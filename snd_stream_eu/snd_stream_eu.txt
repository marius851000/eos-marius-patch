;original by Irdkwia, EU adaptation by marius851000. I (marius) publish the **change** into the public domain, but there is the original copyright of Irdkwia that remain.

.nds
.definelabel FStreamAlloc,    0x2008168     ;() Is usually done first, before any reading is done. Seems to instantiate the Filestream?
.definelabel FStreamCtor,     0x2008204     ;(r0 = PtrFStreamStruct)  Zeroes the content of the struct
.definelabel FStreamFOpen,    0x2008210     ;(r0 = PtrFStreamStruct, r1 = PtrFPath) Open the file for reading
.definelabel FStreamSeek,     0x20082A8     ;(r0 = PtrFStreamStruct, r1 = OffsetToSeekTo, r2 = unknown?(usually 0) )
;2008244h
.definelabel FStreamRead,     0x2008254     ;(r0 = PtrFStreamStruct, r1 = PtrOutBuffer, r2 = NbBytesToRead ) Read the ammount of bytes specified to the buffer, for the FStream object
.definelabel FStreamClose,    0x20082C4     ;(r0 = PtrFStreamStruct)  Close the filestream
.definelabel FStreamDealloc,  0x2008194     ;() ???

.definelabel snd_addr, 0x023B0000
.definelabel snd_size, 0x15888
.definelabel snd_loop, 0x1400
.definelabel swap_time, 0x61

.open "arm9.bin", 0x02000000
	.org 0x020a72f8 ; changed
	.area 0x400
	playing:
		.dcb 0
	ofstream:
		.dcb 0
	reload:
		.dcb 0
		.dcb 0
	start:
		.word 0x0
	timer:
		.word 0x0
	filename:
		.fill 0x40, 0x0
	fstream:
		.fill 0x48, 0x0
	loop:
		.word 0x0
	SetMusicInfo:
		stmdb r13!,{r4,r5,r14}
		bl 0x02079c20 ; changed
		ldr r1,=reload
		ldrb r0,[r1]
		cmp r0,#0
		beq no_reload
		mov r0,#0
		strb r0,[r1]
		
		ldr r1,=ofstream
		ldrb r0,[r1]
		cmp r0,#0
		beq no_close
		ldr r0,=fstream
		bl FStreamClose
	no_close:
		ldr r1,=ofstream
		mov r0,#1
		strb r0,[r1]
		ldr r0,=fstream
		bl FStreamCtor
		ldr r0,=fstream
		ldr r1,=filename
		bl FStreamFOpen
		
		mov r0,#0
		ldr r1,=start
		str r0,[r1]
		ldr r1,=timer
		str r0,[r1]
		
		mov r0, #1
		ldr r1,=playing
		strb r0,[r1]

	no_reload:
		ldr r1,=playing
		ldrb r0,[r1]
		cmp r0,#0
		beq end_set_music_info
		ldr r1,=0x022b8370 ; changed
		mov r3, #0x10
		mvn r2, r3
		ldrh r0,[r1,#0x34]
		and r0,r0,r2
		strh r0,[r1,#0x34]
		ldr r4,=timer
		ldr r0,[r4]
		cmp r0,#0
		subne r0,r0,#1
		moveq r0,swap_time
		str r0,[r4]
		bne end_set_music_info
		
		sub r13,r13,#0x30
		
		ldr r2,=start
		ldr r1,[r2]
		ldr r4,=snd_size
		add r0,r1,r4
		str r0,[r2]
		
		ldr r0,=fstream
		add r1,r1,#0x2C
		mov r2,#0
		bl FStreamSeek
		
		ldr r0,=fstream
		bl 0x2008244 ; changed
		
		ldr r2,=start
		ldr r1,[r2]
		cmp r1,r0
		ldrge r3,=loop
		ldrge r3,[r3]
		addge r3,r3,r1
		subge r3,r3,r0
		strge r3,[r2]
		movle r5,#0
		ble read_once
		sub r2,r1,r0
		sub r5,r4,r2
		sub r5,r5,#0x2C
		ldr r0,=fstream
		ldr r1,=snd_addr
		mov r2,r5
		bl FStreamRead
		ldr r1,=loop
		ldr r1,[r1]
		ldr r0,=fstream
		add r1,r1,#0x2C
		mov r2,#0
		bl FStreamSeek
	read_once:
		ldr r0,=fstream
		ldr r1,=snd_addr
		add r1,r1,r5
		sub r2,r4,r5
		bl FStreamRead
		
		; PNT
		ldr r0,=(snd_size-snd_loop)/4
		str r0,[r13]
		; LEN
		ldr r0,=snd_loop/4
		str r0,[r13,#0x4]
		; Volume
		ldr r0,=0x3C
		str r0,[r13,#0x8]
		; ???
		mov r0,#0x0
		str r0,[r13,#0xC]
		; 0x10000-TMR
		ldr r0,=0x17C
		str r0,[r13,#0x10]
		; Pan
		ldr r0,=0x40
		str r0,[r13,#0x14]
		; Channel
		mov r0,#4
		; Sound Type
		mov r1,#1
		; Sound Start
		ldr r2,=snd_addr
		; Sound Repeat
		mov r3,#1
		bl 0x0207ce04 ; changed
		
		ldr r1,=0x022b8370 ; changed
		mov r3, #0x10
		mvn r2, r3
		ldrh r0,[r1,#0x36]
		and r0,r0,r2
		strh r0,[r1,#0x36]
		ldrh r0,[r1,#0x32]
		orr r0,r0,r3
		strh r0,[r1,#0x32]
		
		add r13,r13,#0x30
	end_set_music_info:
		ldmia r13!,{r4,r5,r15}
		.pool
	.endarea

	.org 0x020711dc ; changed
	;hmmm... That seems useless, this address already point here. Will still change just in case.
	.area 0x4
		bl 0x0206ce64 ; changed
	.endarea

	.org 0x020713d0 ; changed
	.area 0x4
		bl SetMusicInfo
	.endarea
.close

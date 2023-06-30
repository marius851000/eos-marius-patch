;original by Irdkwia, EU adaptation by marius851000. I (marius) publish the **change** into the public domain, but there is the original copyright of Irdkwia that remain.


;So... THis add double buffering.
;a buffer is for two second. They have a separation of 4 audio frame. The first half of a buffer is loaded 3 frame before the buffer switch, the second half 3 frame after switching.
.nds
.definelabel FStreamAlloc,    0x2008168     ;() Is usually done first, before any reading is done. Seems to instantiate the Filestream?
.definelabel FStreamCtor,     0x2008204     ;(r0 = PtrFStreamStruct)  Zeroes the content of the struct
.definelabel FStreamFOpen,    0x2008210     ;(r0 = PtrFStreamStruct, r1 = PtrFPath) Open the file for reading
.definelabel FStreamSeek,     0x20082A8     ;(r0 = PtrFStreamStruct, r1 = OffsetToSeekTo, r2 = unknown?(usually 0) )
;2008244h
.definelabel FStreamRead,     0x2008254     ;(r0 = PtrFStreamStruct, r1 = PtrOutBuffer, r2 = NbBytesToRead ) Read the ammount of bytes specified to the buffer, for the FStream object
.definelabel FStreamClose,    0x20082C4     ;(r0 = PtrFStreamStruct)  Close the filestream
.definelabel FStreamDealloc,  0x2008194     ;() ???

.definelabel NB_AF_MARGIN_BYTES, 3676
.definelabel NB_AF_MARGIN, 4

;.definelabel snd_addr, 0x023B0000
;.definelabel snd_size, 0x15888; a.k.a 1 second of the signed 16 audio in byte
;.definelabel buffer_base, 0x023B0000
;.definelabel BUFFER_SIZE, 0x0000ac44; + 3900  + 882 - 40; for 0.5 seconds
.definelabel buffer_base, 0x023A7080; overlay 36
.definelabel BUFFER_SIZE, 0x2b110; 2 seconds
.definelabel TIMER_BASE, 0xc1
.definelabel snd_loop, 0x1400

.open "arm9.bin", 0x02000000
	.org 0x020a72f8 ; changed
	.area 0x400
	playing:
		.dcb 0
	ofstream:
		.dcb 0
	reload:
		.dcb 0 ; set to 1 if the stream should be reloaded
	next_buffer:
		.dcb 0 ; nextbuffer, boolean, which buffer to fill (opposite to the one being played) (0 or 1)
	pos_in_file:
		.word 0x0 ; position in file, including header
	timer:
		.word 0x0
	filename:
		.fill 0x40, 0x0
	fstream: ; file_stream
		.fill 0x48, 0x0
	loop:
		.word 0x0
	buffer_addresses:
		.word buffer_base
		.word buffer_base + NB_AF_MARGIN_BYTES
	loop_buffer:
		.word 0x0
	
	; ----------------
	; - Some IO init -
	; ----------------
	SetMusicInfo:
		stmdb r13!,{r4,r5,r6,r7,r8,r14}
		; the original function that this one replace
		bl 0x02079c20 ; changed
		
		; if !reload { jump @no_reload; } else ...
		ldr r1,=reload
		ldrb r0,[r1]
		cmp r0,#0
		beq no_reload

		; reload = false
		mov r0,#0
		strb r0,[r1]
		
		; if ofstream { FileClose(&fstream) }
		ldr r1,=ofstream
		ldrb r0,[r1]
		cmp r0,#0
		beq no_closecurrent_buffer:
		.dcb 0 ; current buffer, boolean, which buffer to fill (0 or 1)
		ldr r0,=fstream
		bl FStreamClose
	no_close:

		; ofstream = false
		ldr r1,=ofstream
		mov r0,#1
		strb r0,[r1]

		; FileInitVeneer(&fstream)
		ldr r0,=fstream
		bl FStreamCtor

		; FileOpen(&fstream, &filename)
		ldr r0,=fstream
		ldr r1,=filename
		bl FStreamFOpen
		
		; pos_in_file = 0x2C
		mov r0,0x2C ; skip header
		ldr r1,=pos_in_file
		str r0,[r1]

		; timer = 2
		mov r0, #2
		ldr r1,=timer
		str r0,[r1]
		
		; playing = true
		mov r0, #1
		ldr r1,=playing
		strb r0,[r1]

	no_reload:
		; if (!playing) { return }
		ldr r1,=playing
		ldrb r0,[r1]
		cmp r0,#0
		beq end_set_music_info

		; TODO: understand this !!!
		; GLOBAL_UNK->field_0x34 &= 0xFFEF; (short)
		ldr r1,=0x022b8370 ; changed ; unknown value, contain some struct. Called GLOBAL_UNK. Semmingly related to arm7 FIFO's
		mov r3, #0x10
		mvn r2, r3
		ldrh r0,[r1,#0x34]
		and r0,r0,r2
		strh r0,[r1,#0x34]

		; timer -= 1;
		ldr r4, =timer
		ldr r0, [r4]
		sub r0, r0, #1
		str r0, [r4]

		;;; the big jump
		; if it is nearly at the end of the buffer, preload the first half of the second buffer
		cmp r0, NB_AF_MARGIN
		moveq r8, 0
		beq preload_next_buffer
		; if it is near the beggining of the buffer, load the second half of the current buffer
		cmp r0, TIMER_BASE-1-NB_AF_MARGIN
		moveq r8, 1
		beq preload_next_buffer
		; if the timer is 0, switch bufer
		cmp r0, #0
		beq switch_and_play_next_buffer
		b end_set_music_info

		preload_next_buffer:

		;;;; Rought plan
		; r8 determine where to load:
		; 0 = first half of the next buffer
		; 1 = second half of the current buffer

		; plan don’t take into account r8
		; buffer_to_fill_addr = buffer_addresses[next_buffer]
		; if (pos_in_file + BUFFER_SIZE) >= file_size {
		; 	nb_bytes_to_read = pos_in_file + BUFFER_SIZE - file_size;
		; } else {
		;	nb_bytes_to_read = BUFFER_SIZE
		; }
		; @stuff
		; FileSeek(fstream, pos_in_file)
		; FileRead(fstream, buffer_to_fill_addr, BUFFER_SIZE+8)
		; if (pos_in_file + BUFFER_SIZE >= file_size {
		;   nb_bytes_to_read = BUFFER_SIZE - nb_bytes_to_read;
		;   jump @stuff
		; }

		; r4 = pos_in_file + BUFFER_SIZE/2
		ldr r1, [pos_in_file]
		ldr r2, =(BUFFER_SIZE/2)
		add r4, r1, r2

		; file_size = FileGetSize(&fstream);
		ldr r0,=fstream
		bl 0x2008244

		; if (r4 < file_size)
		cmp r4, r0
		bge file_overflow_stuff
		; r6 = BUFFER_SIZE/2
		ldr r6, =(BUFFER_SIZE/2)
		mov r7, #1
		b end_file_overflow_management_stuff
		file_overflow_stuff:
		; else {r6 = file_size - pos_in_file} // file_size in r0
		ldr r6, [pos_in_file]
		sub r6, r0, r6
		//r7 = 0
		mov r7, #0
		end_file_overflow_management_stuff:

		; r4 = buffer_addresses[if r8 == 0 {next_buffer} else {!next_buffer}] + if r8 == 1 { BUFFER_SIZE/2 } else { 0 }
		ldr r1, =buffer_addresses
		ldr r2, =next_buffer
		ldrb r2, [r2]
		cmp r8, #1
		bne no_switching_buffer_for_loading
		cmp r2, #1
		moveq r2, #0
		movne r2, #1
		no_switching_buffer_for_loading:
		mov r3, #4
		mul r2, r2, r3
		add r1, r1, r2
		ldr r4, [r1]
		ldr r0, =(BUFFER_SIZE/2)
		cmp r8, #1
		addeq r4, r4, r0


		continue_loading_music:
		; FileSeek(&fstream, pos_in_file, SEEK_SET)
		ldr r0, =fstream
		ldr r1, [pos_in_file]
		mov r2, #0
		bl FStreamSeek

		; FileRead(&fstream, r4, r6)
		ldr r0, =fstream
		mov r1, r4
		mov r2, r6
		bl FStreamRead

		; pos_in_file += r6
		ldr r0, [pos_in_file]
		add r0, r6
		str r0, [pos_in_file]

		; if (r7 == 1) {
		cmp r7, #0
		; return
		bne end_set_music_info
		; }

		; pos_in_file = 0x2C
		mov r0, 0x2C
		str r0, [pos_in_file]

		; r6 = (BUFFER_SIZE/2) - r6
		ldr r0, =(BUFFER_SIZE/2)
		sub r6, r6, r0

		; r4 += r6
		add r4, r4, r6

		; r7 = 1
		mov r7, #1

		; jump continue_loading_music
		b continue_loading_music
	switch_and_play_next_buffer:
		; rought plan
		; PlayBuffer(buffer_addresses[next_buffer], ...);
		; next_buffer = next_buffer == 0 : 1 ? 0;
		; timer = TIMER_BASE

		; r4 = buffer_addresses[next_buffer]
		ldr r1, =buffer_addresses
		ldr r2, =next_buffer
		ldrb r2, [r2]
		mov r3, #4
		mul r2, r2, r3
		add r1, r1, r2
		ldr r4, [r1]

		sub r13,r13,#0x30 ; allocate 0x30 of stack
		
		;;; Set various variable and call the function to tell the arm7 core to play it
		; PNT
		ldr r0,=(BUFFER_SIZE-snd_loop)/4
		;ldr r0, =(BUFFER_SIZE/4-1)
		str r0,[r13]
		; LEN
		ldr r0,=snd_loop/4
		;mov r0, #1
		str r0,[r13,#0x4]
		; Volume
		ldr r0,=0x3C
		str r0,[r13,#0x8]
		; ???
		mov r0,#0x0
		str r0,[r13,#0xC]
		; 0x10000-TMR
		ldr r0,=0x17C ; timer stuff. I think
		str r0,[r13,#0x10]
		; Pan
		ldr r0,=0x40
		str r0,[r13,#0x14]
		; Channel
		mov r0,#4
		; Sound Type
		mov r1,#1
		; Sound Start
		mov r2, r4
		; Sound Repeat
		mov r3,#1
		bl 0x0207ce04 ; changed ; tell arm7 to play an audio

		; next_buffer = next_buffer == 0 : 1 ? 0;
		ldr r1, =next_buffer
		ldrb r0, [r1]
		cmp r0, #1
		moveq r0, #0
		movne r0, #1
		strb r0, [r1]

		; timer = swap_time
		ldr r1, =timer
		mov r0, TIMER_BASE
		str r0, [r1]

		

		; ----------------------------------
		; - some de-initilization stuff... -
		; ----------------------------------

		; GLOBAL_UNK->field_0x36 &= 0xFFEF // short
		ldr r1,=0x022b8370 ; changed ; //GLOBAL_UNK
		mov r3, #0x10
		mvn r2, r3 ; 0xFFFFFEFF
		ldrh r0,[r1,#0x36]
		and r0,r0,r2
		strh r0,[r1,#0x36]

		; GLOBAL_UNK->field_0x32 &= 0x0010
		ldrh r0,[r1,#0x32]
		orr r0,r0,r3
		strh r0,[r1,#0x32]
		
		add r13,r13,#0x30 ; free the previously allocated stack
	end_set_music_info:
		ldmia r13!,{r4,r5,r6,r7,r8,r15}
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

; ==========================================
; SOUND STREAM: Official Version
; Plays a streamed sound as the main BGM
; BGM IDs 1000+X are translated as playing
; file "SOUND/BGM/streamed_X.wav"
; ==========================================

.nds

.definelabel RESERVE_CHANNEL, 15 ; Addendum -> Mandatory (Channel must be reserved, ignore the rest) ; Set to 15 to actually reserve the channel for snd_stream (Note this may alter the quality of sequenced BGMs)
.definelabel USE_CHANNEL, 15

.definelabel BUFFER_SIZE, 0x8000

.definelabel FunctionUnk1, 0x02002CB4

.definelabel FStreamAlloc, 0x2008168
.definelabel FStreamCtor, 0x2008204
.definelabel FStreamFOpen, 0x2008210
.definelabel FStreamSeek, 0x20082A8
.definelabel FStreamRead, 0x2008254
.definelabel FStreamClose, 0x20082C4
.definelabel FStreamDealloc, 0x2008194

.definelabel SPrintF, 0x0200D634

.definelabel HookCode1, 0x020198D0
.definelabel HookCode2, 0x0201996C
.definelabel EndOfStartBGM, 0x02019AF8
.definelabel HookCode3, 0x02019B30
.definelabel HookCode4, 0x02019C64

.definelabel HookSoundProcess, 0x02071038
.definelabel HookChannel1, 0x020743EC
.definelabel HookChannel2, 0x020743F4

.definelabel FunctionUnk2, 0x02079888

.definelabel SetChannelVolume, 0x0207CA24
.definelabel SetChannelGlobal, 0x0207CA6C

.definelabel EuclidianDivision, 0x0208FEA4

.definelabel ActorLevelListClearedArea, 0x020A6A58

.definelabel ChannelsStruct, 0x022B7A30

; TODO: Change that address
.definelabel snd_addr, 0x023B0000

.definelabel TMR2, 0x04000108

.open "arm9.bin", 0x02000000
	.org HookCode1
	.area 0x4
		b HookCheckBGM ; -> Hook Check BGM: r6: ID, r5: Fade In, r4: Volume
	EndHookCheckBGM:
	.endarea
	.org HookCode2
	.area 0x4
		b HookStartBGM ; -> Hook Play BGM: r6: ID, r5: Fade In, r4: Volume
	.endarea
	.org HookCode3
	.area 0x4
		b HookStopBGM ; -> Hook Stop BGM: r0/r4: Fade Out
	EndHookStopBGM:
	.endarea
	
	.org HookCode4
	.area 0x4
		b HookChangeBGM ; -> Hook Change BGM: r5: Duration, r4: Volume
	EndHookChangeBGM:
	.endarea
	
	.org HookChannel1
	.area 0x4
		mov r2,RESERVE_CHANNEL
	.endarea
	.org HookChannel2
	.area 0x4
		cmp r0,RESERVE_CHANNEL
	.endarea

	.org ActorLevelListClearedArea
	.area 0x800
	playing:        ; TIP: set/unset this to play/stop the sound file. Available since v1.
		.dcb 0
	ofstream:       ; 
		.dcb 0
	reload:         ; TIP: set this to reload the sound file. Available since v1.
		.dcb 0
	buffer:         ; 
		.dcb 0
	start:          ; 
		.word 0x0
	timer:
		.word 0x0
	filename:       ; TIP: this controls the file to use. Available since v1.
		.fill 0x40, 0x0
	fstream:        ; 
		.fill 0x48, 0x0
	loop:           ; TIP: this controls where the loop point of the sound will be; measured in bytes. Available since v1.
		.word 0x0
	volume:         ; TIP: this controls the volume of the current sound (/127); currently at 60/127. Available since this version.
		.word 0x3C
	fade_to:        ; 
		.word 0x0
	fade_time:      ; 
		.word 0x0
	fade_play:      ; 
		.word 0x0
	freq:           ; 
		.word 0x0
	data_start:     ;
		.word 0x0
	data_end:       ;
		.word 0x0
	old_timer:      ;
		.word 0x0
	HookCheckBGM:
		bl FunctionUnk1
		ldr r0,[bgm_no]
		cmp r6,r0
		beq EndHookCheckBGM
		ldr r1,=playing
		mov r0,#0
		strb r0,[r1]
		mvn r0,#0
		str r0,[bgm_no]
		b EndHookCheckBGM
	HookStartBGM:
		ldr r0,[bgm_no]
		cmp r6,r0
		beq EndOfStartBGM
		ldr r0,=filename
		ldr r1,=string_strm
		sub r2,r6,#0x3E8
		bl SPrintF
		str r6,[bgm_no]
		rsb  r1,r4,r4,lsl #0x7
		mov  r0,r1,asr #0x8
		str r0,[fade_to]
		mov  r0,#0x3E8
		mul  r0,r5,r0
		mov  r1,#0x258
		bl EuclidianDivision
		cmp r0,#0
		moveq r0,#1
		str r0,[fade_time]
		mov r0,#0
		str r0,[volume]
		ldr r1,=playing
		mov r0,#1
		str r0,[fade_play]
		strb r0,[r1]
		ldr r1,=reload
		strb r0,[r1]
		b EndOfStartBGM
	HookStopBGM:
		mov  r4,r0
		mvn r0,#0
		str r0,[bgm_no]
		mov  r0,#0x3E8
		mul  r0,r4,r0
		mov  r1,#0x258
		bl EuclidianDivision
		cmp r0,#0
		moveq r0,#1
		str r0,[fade_time]
		mov r0,#0
		str r0,[fade_play]
		str r0,[fade_to]
		b EndHookStopBGM
	HookChangeBGM:
		bl FunctionUnk1
		rsb  r1,r4,r4,lsl #0x7
		mov  r0,r1,asr #0x8
		str r0,[fade_to]
		mov  r0,#0x3E8
		mul  r0,r5,r0
		mov  r1,#0x258
		bl EuclidianDivision
		cmp r0,#0
		moveq r0,#1
		str r0,[fade_time]
		b EndHookChangeBGM
	bgm_no:
		.word 0xFFFFFFFF
	ReadWAVChunk:
		stmdb r13!,{r14}
		ldr r0,=fstream
		ldr r1,[current_pos]
		mov r2,#0
		bl FStreamSeek
		
		ldr r0,=fstream
		ldr r1,=chunk_info
		mov r2,#8
		bl FStreamRead
		ldr r0,[chunk_info]
		ldr r1,=0x20746D66
		cmp r0,r1
		beq process_fmt
		ldr r1,=0x6C706D73
		cmp r0,r1
		beq process_smpl
		ldr r1,=0x61746164
		cmp r0,r1
		beq process_data
		b ignore_chunk
	process_fmt:
		ldr r0,=fstream
		mov r1,#4
		mov r2,#1
		bl FStreamSeek
		ldr r0,=fstream
		ldr r1,=freq
		mov r2,#4
		bl FStreamRead
		b ignore_chunk
	process_smpl:
		ldr r0,=fstream
		mov r1,#0x1C
		mov r2,#1
		bl FStreamSeek
		ldr r0,=fstream
		ldr r1,=chunk_info ; Replace chunk info
		mov r2,#4
		bl FStreamRead
		ldr r1,[chunk_info]
		cmp r1,#0
		beq ignore_chunk
		ldr r0,=fstream
		mov r1,4+8
		mov r2,#1
		bl FStreamSeek
		ldr r0,=fstream
		ldr r1,=loop
		mov r2,#4
		bl FStreamRead
		ldr r0,[loop]
		mov r0,r0,lsl #0x1
		str r0,[loop]
		b ignore_chunk
	process_data:
		ldr r0,[chunk_size]
		ldr r1,[current_pos]
		add r1,r1,#8
		str r1,[data_start]
		add r1,r1,r0
		str r1,[data_end]
	ignore_chunk:
		ldr r0,[chunk_size]
		ldr r1,[current_pos]
		add r1,r1,#8
		add r1,r1,r0
		str r1,[current_pos]
		ldr r0,[eof]
		cmp r1,r0
		movge r0,#0
		movlt r0,#1
		ldmia r13!,{r15}
	chunk_info:
		.word 0x0
	chunk_size:
		.word 0x0
	current_pos:
		.word 0x0
	eof:
		.word 0x0
		.pool
	GetTimer:
		stmdb r13!,{r14}
		ldr r0,=0xFFB0FF ; Clock Rate
		ldr r1,[freq]
		bl EuclidianDivision
		ldr r2,[freq]
		mov r2,r2,lsr #0x1
		cmp r1,r2
		addge r0,r0,#1
		ldmia r13!,{r15}
	SwapBuffers:
		stmdb r13!,{r4,r5,r14}
		ldr r1,[start]
		mov r4,BUFFER_SIZE/2
		add r0,r1,r4
		str r0,[start]
		
		ldr r0,=fstream
		ldr r2,[data_start]
		add r1,r1,r2
		mov r2,#0
		bl FStreamSeek
		
		ldr r0,[data_end]
		
		ldr r1,[start]
		cmp r1,r0
		ldrgt r3,[loop]
		addgt r3,r3,r1
		subgt r3,r3,r0
		strgt r3,[start]
		movle r5,#0
		ble read_once
		sub r2,r1,r0
		sub r5,r4,r2
		ldr r2,[data_start]
		sub r5,r5,r2
		ldr r0,=fstream
		ldr r3,=buffer
		ldrb r3,[r3]
		cmp r3,#0
		ldr r1,=snd_addr
		addne r1,r1,r4
		mov r2,r5
		bl FStreamRead
		ldr r1,[loop]
		ldr r0,=fstream
		ldr r2,[data_start]
		add r1,r1,r2
		mov r2,#0
		bl FStreamSeek
	read_once:
		ldr r0,=fstream
		ldr r3,=buffer
		ldrb r3,[r3]
		cmp r3,#0
		ldr r1,=snd_addr
		addne r1,r1,r4
		add r1,r1,r5
		sub r2,r4,r5
		bl FStreamRead
		ldr r0,=buffer
		ldrb r3,[r0]
		rsb r3,r3,#1
		strb r3,[r0]
		ldmia r13!,{r4,r5,r15}
	SetMusicInfo:
		stmdb r13!,{r4,r14}
		bl FunctionUnk2
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
		ldr r0,=TMR2
		mov r1,#0
		strh r1,[r0,#+0x2]
		strh r1,[r0,#+0x6]
		ldr r1,=ofstream
		mov r0,#1
		strb r0,[r1]
		ldr r0,=fstream
		bl FStreamCtor
		ldr r0,=fstream
		ldr r1,=filename
		bl FStreamFOpen
		
		ldr r0,=fstream
		mov r1,#4
		mov r2,#0
		bl FStreamSeek
		ldr r0,=fstream
		ldr r1,=eof
		mov r2,#4
		bl FStreamRead
		
		mov r1,#0x0
		str r1,[loop]
		mov r1,#0xC
		str r1,[current_pos]
	header_loop:
		bl ReadWAVChunk
		cmp r0,#0
		bne header_loop
		
		mov r0,#0
		ldr r1,=start
		str r0,[r1]
		ldr r1,=timer
		str r0,[r1]
		
		mov r0,#0
		ldr r3,=buffer
		strb r0,[r3]
		bl SwapBuffers
		
		sub r13,r13,#0x30
		
		; PNT
		mov r0,#0
		str r0,[r13]
		; LEN
		mov r0,BUFFER_SIZE/4
		str r0,[r13,#0x4]
		; Volume
		ldr r0,[volume]
		str r0,[r13,#0x8]
		; ???
		mov r0,#0x0
		str r0,[r13,#0xC]
		; TMR
		bl GetTimer
		str r0,[r13,#0x10]
		; Pan
		ldr r0,=0x40
		str r0,[r13,#0x14]
		; Channel
		mov r0,USE_CHANNEL
		; Sound Type
		mov r1,#1
		; Sound Start
		ldr r2,=snd_addr
		; Sound Repeat
		mov r3,#1
		bl SetChannelGlobal
		
		ldr r1,=ChannelsStruct
		mov r3, 1<<USE_CHANNEL
		mvn r2, r3
		ldrh r0,[r1,#0x36]
		and r0,r0,r2
		strh r0,[r1,#0x36]
		ldrh r0,[r1,#0x32]
		orr r0,r0,r3
		strh r0,[r1,#0x32]
		
		add r13,r13,#0x30
		
		mov r0, #1
		ldr r1,=playing
		strb r0,[r1]
		
		ldr r0,=TMR2
		mov r1,#0
		str r1,[old_timer]
		mov r1,#0x830000
		str r1,[r0]
		mov r1,#0x840000
		str r1,[r0,+0x4]

	no_reload:
		ldr r1,=playing
		ldrb r0,[r1]
		cmp r0,#0
		beq end_set_music_info
		ldr r1,[fade_time]
		cmp r1,#0
		beq no_fade
		ldr r0,[volume]
		ldr r2,[fade_to]
		cmp r2,r0
		subge r0,r2,r0
		sublt r0,r0,r2
		bl EuclidianDivision
		ldr r1,[volume]
		ldr r2,[fade_to]
		cmp r2,r1
		addge r1,r1,r0
		sublt r1,r1,r0
		str r1,[volume]
		ldr r2,[fade_time]
		subs r2,r2,#1
		str r2,[fade_time]
		bne no_fade
		ldr r1,=playing
		ldr r0,[fade_play]
		strb r0,[r1]
	no_fade:
		mov r0,1<<USE_CHANNEL
		ldr r1,[volume]
		mov r2,#0
		bl SetChannelVolume
		ldr r1,=ChannelsStruct
		mov r3,1<<USE_CHANNEL
		mvn r2, r3
		ldrh r0,[r1,#0x34]
		and r0,r0,r2
		strh r0,[r1,#0x34]
		bl GetTimer
		mov r4,r0
		ldr r0,=TMR2
		ldmia r0,{r1,r2}
		mov r1,r1,lsl #0x10
		mov r1,r1,lsr #0x10
		add r1,r1,r2,lsl #0x10
		ldr r2,[old_timer]
		str r1,[old_timer]
		ldr r3,[timer]
		cmp r2,r1
		bls no_handle_overflow
		rsb r2,r2,#0
		add r3,r3,r2,lsl #0x9 ; *512
		mov r2,#0x0
	no_handle_overflow:
		sub r1,r1,r2
		add r3,r3,r1,lsl #0x9 ; *512
		mov r2,BUFFER_SIZE/2
		mul r2,r2,r4
		cmp r3,r2
		subge r3,r3,r2
		str r3,[timer]
		add r2,r2,#100
		cmp r3,r2,lsr #0x1
		bgt high_end
		ldr r1,=buffer
		ldrb r1,[r1]
		cmp r1,#1
		bleq SwapBuffers
		b end_set_music_info
	high_end:
		ldr r1,=buffer
		ldrb r1,[r1]
		cmp r1,#0
		bleq SwapBuffers
	end_set_music_info:
		ldmia r13!,{r4,r15}
		.pool
	string_strm:
		;.ascii "SOUND/BGM/bgm%04d.smd",0
		.ascii "SOUND/BGM/streamed_%d.wav",0
	.endarea
	
	.org HookSoundProcess
	.area 0x4
		bl SetMusicInfo
	.endarea
.close

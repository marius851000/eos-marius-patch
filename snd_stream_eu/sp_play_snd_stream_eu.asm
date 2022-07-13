; 
; ------------------------------------------------------------------------------
; Play a music track with irdkwia's snd_stream patch
; The .wav file that should be played back must be 44100 Hz, 16-bit Mono.
; arg 0: ID for specifying a file located at path "SOUND/BGM/streamed_[id].wav"
; ------------------------------------------------------------------------------

; original by techticks, EU adaption by marius851000

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x810

; Uncomment the correct version

; For US
;.include "lib/stdlib_us.asm"
;.definelabel ProcStartAddress, 0x022E7248
;.definelabel ProcJumpAddress, 0x022E7AC0

;.definelabel SndStreamPlaying, 0x020A6A58
;.definelabel SndStreamReload, 0x020A6A5A
;.definelabel SndStreamTrackName, 0x020A6A64

;.definelabel snprintf, 0x208955C

; For EU
.include "lib/stdlib_eu.asm"
.definelabel ProcStartAddress, 0x022E7B88
.definelabel ProcJumpAddress, 0x022E8400

.definelabel SndStreamPlaying, 0x020a72f8
.definelabel SndStreamReload, 0x020a72fa
.definelabel SndStreamTrackName, 0x20a7304

.definelabel snprintf, 0x20898F4

; File creation
.create "./code_out.bin", 0x022E7B88 ; Change to the actual offset as this directive doesn't accept labels
	.org ProcStartAddress
	.area MaxSize ; Define the size of the area
		; Format file name that should be loaded
    ldr r0, =SndStreamTrackName ; Target buffer
    mov r1, 0x40 ; Length
    ldr r2, =FileNameFormat ; Format string
    mov r3, r7 ; File number
    bl snprintf

    ; Set the reload flag to 1
    ldr r1, =SndStreamReload
    mov r2, #1
    strb r2, [r1]

    ; SndStreamPlaying will automatically be set to 1 and SndStreamReload will be cleared
		
		; Always branch at the end
		b ProcJumpAddress
		.pool

    .area 0x40
    FileNameFormat:
      ; Name of the .wav file that should be played
      .ascii "SOUND/BGM/streamed_%d.wav"
      dcb 0
    .endarea
	.endarea

.close

; 
; ------------------------------------------------------------------------------
; Set the snd_stream music track to playing or paused
; arg 0: 0 = paused, 1 = playing
; ------------------------------------------------------------------------------


.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x810

; Uncomment the correct version

; For US
;.include "lib/stdlib_us.asm"
;.definelabel ProcStartAddress, 0x022E7248
;.definelabel ProcJumpAddress, 0x022E7AC0

; For EU
.include "lib/stdlib_eu.asm"
.definelabel ProcStartAddress, 0x022E7B88
.definelabel ProcJumpAddress, 0x022E8400

.definelabel SndStreamPlaying, 0x020a72f8
.definelabel SndStreamReload, 0x020a72fa
.definelabel SndStreamTrackName, 0x20a7304

; File creation
.create "./code_out.bin", 0x022E7B88 ; Change to the actual offset as this directive doesn't accept labels
	.org ProcStartAddress
	.area MaxSize ; Define the size of the area

    ; Set the playing flag to the value of the first argument
		; 0 = paused, 1 = playing
    ldr r1, =SndStreamPlaying
    strb r7, [r1]
		
		; Always branch at the end
		b ProcJumpAddress
		.pool
	.endarea

.close

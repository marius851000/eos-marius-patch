; Make the screen flush mode 4 faster by transforming division by 255 to division by 256, resulting in hard-to-perceive changes
; but a much faster code.
;
; Avoid Desmume skipping half the frames.

; happens to be identical for EU and US

.nds

.open "arm9.bin", 0x02000000
	.org 0x0200af48
	.area 4
		asr r0,r0, #8
	.endarea
	.org 0x0200af5c
	.area 4
		asr r0,r0, #8
	.endarea
	.org 0x0200af70
	.area 4
		asr r0,r0, #8
	.endarea
.close

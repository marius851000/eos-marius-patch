; ------------------------------------------------------------------------------
; Swap Monster Entry
; Swaps two monster data entries
; See Remove Party if you are using this on current party members
; Param 1: ent_id_1
; Param 2: ent_id_2
; Returns: nothing
; ------------------------------------------------------------------------------

; by Adex

.relativeinclude on
.nds
.arm


.definelabel MaxSize, 0x810

; For US
.include "lib/stdlib_us.asm"
.definelabel ProcStartAddress, 0x022E7248
.definelabel ProcJumpAddress, 0x022E7AC0
.definelabel AssemblyPointer, 0x020B0A48
.definelabel Copy4BytesArray, 0x0200330C

; For EU
;.include "lib/stdlib_eu.asm"
;.definelabel ProcStartAddress, 0x022E7B88
;.definelabel ProcJumpAddress, 0x022E8400
;.definelabel AssemblyPointer, 0x20B138C
;.definelabel Copy4BytesArray, 0x0200330C


; File creation
.create "./code_out.bin", 0x022E7248 ; Change to the actual offset as this directive doesn't accept labels
	.org ProcStartAddress
	.area MaxSize ; Define the size of the area
		sub r13,r13,#0x44
		ldr r1,=AssemblyPointer
		ldr r1,[r1]
		mov r0,r13
		mov r2,#0x44
		mla r1,r7,r2,r1
		bl Copy4BytesArray
		ldr r1,=AssemblyPointer
		ldr r1,[r1]
		mov r2,#0x44
		mla r0,r7,r2,r1
		mla r1,r6,r2,r1
		bl Copy4BytesArray
		ldr r1,=AssemblyPointer
		ldr r1,[r1]
		mov r2,#0x44
		mla r0,r6,r2,r1
		mov r1,r13
		bl Copy4BytesArray
		add r13,r13,#0x44

		b ProcJumpAddress
		.pool
	.endarea
.close
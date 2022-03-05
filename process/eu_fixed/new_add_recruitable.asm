; 
; ------------------------------------------------------------------------------
; New Add Recruitable to Team
; Adds correctly a recruitable to storage team (a.k.a. Assembly), 
; and does not use the recruitable list.
; Param 1: pkmn_id
; Param 2: origin_id+pkmn_level*256 (NB: Hard to pass 3 parameters in 2 values)
; Returns: 1 if successfully added, otherwise 0
; ------------------------------------------------------------------------------

; by irdkwia

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x810

; For US
.include "lib/stdlib_us.asm"
.definelabel ProcStartAddress, 0x022E7248
.definelabel ProcJumpAddress, 0x022E7AC0
.definelabel AllocateSlotInAssembly, 0x02055964
.definelabel CopyStuffFromSomewhereToSomewhereElse, 0x02055B78
.definelabel GetAssemblyEntry, 0x020555A8
.definelabel SomethingIDK, 0x020544C8
.definelabel SomethingIDKBis, 0x02053568

; For EU
;.include "lib/stdlib_eu.asm"
;.definelabel ProcStartAddress, 0x022E7B88
;.definelabel ProcJumpAddress, 0x022E8400
;.definelabel AllocateSlotInAssembly, 0x02055ce0
;.definelabel CopyStuffFromSomewhereToSomewhereElse, 0x02055ef4
;.definelabel GetAssemblyEntry, 0x02055924
;.definelabel SomethingIDK, 0x02054844
;.definelabel SomethingIDKBis, 0x20538e4

; File creation
.create "./code_out.bin", 0x022E7248 ; Change to the actual offset as this directive doesn't accept labels
	.org ProcStartAddress
	.area MaxSize ; Define the size of the area
		bl AllocateSlotInAssembly
		mvn r1, #0
		cmp r0,r1
		moveq r0,#0
		beq ProcJumpAddress
		stmdb r13!, {r4}
		mov r4,r0
		mov r1,r7
		and r2,r6,#0xFF
		mov r3,#0
		bl CopyStuffFromSomewhereToSomewhereElse
		mov r0,r4
		bl GetAssemblyEntry
		mov r4,r0
		mov  r1,r6,lsr #0x8
		mov  r2,#0x0
		bl SomethingIDK
		mov  r0,r4
		bl SomethingIDKBis
		ldmia r13!, {r4}
		mov r0,#1
		b ProcJumpAddress
		.pool
	.endarea
.close
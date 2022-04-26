; ------------------------------------------------------------------------------
; Multithreaded SetAnimation
; Same as SetAnimation, but can be called while other code of the actor is running
; Param 1: Actor ID
; Param 2: Animation ID
; Returns: nothing
; ------------------------------------------------------------------------------

; by marius851000

.relativeinclude on
.nds
.arm


.definelabel MaxSize, 0x810

; For US
;.include "lib/stdlib_us.asm"
; TODO: the US version is actually not done at all
;.definelabel ProcStartAddress, 0x022E7248
;.definelabel ProcJumpAddress, 0x022E7AC0

; For EU
.include "lib/stdlib_eu.asm"
.definelabel ProcStartAddress, 0x022E7B88
.definelabel ProcJumpAddress, 0x022E8400
.definelabel lookup_actor_live_id_for_ground_actor_id, 0x022f87b0
.definelabel live_actors, 0x0232583c

; File creation
.create "./code_out.bin", 0x022E7B88 ; Change to the actual offset as this directive doesn't accept labels
	.org ProcStartAddress
	.area MaxSize ; Define the size of the area
        ; get the the live actor id from the actor id (into r0)
        mov r0, r7
        bl lookup_actor_live_id_for_ground_actor_id
        mov r1, 0xFFFFFFFF
        cmp r0, r1 ; check if it can't be found
        beq end
        ; get the live actor pointer (into r12, use r1 and r0)
        mov r1, 250h
        mul r0, r0, r1
        ldr r1, =live_actors
        ldr r1, [r1]
        add r12, r0, r1
        ; set the direction (for debug) (r12 read, r3 is the pointer to the actor function pointer)
        ldr r3, [r12, #56]
        ldr r3, [r3, #48] ;r3 = function that set the pokemon orientation
        mov r0, r12
        mov r1, r6 ;r1 = actor's orientation
        blx r3
        
        


        end:
		b ProcJumpAddress
		.pool
	.endarea
.close
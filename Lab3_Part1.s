# Start of the data section
.data			
.align 4						# To make sure we start with 4 bytes aligned address (Not important for this one)
SEED:
	.word 0x1234				# Put any non zero seed
	
# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl	main
main:
	# Put your initializations here
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)
	
	li a0, 1000				# change  delay
	li t2, 0xFF

	RESET:
	li t1, 0x00

	LOOP:
	sw t1, 0(s1)
	jal DELAY
	addi t1,t1, 0x01

	beq t1, t2, RESET
	jal LOOP

	
	


	# Subroutines			
DELAY:
	# Insert your code here to make a delay of a0 * 0.1 ms
	addi sp, sp, -8				# push t1 to the stack
	sw t1, 0(sp)
	sw t2, 4(sp)

	addi t2,a0,0
	outer_loop:
	addi t1,x0,833 # t1=0.1ms
	inner_loop:
	addi t1,t1,-1	# t1=t1-1
	beq x0, t1,EXIT_inner
	beq x0,x0,inner_loop
	EXIT_inner:
	addi t2,t2,-1
	beq x0,a0,EXIT_outer
	beq x0,x0,outer_loop
	EXIT_outer:

	lw t1, 0(sp)				# pop t1 from the stack
	lw t2, 4(sp)
	addi sp, sp, 8
	jr ra

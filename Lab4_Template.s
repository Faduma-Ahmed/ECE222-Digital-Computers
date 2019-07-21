##################################################
## Name:    Lab4_Template.s  					##
## Purpose:	Interrupt Handling			 		##
## Author:	Mahmoud A. Elmohr 					##
##################################################

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
	li s0, 0					# Initializes s0 to be 0
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)

	# Enabling Interrupts from core side
	csrrsi zero, mstatus, 0x08 	#enable global interrupt
	csrrsi zero, 0x7C0, 0x02 	#enable push button interrupt line from core side	
	
	# Enable a specific push button interrupt from the PIO side (Check Appendix B)
		
	li s4, 0b100		# interruptMask Detects PB-2
	sw s4, 8(s2)		#load InterruptMask to register

	# Write your functional code here
	 
	#8 LED flash on/off at 1Hz
	
	
    li s0,0
	sw t2,0(s1)
	
	BLINKING:
	bne s0,zero,EXIT
	jal RANDOM_NUM
	
	li a1,5000
	jal DELAY
	bne s0,zero,EXIT
	
	xori t2,t2,0xff
	sw t2,0(s1)

	bne s0,zero,EXIT
	beq x0,x0,BLINKING


	EXIT:
	jal DISPLAY_NUM
	beq x0,x0,BLINKING
	
	# display on led
	# decrement by 10
	# delay by 1 sec
	# return to blinking if s0=0
	





	# End of main function		




# Subroutines						
DELAY:
	# Insert your code here to make a delay of a1 * 0.1 ms
	addi sp, sp, -8				# push t1 to the stack
	sw ra, 0(sp)
	sw t1, 4(sp)

	outer_loop:
	addi t1,x0,833	 			# 0.1ms
	inner_loop:
	addi t1,t1,-1				# t1=t1-1
	beq x0, t1,EXIT_inner
	beq x0,x0,inner_loop
	EXIT_inner:
	addi a1,a1,-1
	bne x0,a1,outer_loop			#only exit outer loop if a0*0.1ms is delayed

			

	lw ra, 0(sp)				# pop t1 from the stack
	lw t1, 4(sp)
	addi sp, sp, 8
	jr ra

DISPLAY_NUM:
	# Insert your code here to display the 32 bits in a0 on the LEDs byte by byte (Least isgnificant byte first) with  seconds delay for each byte and 1 seconds for the last
	addi sp, sp, -4				# push ra, a0 to the stack
	sw ra, 0(sp)
	

	#addi t1,zero,a0

	
	
	LOOP:	
		#for every loop, print the 8 least significant digits to LED, and delay 1 seconds
		sw s0, 0(s1)
		li a1, 10000
		jal DELAY
		addi s0,s0,-10
		jal RANDOM_NUM
		bge s0, zero,LOOP
	


	addi s0,zero,0
	sw s0, 0(s1)
	li a1,10000
	jal DELAY

	lw ra, 0(sp)
	addi sp, sp, 4

	jr ra


RANDOM_NUM:
	# This is a provided pseudo-random number generator no need to modify it, just call it using JAL (the random number is saved at a0)
	addi sp, sp, -20			# push ra to the stack
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	sw t3, 16(sp)
	
	lw t0, 0(gp)				# load the seed or the last previously generated number from the data memory to t0
	li t1, 0x8000
	and t2, t0, t1				# mask bit 16 from the seed
	li t1, 0x2000
	and t3, t0, t1				# mask bit 14 from the seed
	slli t3, t3, 2				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 14 with bit 16
	li t1, 0x1000		
	and t3, t0, t1				# mask bit 13 from the seed
	slli t3, t3, 3				# allign bit 13 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 13 with bit 14 and bit 16
	li t1, 0x400
	and t3, t0, t1				# mask bit 11 from the seed
	slli t3, t3, 5				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 11 with bit 13, bit 14 and bit 16
	srli t2, t2, 15				# shift the xoe result to the right to be the LSB
	slli t0, t0, 1				# shift the seed to the left by 1
	or t0, t0, t2				# add the XOR result to the shifted seed 
	li t1, 0xFFFF				
	and t0, t0, t1				# clean the upper 16 bits to stay 0
	sw t0, 0(gp)				# store the generated number to the data memory to be the new seed
	mv a0, t0					# copy t0 to a0 as a0 is always the return value of any function
	
	lw ra, 0(sp)				# pop ra from the stack
	lw t0, 4(sp)				# pop t0 from the stack
	lw t1, 8(sp)				# pop t1 from the stack
	lw t2, 12(sp)				# pop t2 from the stack
	lw t3, 16(sp)				# pop t3 from the stack
	addi sp, sp, 20
	jr ra


# Interrupt Service Routine
.text
.globl	isr
isr:
	
	addi sp, sp, -16			# push ra to the stack
	sw t5, 0(sp)
	sw t6, 4(sp)
	sw t3, 8(sp)
	sw t1, 12(sp)
	
	# De-bouncing (Due to the bouncing of mechanical switches, we need to de-bounce it to avoid entering the ISR many times for the same button press)
	li t1, 2000000
	debounce:
		addi t1, t1, -1
		bne t1, zero, debounce
		
	# Generate a number from 50 t0 255 and put it in S0	(You shouldn't call the RANDOM_NUM here, you should have called it in the main already and saved it in some register, you just need to make it fit the 50-255 requirement and save it to s0)
	

	li t5,0
	li t6,0
	
	
	li t3,3

	mul t6,a0,t3
	add s0,t6,zero
	
	srli s0,s0,10
	
	li t5,50
	add s0,s0,t5
	
	#addi s0,zero, 11

	#addi t5,s2,12
	
	
	#scale

	#save scaled result to s0

	addi t5,zero,1

	#Clear push button interrupt PIO side to acknowledge handling the interrupt
	sw t5, 12(s2)	#write any value to clear the interrupt
		
	lw t5, 0(sp)				# pop ra from the stack
	lw t6, 4(sp)				# pop t2 from the stack
	lw t3, 8(sp)	
	lw t1, 12(sp)
	addi sp, sp, 16
	

	# Wait until store takes place and read by the PIO
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	

	mret					#return from interrupt

	
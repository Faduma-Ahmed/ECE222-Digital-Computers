##################################################
## Name:    Lab3_Template.s  					##
## Purpose:	Reaction Time Measurement	 		##
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
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)

#a0
# Write your code here
	
	sw zero,0(s1)		#Turn off all 8 LEDs
	#jal PART1

	jal RANDOM_NUM		#produce a random number in a0
	addi t1, a0, 0
	srli t1, t1, 2
	add t1, t1, a0		#t1=1.25a0 (around 2% error)
	li t2,625		
	slli t2,t2,5		#t2=offset=19997
	add t1,t1,t2		#t1=1.25a0+19997 (scaled random delay time)

	

	addi a0, t1, 0		#scaled random delay time saved in a0, t1 discarded
	jal DELAY		#delay random time

	addi t1, zero, 1	#t1=1
	sw t1,0(s1)		#turn on LED 0, t1 discarded
	addi t2, zero, 0	#initialize counter in t2

	waitloop: 

	li a0, 1 		#a0=1
	jal DELAY		#increment 0.1 ms
	addi t2,t2,1		#increment counter
	
	lw t1, 0(s2)		#t1=push button
	andi t1,t1,1		#t1=pb[0]
	beq t1,x0, send_loop	#if pb is pushed, print result to led
	jal waitloop		#else loop
	
	
	send_loop:
	addi a0,t2,0		#a0=counter result
	jal DISPLAY_NUM		#print counter result
	beq zero,zero, send_loop	#infinite loop

	
	
	
	


	
	
# End of main function		
		







# Subroutines			
DELAY:
	# Insert your code here to make a delay of a0 * 0.1 ms
	addi sp, sp, -4				# push t1 to the stack
	sw t1, 0(sp)

	outer_loop:
	addi t1,x0,833 				# 0.1ms
	inner_loop:
	addi t1,t1,-1				# t1=t1-1
	beq x0, t1,EXIT_inner
	beq x0,x0,inner_loop
	EXIT_inner:
	addi a0,a0,-1
	beq x0,a0,EXIT_outer			#only exit outer loop if a0*0.1ms is delayed
	beq x0,x0,outer_loop
	EXIT_outer:			

	lw t1, 0(sp)				# pop t1 from the stack
	addi sp, sp, 4
	jr ra



DISPLAY_NUM:
	# Insert your code here to display the 32 bits in a0 on the LEDs byte by byte (Least isgnificant byte first) with 2 seconds delay for each byte and 5 seconds for the last
	addi sp, sp, -8				# push ra, a0 to the stack
	sw ra, 0(sp)
	sw a0, 4(sp)
	

	li t1,4					#4 bytes in every 32-bit word

	addi a2, a0, 0
	addi a3, s1,0


	LOOP:					#for every loop, print the 8 least significant digits to LED, and delay 2 seconds
		sw a2, 0(a3)
		li a0, 50000
		jal DELAY
		addi t1,t1,-1
		srli a2,a2,8
		beq t1,zero,Exit_LOOP
		beq x0,x0,LOOP
		Exit_LOOP:

		
	li a0, 50000				#delay another 5 seconds after all 32 bits are displayed
	jal DELAY

	lw ra, 0(sp)
	lw a0, 4(sp)				# pop ra, a0 from the stack
	addi sp, sp, 8

	jr ra





RANDOM_NUM:
	# This is a provided pseudorandom number generator no need to modify it, just call it using JAL (the random number is saved at a0)
	addi sp, sp, -4				# push ra to the stack
	sw ra, 0(sp)
	
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
	addi sp, sp, 4
	jr ra
PART1:
	addi sp, sp, -12				# push ra,t1,t2 to the stack
	sw ra, 0(sp)
	sw t1, 4(sp)
	sw t2, 8(sp)

	li t2, 0xFF					# set t2 to max value				

	RESET:
	li t1, 0x00					# wrap around to set 0xFF back to 0

	PART1_LOOP:
	sw t1, 0(s1)					# load value in LED 
	li a0, 1000
	jal DELAY
	addi t1,t1, 0x01				# increment by 1

	beq t1, t2, RESET				# when t1= 0xFF call RESET to wrap around
	jal PART1_LOOP				
	
	lw ra, 0(sp)				# pop ra,t1,t2 from the stack
	lw t1, 4(sp)
	lw t2, 8(sp)
	addi sp, sp, 12
	jr ra

# Lab 3 – Post Lab Report
1.	 If a 32-bit register is counting user reaction time in 0.1 milliseconds increments, what is the maximum amount of time which can be stored in 8 bits, 16-bits, 24-bits and 32-bits?

	8 bits – 0 -> 255		0.0255 seconds
	16 bits – 0 -> 65535		6.5535 seconds
	24 bits – 0 -> 16777215	1677.7215 seconds
	32 bits – 0 -> 4294967295	429496.7295 seconds= 4.97 days

2.	Considering typical human reaction time, which size would be the best for this task (8, 16, 24, or 32 bits)?

	According to https://backyardbrains.com/experiments/reactiontime the human reaction time for a visual stimulus is 0.25 seconds. 
 	Thus, the best size for this task would be a 16 bit register.





##################################################
## Name:    Lab2_Template.s  					##
## Purpose:	Morse Code Transmitter		 		##
## Author:	Mahmoud A. Elmohr 					##
##################################################

# Start of the data section
.data			
.align 4						# To make sure we start with 4 bytes aligned address (Not important for this one)
InputLUT: 						
	# Use the following line only with the board
	.ascii "FAYCU"				# Morse Code Letters are FAYCU
	
	# Use the following 2 lines only on Venus simulator
	#.asciiz "ABCDE"			# Put the 5 Letters here instead of ABCDE	
	#.asciiz "X"				# Leave it as it is. It's used to make sure we are 4 bytes aligned  (as Venus doesn't have the .align directive)

.align 4						# To make sure we start with 4 bytes aligned address (This one is Important)
MorseLUT:
	.word 0xE800
	.word 0xAB80
	.word 0xBAE0
	.word 0xAE00
	.word 0x8000
	.word 0xBA80
	.word 0xBB80
	.word 0xAA00
	.word 0xA000
	.word 0xEEE8
	.word 0xEB80
	.word 0xAE80
	.word 0xEE00
	.word 0xB800
	.word 0xEEE0
	.word 0xBBA0
	.word 0xEBB8
	.word 0xBA00
	.word 0xA800
	.word 0xE000
	.word 0xEA00
	.word 0xEA80
	.word 0xEE80
	.word 0xEAE0
	.word 0xEEB8
	.word 0xAEE0



# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl	main
main:
	# Put your initializations here
	#li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	lui s1, 0x7ff60
	li s2, 0x01				# assigns s2 with the value 1 to be used to turn the LED on
	la s3, InputLUT				# assigns s3 with the InputLUT base address
	la s4, MorseLUT				# assigns s4 with the MorseLUT base address

	li t3, 6250000

	sw zero, 0(s1)				# Turn the LED off
		
    ResetLUT:
		mv s5, s3				# assigns s5 to the address of the first byte  in the InputLUT (WHY DO WE NEED THIS)

	NextChar:
		lbu a0, 0(s5)				# loads one byte from the InputLUT
		addi s5, s5, 1				# increases the index for the InputLUT (For future loads)
		bne a0, zero, ProcessChar	# if char is not NULL, jumps to ProcessChar
		# If we reached the end of the 5 letters, we start again
		li a0, 4 					# delay 4 extra spaces (7 total) between words to terminate
		jal DELAY				
		j ResetLUT					# start again

	ProcessChar:
		jal CHAR2MORSE				# convert ASCII to Morse pattern in a0	

	RemoveZeros:
		# Write your code here to remove trailling zeroes until you reach a one
		addi a2, a0, 0
		li t4, 1

		loop:
		srli a2, a2,1
		andi a3, a2,1
		beq a3, t4,exit
		
		j loop

		exit:
	
		
	Shift_and_display:
		# Write your code here to peel off one bit at a time and turn the light on or off as necessary
		andi a3, a2,1  			#and the flipped binary withone to find the least significant digit
		
		bne a3, zero, TURN_ON
		beq a3,zero, TURN_OFF
		
		TURN_ON:
		jal LED_ON
		li a0, 1
		jal DELAY
		j SHIFT

		TURN_OFF:
		jal LED_OFF
		li a0, 1
		jal DELAY
		j SHIFT

		
		SHIFT:
		srli a2,a2,1
		

		bne a2, zero, Shift_and_display
		jal LED_OFF
		li a0, 3
		jal DELAY
		
		j NextChar
		
		
# End of main function		

		







# Subroutines
LED_OFF:
	# Insert your code here to turn LED off
	
	sw zero, 0(s1)				# turns LEDs off 
	
	jr ra
	
	
LED_ON:
	# Insert your code here to turn LED on
	sw s2, 0(s1)				#turns the LED on by seting the value in the base address of S1 to 01
	jr ra


DELAY:
	# Insert your code here to make a delay of a0 * 500ms
	 OUTER_LOOP:
		addi t6, t3, 0
		addi a0, a0, -1
		
		INNER_LOOP:
			addi t6, t6, -1
			bne t6, zero,INNER_LOOP

	bne a0, zero, OUTER_LOOP
			
	jr ra


CHAR2MORSE:
	# Insert your code here to convert the ASCII code to an index and lookup the Morse pattern in the Lookup Table

	addi a0, a0, -0x41  #subtract ACII A from character
	li t5, 4

	mul a0,a0, t5     # multiply the offset by 4 ( for hexadecimal)
	add a0, a0, s4   # add offset to base address of MorseLUT
	lw a0, 0(a0)	  #load morse value


	jr ra

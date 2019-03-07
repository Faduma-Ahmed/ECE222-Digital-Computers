##################################################
## Name: Lab1_Template.s ##
## Purpose: A Template for flashing LED ##
## Author: Mahmoud A. Elmohr ##
##################################################
# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl main
main:
	lui s1, 0x7ff60   #set the based address of  in x11
	addi s2,zero,0x01  #storing the value of s2 in the led address depending
	sw s2, 0(s1)  		#turns the LED on by seting the value in the base address of S1 to 01

 	# an infinite loop, almost needed in any embedded systems code

	while_1:
	lui s3, 0x800			# sets the counter max

	delay:
   	addi s3, s3, -1
        bne x0, s3, delay
 
   	xori s2,s2,1   		#toggle LED control- assume lsb is LED control bit
        sw s2, 0(s1)			#stores new value back in base address LED			

        j while_1 			# j loop1 - return to main-loop 
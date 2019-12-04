


/******************************************************************************
* File: part2.s
* Author: Sanjana Jammi
* Roll number: CS18M522
* TA: G S Nitesh Narayana
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

/*
  Assignment 6 
  PART 2 - Find the position of an element in a sorted array using minimum number of memory accesses

  Algorithm used - Binary search algorithm to effectively find the element in a sorted array. Complexity is O(log(n))
  Input- Length of array and array elements (sorted)
  Output - Position of element in array if found (-1 otherwise)
  */

  @ BSS section
      .bss


.data

.equ SWI_PrStr, 0x69 ; @Write a string to file handle
.equ SWI_RdInt, 0x6c ; @Read an integer from file handle
.equ SWI_PrInt, 0x6b ; @Write an integer to file handle
.equ SWI_Exit, 0x11 @ Stop execution

InFileHandle: .word 0x00;
OutFileHandle: .word 0x01;
number_prompt:   .asciz "Enter a number to search and press enter-\n"
arraylen_prompt:   .asciz "Enter array length (max 100) and press enter-\n"
array_prompt:   .asciz "Enter array elements(sorted) separated by newlines-\n"
result_message: .asciz "The number's position in the array is- \n"

.align
array: .word 0x00;

.skip 400 @ Skipping 400 bytes to account for array elements (max 100 possible)

.align
Output: .word 0x00;

.text
.global main

main:

			LDR R1, =OutFileHandle;         @Printing message to enter array length to stdout
			LDR R0, [R1];
	        LDR R1, =arraylen_prompt;	        
	        SWI SWI_PrStr;
	        LDR R0, =InFileHandle;			@Reading array length input from stdin
	        LDR R0, [R0];
	        SWI SWI_RdInt;
	        MOV R2, R0; 					@Storing array length in R2

			LDR R1, =OutFileHandle;			@Printing message to enter array elements to stdout
			LDR R0, [R1];
	        LDR R1, =array_prompt;
	        SWI SWI_PrStr;
	        
			MOV R3, R2;						@Using R3 as a loop counter to read all array elements
			LDR R1, =array;					@Reading array elements one by one
Loop:   	LDR R0, =InFileHandle;
	        LDR R0, [R0];
			SWI SWI_RdInt;
			STR R0, [R1];					@Storing the array elements read into memory
			ADD R1, R1, #4;
			SUBS R3, R3, #1;				@Decrement the loop counter
			BNE Loop;						@Repeat until all elements (equal to array length) are read

			LDR R1, =OutFileHandle;			@Printing message to enter number to be searched to stdout
			LDR R0, [R1];
	        LDR R1, =number_prompt;
	        SWI SWI_PrStr;
	        LDR R0, =InFileHandle;			@Reading number to be searched input from stdin
	        LDR R0, [R0];
			SWI SWI_RdInt;
	        MOV R4, R0;  					@Storing number to be searched in R4

	        LDR R3, =array;					@Register R3 points to the starting memory location of the array

	        BL SEARCH;						@Call subroutine SEARCH
	        LDR R1, =Output;
	        STR R0, [R1];
	        MOV R2, R0;						@Register R2 has the output

	        LDR R1, =OutFileHandle;			@Printing result to stdout
	        LDR R0, [R1];
	        LDR R1, =result_message;                     
	        SWI SWI_PrStr;
	        LDR R1, =OutFileHandle;
	        LDR R0, [R1];
	        MOV R1, R2;                                   
	        SWI SWI_PrInt;
  			SWI SWI_Exit;					@Stop the program

SEARCH: @Subroutine to find the position of element in array(array length and number passed as registers and array elements passed as memory block to subroutine)
          	STMFD SP!, {R1, R5-R8, LR};
          	EOR R5, R5, R5;					@Register R5 holds the min index of the effective array to be searched
          	MOV R6, R2; 					@Register R6 holds the max index of the effective array to be searched
			SUB R6, R6, #1;					@Subtracting 1 from max index as array indices start from 0
          	MOV R7, #4;         			
LOOP:		SUBS R8, R6, R5;				@Calculating the mid index of the effective array by (max - min)/2+ min
          	BEQ Skip;						@If min = max, skip the division step
          	BLT Not_Found;					@If min < max, it indicates that the number is not found, so branch to Not_Found

			MOV R8, R8, LSR #1; 			@Shift right by 1 position to divide by 2 -> (max - min)/2
			ADD R1, R8, R5;					@Add to min -> (max - min)/2+ min

Skip:		MOV R0, R1;						@R1 holds the mid index
			ADD R0, R0, #1; 				@Register R0 holds the resultant position, Add 1 to the array index to get the position(as position starts from 1)
			MUL R8, R7, R1;					@Get the array element at that position by adding 4*(index) to the base address of the array
			ADD R8, R3, R8;
			LDR R8, [R8];					@Load the array element at mid index
            	
			CMP R4, R8;						@Compare element to be searched with this mid element
			BEQ DONE;						@If equal, branch to DONE
			BLT LESS;						@If number is lesser than mid element, look in the first half of the array
			BGT GREATER;					@If number is greater than mid element, look in the second half of the array

LESS:            
			SUB R1, R1, #1;					@The effective max index of the new array formed using the first half is mid index -1
			MOV R6, R1;
			B LOOP;

GREATER:            
			ADD R1, R1, #1;					@The effective min index of the new array formed using the second half is mid index + 1
			MOV R5, R1;            
			B LOOP;
			
Not_Found:	MOV R0, #-1; 			        @If not found, store -1                   
                       
DONE:		LDMFD SP!, {R1, R5-R8, PC}      @Return to main program by restoring registers

			




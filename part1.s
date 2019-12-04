


/******************************************************************************
* File: part1.s
* Author: Sanjana Jammi
* Roll number: CS18M522
* TA: G S Nitesh Narayana
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

/*
  Assignment 6 
  PART 1 - Find the position of an element in an unsorted array

  Algorithm used - Linear search through all array elements. Complexity is O(n)
  Input- Length of array and array elements (unsorted)
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
array_prompt:   .asciz "Enter array elements separated by newlines-\n"
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
            LDR R0, =InFileHandle;          @Reading array length input from stdin
            LDR R0, [R0];
            SWI SWI_RdInt;
            MOV R2, R0;                     @Storing array length in R2

            LDR R1, =OutFileHandle;         @Printing message to enter array elements to stdout
            LDR R0, [R1];
            LDR R1, =array_prompt;
            SWI SWI_PrStr;
                    
            MOV R3, R2;                     @Using R3 as a loop counter to read all array elements
            LDR R1, =array;                 @Reading array elements one by one
Loop:       LDR R0, =InFileHandle;
            LDR R0, [R0];
            SWI SWI_RdInt;
            STR R0, [R1];                   @Storing the array elements read into memory
            ADD R1, R1, #4;
            SUBS R3, R3, #1;                @Decrement the loop counter
            BNE Loop;                       @Repeat until all elements (equal to array length) are read

            LDR R1, =OutFileHandle;         @Printing message to enter number to be searched to stdout
            LDR R0, [R1];
            LDR R1, =number_prompt;
            SWI SWI_PrStr;
            LDR R0, =InFileHandle;          @Reading number to be searched input from stdin
            LDR R0, [R0];
            SWI SWI_RdInt;
            MOV R4, R0;                     @Storing number to be searched in R4

            LDR R3, =array;                 @Register R3 points to the starting memory location of the array

            BL SEARCH;                      @Call subroutine SEARCH
            LDR R1, =Output;
            STR R0, [R1];
            MOV R2, R0;                     @Register R2 has the output

            LDR R1, =OutFileHandle;         @Printing result to stdout
            LDR R0, [R1];
            LDR R1, =result_message;                     
            SWI SWI_PrStr;
            LDR R1, =OutFileHandle;
            LDR R0, [R1];
            MOV R1, R2;                                   
            SWI SWI_PrInt;
            SWI SWI_Exit;                   @Stop the program


SEARCH: @Subroutine to find the position of element in array(array length and number passed as registers and array elements passed as memory block to subroutine)
            STMFD SP!, {R5, LR};
            EOR R0, R0, R0;
LOOP:       LDR R5, [R3], #4;               @Looping through all the elements and comparing each one with the number to be searched
            ADD R0, R0, #1                  @R0 holds the resultant position
            CMP R5, R4;                     @If element found, branch to done
            BEQ DONE;
            SUBS R2, R2, #1;                @Using array length as a loop counter
            BNE LOOP;
            MOV R0, #-1;                    @If all array elements are traversed and number not found, store -1
DONE:       LDMFD SP!, {R5, PC}             @Return to main program



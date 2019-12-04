


/******************************************************************************
* File: part3.s
* Author: Sanjana Jammi
* Roll number: CS18M522
* TA: G S Nitesh Narayana
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

/*
  Assignment 6 
  PART 3 - Print the Nth fibonacci number in the sequence given a number N
  Algorithm used -> Calculating fiboncacci sequence by recursion using stack
  Fibonacci(n) = Fibonacci(n-1) + Fibonacci(n-2)
  Popping the first two values which are results of the previous iterations, summing them up and pushing the results to the stack

  Input - Number N
  Output - Nth number in the Fibonacci sequence 
  */

  @ BSS section
      .bss

  
  @ DATA SECTION
  .data
  .equ SWI_PrStr, 0x69 ; @Write a string to file handle
  .equ SWI_RdInt, 0x6c ; @Read an integer from file handle
  .equ SWI_PrInt, 0x6b ; @Write an integer to file handle
  .equ SWI_Exit, 0x11    @Stop execution

  InFileHandle: .word 0x00;
  OutFileHandle: .word 0x01;
  number_prompt:   .asciz "Enter a number N to display fibonacci sequence result-\n"
  result_message: .asciz "The Nth fibonacci number in the series is- \n"

  NUM: .word 0x00;
  .skip 4               @Skip 4 bytes to store the number N entered

  .align
  Output: .word 0x00    @Output Nth fibonacci number
    
  @ TEXT section
      .text

.globl _main


_main:
        LDR R1, =OutFileHandle;           @Printing message to enter number N
        LDR R0, [R1];
        LDR R1, =number_prompt;         
        SWI SWI_PrStr;

        LDR R0, =InFileHandle;            @Reading number N input from stdin
        LDR R0, [R0];
        SWI SWI_RdInt;  
              
        SUB R0, R0, #2;                   @Subtracting 2 to account for the initial numbers 1,1 in the sequence
        MOV R4, R0;                       @Storing the effective length of fibonacci sequence in R4
        MOV R1, #1;        
        PUSH {R1};                        @Pushing the initial elements in the sequence 1,1 to stack
        PUSH {R1};
        BL FIBONACCI;                     @Calling the Fibonacci subroutine to calculate the Nth number in the sequence
        LDR R1, =Output;                  
        STR R0, [R1];
        MOV R2, R0;                       @Storing the result obtained in R2

        LDR R1, =OutFileHandle;           @Printing result to stdout
        LDR R0, [R1];
        LDR R1, =result_message;
        SWI SWI_PrStr;
        LDR R1, =OutFileHandle;
        LDR R0, [R1];
        MOV R1, R2;                                   
        SWI SWI_PrInt;
        SWI SWI_Exit;                     @Stop the program
        

FIBONACCI:   @Subroutine to find the Nth fibonacci number in sequence(number passed through register), implementation using stack
        POP {R2};                         @Pop top 2 elements from stack which are effectively Fibonacci(n-1) and Fibonacci(n-2)
        POP {R1};                         
        PUSH {LR};                        @Push the Link register content to keep track of the return address from the subroutine
        ADD R3, R1, R2;                   @Add the results of the previous 2 iterations - Fibonacci(n-1) + Fibonacci(n-2)
        PUSH {R2};                        @Pushing Fibonacci(n-1) to stack
        PUSH {R3};                        @Push the result computed in the current iteration - Fibonacci(n) to the stack
            
        SUBS R0, R0, #1;                  @Decrement the loop counter R0 to perform this sequence of operations N times
        BNE F_CONT;                       @Branch to F_CONT if not complete
        B DONE;                           @Branch to DONE if complete

F_CONT:         
        BL FIBONACCI;                     @Recursively call the subroutine Fibonacci

DONE:                
        POP {R0};                         @Pop the first element from the stack which is the result of the latest computation -> required result
        MOV R5, #4;                       @As each LR address is stored on stack, perform these steps to calculate return address to the main program
        MUL R4, R4, R5;                   @Increment the Stack pointer by (no. of times the Fibonacci sequence ran)*4 bytes to point it to the return address to main
        ADD SP, SP, R4;
        POP {PC};                         @Pop the result to PC, return
        .end
            
          

                    
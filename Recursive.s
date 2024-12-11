W_CAPACITY  EQU     50                       ; W_CAPACITY = 50
SIZE        EQU     3                        ; SIZE = 3
; Data area for arrays
            AREA data_area, DATA, READWRITE  
dp_start
dp          SPACE   W_CAPACITY * 4           ; Allocating 200 bytes for dp array 
            AREA example, CODE, READONLY     ; Declaring code area for read-only instructions
            ENTRY                            ; Defining the entry point of the program
            ALIGN                            ; 
__main      FUNCTION                         ; Define main function
            EXPORT __main                    ; Export main as an entry point of assembly code
            LDR R1, =profit                  ; Loading the address of the profit array into R1
            LDR R2, =weight                  ; Loading the address of the weight array into R2
            LDR R3, =dp                      ; Loading the address of the dp array into R3
            LDR R4, =W_CAPACITY              ; Loading the W_CAPACITY value into R4 (W)
            LDR R5, =SIZE                    ; Loading the SIZE value into R5 (n)
			MOVS R6, #0						 ; R6 = 0
			MOVS R7, #0						 ; R7 = 0
			PUSH{R1-R3}						 ; Pushing the addresses of profit, weight, and dp arrays onto the stack to preserve their current value 
			BL knapsack						 ; Branching to knapsack label
			POP {R1-R3}						 ; Restoring the previously saved values of R1, R2, and R3 from the stack.
			
stop 		
			B stop							 ; After completing main, it is needed for stopping code execution.
				
knapsack	PUSH {R4-R7, LR}				 ; Similar to the purpose of pushing the R1-R3 values to the stack, pushed them to the stack so that 
											 ; we don't lose the current values when the current knapsack function calls other knapsack functions.
			
			; if (n==0 || W==0)
			CMP R4, #0						 ; Check if(w == 0)
			BEQ returnZero					 ; Branch if W equal to {zero} to returnZero
			CMP R5, #0						 ; check if(SIZE(n) == 0)
			BEQ returnZero					 ; Branch if n equal to {zero} to returnZero
			SUBS R6, R5, #1 				 ; R6 = n - 1,  R5-1
			LSLS R7,R6, #2					 ; R7 = 4*R6 or [n-1] as an array index
			LDR	R0,[R2, R7]					 ; R0 = weight[n-1]
			
			; if (weight[n-1] > W)
			CMP R0, R4						 ; if(weight[n-1] > W)
			BGT knapsackWithReducedN		 ; Branch if greater than to knapsackWithReducedN
			
			; else 
			PUSH {R0, R4, R6}				 ; Before diving into new knapsack function, storing weight[n-1], W, n-1 in the top of the stack
			MOVS R5, R6						 ; R5 = n-1
			BL knapsack						 ; Branching to knapsack function with saving return address to Link Register
			MOVS R7, R0						 ; R7 = weight[n-1]
			POP{R0, R4, R6}                  ; Restoring original values from before diving into recursively called function. R0 = weight[n-1], R4 = W, R6 = n-1
			SUBS R4, R0						 ; R4 = W - weight[n-1]
			MOVS R5, R6						 ; R5 = n-1
			BL knapsack						 ; Branching to knapsack function with saving return address to Link Register
											 ; We will get the result of knapsack from R0 which will be equal to knapsack(W - weight[n-1] , n-1)
			LSLS R6, R6, #2					 ; R6 = 4*R6 or [R6] as an array index
			LDR R6, [R1, R6]				 ; R6 = profit[n-1]
			ADDS R0, R0, R6					 ; R0 = knapsack(W - weight[n-1] , n-1) + profit[n-1]
			CMP R0, R7						 ; Finding new max value for update to max value
			BLE updateMax					 ; If R0<=R7 , R7 should become the new max value, so branching to updateMax
			B return						 ; Branch directly to return label
			
knapsackWithReducedN
			MOVS R5, R6						 ; R5 = n-1
			BL knapsack						 ; knapsack(W, n-1), calling knapsack function recursively with the reduced n. knapsack(W, n-1)
			B return						 ; Branch directly to return label
			
updateMax 
			MOVS R0, R7						 ; R0 = R7, 
			B return						 ; Branch directly to return label
			
returnZero
			MOVS R0, #0						 ; R0 = 0
			
return 
			POP {R4-R7, PC}					 ; Restore saved original values from stack to registers R4-R7 and saves previously saved Link Register to Program Counter. 
											 ; By doing this function returns to the saved address in the callers code where the function was initially called.
			
profit      DCD     60, 100, 120             ; Array of profit values
weight      DCD     10, 20, 30               ; Array of weight values
	
			ENDFUNC                           ; Finishing function
			END                               ; End of the program
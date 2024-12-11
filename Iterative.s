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
            MOVS R6, #1                      ; Initialize i (outer loop counter) to 1

outerLoop 
            PUSH {R6}                        ; save outer loop counter to stack. Because in the inner loop, we will use (i-1) and it may result to losing original value of R6.
            LDR R4, =W_CAPACITY              ; R4 = 50, I reset w to W_CAPACITY for each outer loop iteration because each inner loop starts from 50
            CMP R6, R5                       ; Compare i with n (SIZE)
            BLE innerLoop                    ; If i <= SIZE (it is the same as i < SIZE +1), branch to innerLoop
            B exitOuter                      ; If i > SIZE, branch to exitOuter

innerLoop
            CMP R4, #0                       ; Check if w >= 0
            BLT exitInner                    ; If w < 0, branch to exitInner
            SUBS R6, #1                      ; R6 = i - 1
            LSLS R6, #2                      ; R6 = 4*(i - 1) or [i-1] as an array index
            LDR R7, [R2, R6]                 ; R7 = weight[i-1]
            ; if( weight[i-1] <= w )
            CMP R4, R7                       ; Check if w >= weight[i-1]
            BLT exitInner                    ; If w < weight[i-1], branch to exitInner
            LSLS R4, #2                      ; R4 = 4*w or [w] as an array index
            LDR R3, [R3, R4]                 ; R3 = dp[w]
            LDR R1, [R1, R6]                 ; R1 = profit[i-1] 
            LSRS R4, #2                      ; R4 = w 
            SUBS R0, R4, R7                  ; R0 = w - weight[i-1] 
            LSLS R0, #2                      ; R0 = 4*(w - weight[i-1]) or [w - weight[i-1]] as an array index
            LDR R2, =dp                      ; Loading the address of the dp array into R2
            LDR R0 , [R2, R0]                ; R0 = dp[w - weight[i-1]] 
            ADDS R0, R1                      ; R0 = dp[w - weight[i-1]] + profit[i-1]
            LSRS R6, #2                      ; R6 = i-1
            ADDS R6, #1                      ; R6 = i 
            CMP R3, R0                       ; Comparing dp[w] and dp[w - weight[i-1]] + profit[i-1] to find which one is max 
            BLT update                       ; If dp[w] < dp[w - weight[i-1]] + profit[i-1], branch to update label to assign dp[w] = dp[w - weight[i-1]] + profit[i-1]
            B skipInner                      ; Otherwise, dp[w] remain its own value and branch to skipInner

skipInner 
            LDR R1, =profit                  ; Reload address of the profit array into R1
            LDR R2, =weight                  ; Reload address of the weight array into R2
            LDR R3, =dp                      ; Reload address of the dp array into R3
            SUBS R4, #1                      ; w = w-1
            B innerLoop                      ; Branch to innerLoop

update
            LDR R1, =profit                  ; Reload address of the profit array into R1
            LDR R2, =weight                  ; Reload address of the weight array into R2
            LDR R3, =dp                      ; Reload address of the dp array into R3
            LSLS R4, R4, #2                  ; R4 = 4*w or [w] as an array index
            STR R0, [R3 , R4]                ; dp[w] = dp[w - weight[i-1]] + profit[i-1]
            LSRS R4, R4, #2                  ; R4 = w 
            B skipInner                      ; Branch to skipInner directly to continue the loop

exitInner 
            POP {R6}                         ; Restoring the previous value of R6 from the stack
            ADDS R6, #1                      ; R6 = R6 +1 , i = i+1
            B outerLoop                      ; Branch to outerLoop directly

exitOuter 
            LDR R1, =profit                  ; Reload address of the profit array into R1
            LDR R2, =weight                  ; Reload address of the weight array into R2
            LDR R3, =dp                      ; Reload address of the dp array into R3
            LDR R4, =W_CAPACITY              ; Load W_CAPACITY into R4
            LSLS R4, R4, #2                  ; R4 = W_CAPACTIY * 4 or [W_CAPACITY] as an array index
            LDR R0, [R3, R4]                 ; R0 = dp[W_CAPACITY] 
            LSRS R4, R4, #2                  ; R4 = W

stop
            B stop                           ; Stop execution

profit      DCD     60, 100, 120             ; Array of profit values
weight      DCD     10, 20, 30               ; Array of weight values

           ENDFUNC                           ; Finishing function
           END                               ; End of the program




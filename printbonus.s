## CSE1400: Computer Organisation
## Lab assignment 4b:   Printf
## Wouter Buthker	    wbuthker
## Daniel de Weerd 	    ddeweerd
 
.data
 
string_to_print: .asciz "testssdfas\n"
loc:        
.equ            length, loc - string_to_print      # Load length of string in length variable
buffer:         .skip   256 
eerstenaam:     .asciz  "Daniel"                   # Declare variables used for testing
tweedenaam:     .asciz  "Frank"
derdenaam:      .asciz  "Piter"
achternaam:     .asciz  "de Weerd"
test:           .asciz  "Test"
.global main
 
main:
    push    %rbp                                    # Stack frame
    movq    %rsp, %rbp

    movq    $string_to_print, %rdi                  # Pass parameters to my_printf according to pROpeR cONvEnTIonS
    movq    $eerstenaam, %rsi
    movq    $tweedenaam, %rdx
    movq    $derdenaam, %rcx
    movq    $achternaam, %r8
    movq    $20, %r9
    movq    $3, %r10                                # amount of extra variables on stack
    
    pushq   $1999
    pushq   $-1
    pushq   $3
    call    my_printf                               # Call my_printf

    movq    %rbp, %rsp                                      
    pop     %rbp                                    # Close stack frame
    ret
end:
    movq    $0, %rdi
    call    exit

my_printf:                              # Parameters:
    push    %rbp                        # Stack frame
    movq    %rsp, %rbp
    movq    $16, %r13                   # R13 used 
    movq    $0, %r14                    # R14 used to count added characters 
    movq    %rbp, %rbx                  # Rbx used to calculate stack value
    addq    $16, %rbx                   # default ofset
    
    repeat_push:                        # push extra stack variables
    pushq   (%rbx)
    decq    %r10
    addq    $8, %rbx
    cmpq    $0, %r10
    jg     repeat_push
 
    pushq   %r9                         # Push all arguments to the stack
    pushq   %r8
    pushq   %rcx
    pushq   %rdx
    pushq   %rsi

    call    stringl                     # Get length of format str, store it in RCX and RDX
    movq    %rax, %rcx
    movq    %rax, %rdx

    addq    $666, %rcx
    decq    %rdi

    next_ampersand:
    movq    $0, %rax                    #  Clear RAX
    movq    $'%', %rax                  
   
    repne   scasb                       ## bit-by-bit comparison, moves rdi to location of %
                                        ## decrements rcx
                                        ## increments rdi
    cmpb    $'u', (%rdi)
    je      formatstr_u                 ## jump to correct sub
    cmpb    $'d', (%rdi)
    je      formatstr_d
    cmpb    $'%', (%rdi)
    je      formatstr_a
    cmpb    $'s', (%rdi)
    je      formatstr_s
 
    subq    $666, %rcx
    subq    %rcx, %rdx                   ## Calc amt of spaces needed to go back
    subq    %rdx, %rdi                   ## Go back the calculated amt of spaces
    decq    %rdi
    call    print
   
    movq    %rbp, %rsp
    pop     %rbp
    ret
print:
    push    %rbp
    movq    %rsp, %rbp

    movq    $1, %rax
    movq    %rdi, %rsi
    movq    $1, %rdi
    movq    $length, %rdx
    addq    %r14, %rdx                  ## add number of added characters
    syscall
   
    movq    %rbp, %rsp
    pop     %rbp
    ret
 
formatstr_u:
    pop     %rsi
    u_positive:
    decq    %rdi                        ## go to place of %
    movb    $0, (%rdi)                  ## remove %
 
    call    num_to_string
    jmp     next_ampersand
 
formatstr_d:
    pop     %rsi
    cmpq    $0, %rsi                    ## if param is positive
    jge     u_positive                  ## do unsigned printing
 
    decq    %rdi                        ## go to place of %
    movb    $0, (%rdi)                  ## remove %
   
    imul    $-1, %rsi                   ## make rsi positive
   
    call    num_to_string               ## add number to string
    subq    %r15, %rdi                  ## move to position of first num
    movb    $'-', (%rdi)                ## add -
    addq    %r15, %rdi                  ## go back to last number
    jmp     next_ampersand
 
formatstr_a:
    movb    $0, (%rdi)                  ## remove first %

    jmp     next_ampersand
 
formatstr_s:
    movb    $0, (%rdi)                  # Remove 's' from format string
    decq    %rdi                        # Move pointer to '%' sign
    movb    $0, (%rdi)                  # Remove '%' from format string
    pop     %rsi                        # Get parameter

    pushq   %rdi                        # Save all registers relevant to scasb to stack
    pushq   %rsi
    pushq   %rdx
    pushq   %rcx

    movq    %rsi, %rdi                  # Get length of the inserted string and move it to R15
    call    stringl
    movq    %rax, %r15
    addq    %rax, %r14

    popq    %rcx                        # Load all values relevant to scasb
    popq    %rdx
    popq    %rsi
    popq    %rdi

    call    extend_string               # Make space in string for characters

    movq    $0, %r8                     # Counter

    insert:
    movq    $0, %rax                    # Clear RAX
    movb    (%rsi), %al                 # Move byte from inserted string to AL
    movb    %al, (%r8,%rdi)             # Move byte from AL to format string, offset by counter
    incq    %rsi                        # Move to next byte in inserted string
    incq    %r8                         # Increment counter
    cmpb    $0, (%rsi)                  # End loop when end of inserted string reached
    jne     insert 
 
    jmp     next_ampersand              ## scan for next %
 
num_to_string:
    push    %rbp                        ##  stack frame
    movq    %rsp, %rbp
 
    movq    %rdx, %r12                  ## save rdx (string length)
    movq    %rsi, %rax                  ## number to rax
    movq    $0, %r9                     ## i = 0
    movq    $10, %r13                   ## devide by 10
 
    loop:
    movq    $0, %rdx                    ## clear rdx for devision
    idivq   %r13                        ## devide number by 10
    push    %rdx                        ## push character to the stack
    incq    %r9                         ## i++
    incq    %r12                        ## increment string length
    cmp     $1, %rax                    ## check if the devisor is not 0
    jge     loop                        ## repeat
 
    movq    %r9, %r15                   ## save number of added characters
    addq    %r15, %r14
    call    extend_string               ## extend string by r15

    create_string:
    incq    %rdi                        ## go to an empty place
    pop     %rsi                        ## pop a character
    addb    $48, %sil
    movb    %sil, (%rdi)
 
    dec     %r9
    cmp     $1, %r9
    jge     create_string
 
    movq    %r12, %rdx                  ## move original rdx back
    decq    %rdx
 
    movq    %rbp, %rsp
    pop     %rbp
    ret
 
extend_string:
    pushq   %rbp                        ## stack frame
    movq    %rsp, %rbp
    movq    $0, %r8                     ## int i = 0
    push    %rdi                        ## save rdi
   
    copy_to_stack:
    incq    %r8                         ## i++
    incq    %rdi                        ## go to next character
    push    (%rdi)                      ## save character to stack
   
    cmp     $0, (%rdi)                  ## check if end of string is reached
    jne     copy_to_stack               ## repeat
 
    addq    %r15, %rdi                  ## number of characters to add
    decq    %rdi                        ## align
 
    paste_from_stack:
    pop     (%rdi)                      ## pop character to new position in string
    decq    %rdi                        ## go to next position in string
    decq    %r8                         ## i--
 
    cmp     $0, %r8                     ## while (i<0)
    jg      paste_from_stack            ## repeat
 
    pop     %rdi                        ## pop back old string pointer
    movq    %rbp, %rsp
    pop     %rbp
    ret
stringl:
    pushq   %rbp                        ## stack frame
    movq    %rsp, %rbp                  ## Returns string length
    movq    $420, %rcx
    movq    $0, %rax
    repne   scasb

    movq    $419, %rax
    subq    %rcx, %rax
    subq    %rax, %rdi


    movq    %rbp, %rsp
    pop     %rbp
    ret

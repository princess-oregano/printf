        section .data



        section .text
        global print

; -----------------------------------------------
; DESCRIPTION   | General print() function.
; -----------------------------------------------
; ENTRY         | RDI - pointer to format line
;               | RSI - first arg
;               | RDX - second arg
;               | RCX - third arg
;               | R8 - foutrh arg
;               | R9 - fifth arg
;               | [IN STACK] sixth, seventh, etc. arg
; -----------------------------------------------
; RETURN        | RAX - number of chars written
; -----------------------------------------------
; DESTROYS      | R15 - counts number of chars
;               | R14 - counts args
; -----------------------------------------------
print:
        xor r14, r14            ; R14 = 0
        xor r15, r15            ; R15 = 0
.next:
        cmp byte [rdi], '%'     ; Compare char with '%'.
        jne .symb               ; If ch!= '%', then putchar(ch).

        cmp byte [rdi+1], '%'   ; If '%%' RDI++, so the output is '%',
        jne .print_arg          ; else print argument.

        inc rdi
        jmp .symb

.print_arg:
        inc rdi                 ; Now [RDI] - symbol of arg type.
        call arg                ; Print argument.
        inc rdi                 ; Proceed to next symbol.
        inc r14                 ; arg_counter++

.symb:
        push r15                ; Save registers.
        push rdi
        call print_sym          ; Print next symbol in line.
        pop rdi
        pop r15

        inc rdi                 ; Move to next symbol.
        inc r15                 ; char_counter++

        cmp byte [rdi], 0       ; If not null-terminating byte,
        jne .next               ; then continue.

        mov rax, r15            ; Move return value to RAX.

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints ASCII symbol(char).
; -----------------------------------------------
; ENTRY         | RDI - Pointer to char
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | RAX, RDI, RSI, RDX - for syscall
; -----------------------------------------------
print_sym:
        mov rax, 1
        mov rsi, rdi
        mov rdi, 1
        mov rdx, 1

        syscall

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints argument, according to format line.
; -----------------------------------------------
; ENTRY         | R14 - number of current arg
;               | RDI - pointer to describing char
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | 
; -----------------------------------------------
arg:
        ret

; -----------------------------------------------
; DESCRIPTION   | Pushes next arg to stack or does nothing.
; -----------------------------------------------
; ENTRY         | R14 - number of current arg
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | RAX - contains jump-value
; -----------------------------------------------
push_arg:
        mov rax, [.ARG_TABLE + r14 * 8]
        jmp rax
         
.arg_table:
        .quad   .arg_rsi
        .quad   .arg_rdx
        .quad   .arg_rcx
        .quad   .arg_r8
        .quad   .arg_r9
        .quad   .arg_stk

.arg_rsi:
        push rsi
        jmp .ret

.arg_rdx:
        push rdx
        jmp .ret

.arg_rcx:
        push rcx
        jmp .ret

.arg_r8:
        push r8
        jmp .ret

.arg_r9:
        push r9
        jmp .ret

.arg_stk:

.ret:
        ret


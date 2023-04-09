        section .data

line:   db "$"

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
; RETURN        | Number of chars written.
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
        push rdi
        call arg                ; Print argument.
        pop rdi
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
; DESTROYS      | RAX - contains argument
; -----------------------------------------------
arg:    
        call push_arg           ; Push next argument to stack.

        pop rax                 ; Pop argument to RAX.
        call print_hex

        ret

; -----------------------------------------------
; DESCRIPTION   | Pushes next arg on top of stack.
; -----------------------------------------------
; ENTRY         | R14 - number of current arg
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | RAX - contains jump-value
;               | RBX - contains return address
; -----------------------------------------------
push_arg:
        pop rbx                 ; Save return address.

        cmp r14, 6
        jge .arg_stk
        mov rax, [.arg_table + r14 * 8]
        jmp rax
         
.arg_table:
        dq     .arg_rsi
        dq     .arg_rdx
        dq     .arg_rcx
        dq     .arg_r8
        dq     .arg_r9
        dq     .arg_stk

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
        pop rcx                 ; [IN STACK] ret_val of push_arg, arg, THEN value
        pop rsi
        pop r8
        pop r9                  ; Value.
        push r8
        push rsi
        push rcx
        push r9

.ret:
        push rbx                ; Push return address.

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints decimal number.
; -----------------------------------------------
; ENTRY         | RAX - number to print
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | RAX, RSI, RDI, RDX
; -----------------------------------------------
print_hex:
        push rax 
        push rsi 
        push rdi 
        push rdx

        mov rax, 1
        lea rsi, line
        mov rdi, 1
        mov rdx, 1

        syscall

        pop rdx 
        pop rdi 
        pop rsi 
        pop rax

        ret

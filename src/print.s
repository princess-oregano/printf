        section .data



        section .text
        global print

; -----------------------------------------------
; DESCRIPTION   | General print() function.
; -----------------------------------------------
; ENTRY         | RDI - pointer to format line
; -----------------------------------------------
; RETURN        | RAX - number of chars written
; -----------------------------------------------
; DESTROYS      | RCX - counts number of chars
; -----------------------------------------------
print:         
        xor rcx, rcx            ; RCX = 0
next:
        push rdi                ; Save registers.
        push rcx
        call print_sym          ; Print next symbol in line.
        pop rcx
        pop rdi

        inc rdi                 ; Move to next symbol.
        inc rcx                 ; char_counter++

        cmp byte [rdi], 0       ; If not null-terminating byte, 
        jne next                ; then continue.

        mov rax, rcx            ; Move return value to RAX.
        ret

; -----------------------------------------------
; DESCRIPTION   | Prints ASCII symbol(char).
; -----------------------------------------------
; ENTRY         | [IN STACK] 1: Pointer to char
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | RAX, RDI, RSI, RDX - for syscall
; -----------------------------------------------
print_sym:
        mov rax, 1
        mov rdi, 1
        mov rsi, [rsp + 1 * 8]
        mov rdx, 1

        syscall

        ret


        section .data



        section .text
        global print

; -----------------------------------------------
; ENTRY         | RDI - pointer to format line
; -----------------------------------------------
; RETURN        | RAX - number of chars written
; -----------------------------------------------
; DESTROYS      | RCX - counts number of chars
; -----------------------------------------------
print:         
        xor rcx, rcx
next:
        push rdi
        push rcx
        call print_sym
        pop rcx
        pop rdi

        inc rdi
        inc rcx

        cmp byte [rdi], 0
        jne next

        mov rax, rcx
        ret

print_sym:
        mov rax, 1
        mov rdi, 1
        mov rsi, [rsp + 1 * 8]
        mov rdx, 1

        syscall

        ret


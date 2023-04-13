        section .data

str:    db "Assembly debug)))", 0
fmt:    db "%s -- neud(%d)", 10, 0

;-------------------------------------------------

        section .text

        extern printf
        global main

main:
        mov edx, 10
        mov esi, str
        mov edi, fmt    
        mov eax, 0
        call printf

        mov rax, 0
        ret


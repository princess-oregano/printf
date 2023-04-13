        section .data

str:    db "Debigging))", 0
fmt:    db "%s -- otl(%d)", 10, 0

;-------------------------------------------------

        section .text

        extern print
        global main

main:
        mov rdx, 1000000
        mov esi, str
        mov edi, fmt    
        call print

        mov rax, 0
        ret


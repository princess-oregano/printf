        section .data

ERR_BUF:        db "ERROR", 0
BIN_BUF:        db "0000000000000000000000000000000000000000000000000000000000000000", 0
OCT_BUF:        db "000000000000000000000000", 0
DEC_BUF:        db "00000000000000000000", 0
HEX_BUF:        db "0000000000000000", 0

        section .text
        global print

; -----------------------------------------------
; DESCRIPTION   | Find length of line, pushes it to RCX.
; -----------------------------------------------
; ENTRY         | RDI - pointer to line
; -----------------------------------------------
; RETURN        | Number of chars.
; -----------------------------------------------
; DESTROYS      | RCX
; -----------------------------------------------
str_len:
        mov rcx, rdi

.strlen_loop:
        cmp byte [rcx], 0
        je .done
        inc rcx
        jmp .strlen_loop

.done:
        sub rcx, rdi
        ret

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
        call arg                ; Print argument.
        inc rdi                 ; Proceed to next symbol.
        inc r14                 ; arg_counter++
        jmp .next

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

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints ASCII symbol(char).
; -----------------------------------------------
; ENTRY         | RDI - Pointer to char
; -----------------------------------------------
; RETURN        | NONE
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_sym:
        push rax
        push rsi
        push rdi
        push rdx

        mov rax, 1
        mov rsi, rdi
        mov rdi, 1
        mov rdx, 1

        syscall

        pop rdx
        pop rdi
        pop rsi
        pop rax

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
;               | R11, R10
; -----------------------------------------------
arg:
        call push_arg           ; Moves next arg to rax.

        xor r11, r11
        mov r11b, byte [rdi]

        cmp r11b, 'b'
        jg .err

        cmp r11b, 'x'
        jl .err

        sub r11b, 0x62          ; r11 - 'b'

        mov r10, [.spec_table + r11 * 8]
        jmp r10

.spec_table:
        dq      .sp_b
        dq      .sp_c
        dq      .sp_d
        times ('o' - 'd' - 1) dq .err
        dq      .sp_o
        times ('s' - 'o' - 1) dq .err
        dq      .sp_s
        times ('x' - 's' - 1) dq .err
        dq      .sp_x

.err:
        lea rax, ERR_BUF
        call print_str
        jmp .ret

.sp_b:
        call print_bin
        jmp .sp_num

.sp_d:
        call print_dec
        jmp .sp_num

.sp_o:
        call print_oct
        jmp .sp_num

.sp_x:
        call print_hex
        jmp .sp_num

.sp_c:  
        call print_char
        jmp .ret

.sp_s:
        call print_str
        jmp .ret

.sp_num:
        call print_num

.ret:
        ret

; -----------------------------------------------
; DESCRIPTION   | Moves next arg to RAX.
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

        cmp r14, 5
        jge .arg_stk
        mov r15, [.arg_table + r14 * 8]
        jmp r15

.arg_table:
        dq     .arg_rsi
        dq     .arg_rdx
        dq     .arg_rcx
        dq     .arg_r8
        dq     .arg_r9

.arg_rsi:
        mov rax, rsi
        jmp .ret

.arg_rdx:
        mov rax, rdx
        jmp .ret

.arg_rcx:
        mov rax, rcx
        jmp .ret

.arg_r8:
        mov rax, r8
        jmp .ret

.arg_r9:
        mov rax, r9
        jmp .ret

.arg_stk:
        pop rcx                 ; [IN STACK] Lift value.
        pop r8
        pop rax                 ; Value.
        push rax                ; Return everything to place.
        push r8
        push rcx

.ret:
        push rbx                ; Push return address.

        ret

;___________________________SPECIFIERS_________________________________________

; -----------------------------------------------
; DESCRIPTION   | Prints binary number.
; -----------------------------------------------
; ENTRY         | RAX - number to print
; -----------------------------------------------
; RETURN        | RSI - pointer to start of BUF
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_bin:
        push rcx
        push rdx

        mov rcx, 64
	mov rsi, BIN_BUF
        add rsi, rcx
        dec rsi

.loop:
	mov dl, 1
        and dl, al
        add dl, 0x30

        mov byte [rsi], dl

        dec rsi
        shr rax, 1

        cmp rax, 0
        je .done

        loop .loop

.done:
        inc rsi
        pop rdx
        pop rcx

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints hex number.
; -----------------------------------------------
; ENTRY         | RAX - number to print
; -----------------------------------------------
; RETURN        | RSI - pointer to start of BUF
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_hex:
        push rcx
        push rdx

        xor rdx, rdx

        mov rcx, 16
	mov rsi, HEX_BUF
        add rsi, rcx
        dec rsi

.loop:
	mov dl, 0xF
        and dl, al

        cmp dl, 10
        jbe .num
        jmp .letter

.num:
        add dl, '0'
        jmp .ret

.letter:
        add dl, 'A' - 10

.ret:
        mov byte [rsi], dl

        dec rsi
        shr rax, 4

        cmp rax, 0
        je .done

        loop .loop

.done:
        inc rsi
        pop rdx
        pop rcx

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints octal number.
; -----------------------------------------------
; ENTRY         | RAX - number to print
; -----------------------------------------------
; RETURN        | RSI - pointer to start of BUF
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_oct:
        push rcx
        push rdx

        xor rdx, rdx

        mov rcx, 24
	mov rsi, OCT_BUF
        add rsi, rcx
        dec rsi

.loop:
	mov dl, 0x7
        and dl, al

        add dl, '0'

        mov byte [rsi], dl

        dec rsi
        shr rax, 3

        cmp rax, 0
        je .done

        loop .loop

.done:

        inc rsi
        pop rdx
        pop rcx

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints decimal number.
; -----------------------------------------------
; ENTRY         | RAX - number to print
; -----------------------------------------------
; RETURN        | RSI - pointer to start of BUF
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_dec:
        push rcx
        push rdx
        push r8
        push rax
        
        mov rcx, 20
	mov rsi, DEC_BUF
        add rsi, rcx
        dec rsi

        test eax, eax
        jns .next

        neg eax

.next:
        mov r8, 10
.loop: 
        xor rdx, rdx

        div r8
		       
	add dl, '0'
        mov byte [rsi], dl
        dec rsi

        cmp rax, 0
        je .done

        loop .loop

.done:
        pop rax
        test eax, eax
        js .sign
        jmp .no_sign

.sign:  
        mov byte [rsi], '-'
        dec rsi
        
.no_sign:
        inc rsi

        pop r8
        pop rdx
        pop rcx

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints null-terminated line with number.
; -----------------------------------------------
; ENTRY         | RSI - pointer to buffer
; -----------------------------------------------
; RETURN        | Number of chars written.
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_num:
        push rax
        push rcx
        push rsi
        push rdi
        push rdx

        mov rdi, rsi
        call str_len

        mov rax, 1
        mov rdi, 1
        mov rdx, rcx

        syscall

        pop rdx
        pop rdi
        pop rsi
        pop rcx
        pop rax

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints char.
; -----------------------------------------------
; ENTRY         | RAX - character to print.
; -----------------------------------------------
; RETURN        | Number of chars written.
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_char:
        push rdx
        push rsi
        push rdi
        push rax

        mov rax, 1
        mov rdi, 1
        mov rsi, rsp
        mov rdx, 1

        syscall

        pop rax
        pop rdi
        pop rsi
        pop rdx

        ret

; -----------------------------------------------
; DESCRIPTION   | Prints string.
; -----------------------------------------------
; ENTRY         | RAX - pointer to line.
; -----------------------------------------------
; RETURN        | Number of chars written.
; -----------------------------------------------
; DESTROYS      | NONE
; -----------------------------------------------
print_str:
        push rcx
        push rdx
        push rsi
        push rdi
        push rax

        mov rdi, rax
        call str_len
        mov rdx, rcx

        mov rsi, rax
        mov rax, 1
        mov rdi, 1

        syscall

        pop rax
        pop rdi
        pop rsi
        pop rcx
        pop rcx

        ret

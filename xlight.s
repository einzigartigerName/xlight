; sys_read        0
; sys_write       1
; sys_open        2
; sys_close       3
; sys_exit        60      

; stdin           0
; stdout          1

; O_RDONLY      0
; O_WRONLY      1
; O_RDWR        2
; O_CREATE      64


section .data
    o_file db "output.txt",0
    i_file db "input.txt", 0
    prompt db "Enter Text (max 31 Chars)", 10

section .bss
    input resb 32

section .text
    global _start

_start:
    ; open input-file
    mov     rax, 2          ; sys_open = 2
    mov     rdi, i_file     ; file = filename
    mov     rsi, 0          ; O_RDONLY
    syscall

    push    rdi             ; save fd

    ; Read from stdin
    mov     rdi, rax        ; fd from input-file
    mov     rax, 0          ; sys_read = 0
    mov     rsi, input      ; buffer
    mov     rdx, 32         ; buffer length
    syscall

    pop     rdi             ; get fd from stack to close it
    push    rax             ; Save read bytes
    mov     rax, 3          ; sys_close = 3
    syscall

    ; open output-file
    mov     rax, 2          ; sys_open = 2
    mov     rdi, o_file     ; file = filename
    mov     rsi, 65         ; O_WONLY = 1 + O_CREATE = 64
    mov     rdx, 0644o      ; permisions
    syscall

    ; print buffer 
    mov     rdi, rax        ; fd to write to
    pop     rdx             ; lenght to write
    push    rax             ; save fd
    mov     rax, 1          ; sys_write = 1
    mov     rsi, input      ; buffer to print
    syscall

    ; close file
    mov     rax, 3          ; sys_close = 3
    pop     rdi             ; pop fd from stack
    syscall

    ; Exit
    mov     rax, 60         ; sys_exit = 60
    mov     rdi, 0          ; return value
    syscall

; rdi:  pointer to ascii-string
; function terminates at first non digit
ascii_to_int:
    movzx   eax, byte [rdi]     ; first digit
    sub     eax, 48             ; converts ascii to number
    cmp     al, 9               ; check if its [0..9]
    jbe     .loop_start         ; begin loop, else return 0

    xor     eax, eax            ; return 0
    ret

.prep_next:
    ; rax *= 10 + rcx
    ; rax := total
    ; rcx := digit
    lea     eax, [rax*4 + rax]    ; rax *= 5
    lea     eax, [rax*2 + rcx]    ; rax = (rax * 5) * 2 + rcx

.loop_start:
    inc     rdi                 ; next character
    movzx   ecx, byte [rdi]     ; current digit
    sub     ecx, 48             ; converts ascii to number
    cmp     cl, 9               ; check if its [0..9]
    jbe     .prep_next          ; add value
    
    ret                         ; else return current total
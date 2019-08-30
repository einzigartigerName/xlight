section .data
    file db "output.txt",0
    prompt db "Enter Text (max 31 Chars)", 10

section .bss
    input resb 32

section .text
    global _start

_start:
    ; print prompt 
    mov rax, 1          ; sys_write = 1
    mov rdi, 1          ; stdout = 1
    mov rsi, prompt     ; buffer to print
    mov rdx, 26         ; buffer length
    syscall

    ; Read from stdin
    mov rdi, 0          ; stdin
    mov rax, 0          ; sys_read = 0
    mov rsi, input      ; buffer
    mov rdx, 32         ; buffer length
    syscall

    push rax            ; Save read bytes

    ; open file
    mov rax, 2          ; sys_open = 2
    mov rdi, file       ; file = filename
    mov rsi, 65         ; O_WONLY = 1 + O_CREATE = 64
    mov rdx, 0644o      ; permisions
    syscall

    ; print buffer 
    mov rdi, rax        ; fd to write to
    pop rdx             ; lenght to write
    push rax            ; save fd
    mov rax, 1          ; sys_write = 1
    mov rsi, input      ; buffer to print
    syscall

    ; close file
    mov rax, 3          ; sys_close = 3
    pop rdi             ; pop fd from stack
    syscall

    ; Exit
    mov rax, 60         ; sys_exit = 60
    mov rdi, 0          ; return value
    syscall

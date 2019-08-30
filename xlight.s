section .data
    text db "Hello, World!",10

section .text
    global _start

_start:
    mov rax, 1      ; Number for Write Syscall
    mov rdi, 1      ; Where to write to: 1 = stdout
    mov rsi, text   ; What to write
    mov rdx, 14     ; How many character to write
    syscall         ; Call write(stdout, text)

    mov rax, 60     ; Number for exit()
    mov rdi, 0      ; exit argument
    syscall         ; call exit(0)

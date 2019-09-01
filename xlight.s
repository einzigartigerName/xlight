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
    file db "test.txt",0

section .bss
    input resb 32

section .text
    global _start

_start:
    ; open file
    mov     rax, 2              ; sys_open = 2
    mov     rdi, file           ; file = filename
    mov     rsi, 66             ; O_RDWR + O_CREATE
    mov     rdx, 0644o          ; permisions
    syscall

    mov     rbx, rax            ; save fd

    ; Read from file
    mov     rdi, rax            ; fd from input-file
    mov     rax, 0              ; sys_read = 0
    mov     rsi, input          ; buffer
    mov     rdx, 32             ; buffer length
    syscall

    ; convert buffer to uint32
    mov     rdi, input          ; buffer to convert
    call    ascii_to_int    

    add     rax, 100            ; add 100 to number

    ; write new number to file
    mov     rdi, rax            ; uint32 to write
    mov     rsi, rbx            ; fd to write number to
    call    print_uint32

    ; close file
    mov     rax, 3              ; sys_close = 3
    mov     rdi, rbx            ; file to close
    syscall

    ; Exit
    mov     rax, 60             ; sys_exit = 60
    mov     rdi, 0              ; return value
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
    lea     eax, [rax*4 + rax]  ; rax *= 5
    lea     eax, [rax*2 + rcx]  ; rax = (rax * 5) * 2 + rcx

.loop_start:
    inc     rdi                 ; next character
    movzx   ecx, byte [rdi]     ; current digit
    sub     ecx, 48             ; converts ascii to number
    cmp     cl, 9               ; check if its [0..9]
    jbe     .prep_next          ; add value
    
    ret                         ; else return current total




; rdi:  uint32
; rsi:  fd to write to
print_uint32:
    mov     r8, rsi             ; save fd
    mov     eax, edi            ; uint32 value moved for div
    mov     ecx, 10             ; base 10 = \n
    push    rcx                 
    mov     rsi, rsp            ; save stack-pointer
    sub     rsp, 16



.digit_to_ascii:
    xor     edx, edx            ; clear edx
    div     ecx                 ; eax/10 with remainder in edx
    add     edx, 48             ; digit to ascii
    dec     rsi
    mov     [rsi], dl           ; put digit into write buffer

    test    eax, eax            ; check if 0
    jnz     .digit_to_ascii     ; continue loop

    ; else write
    mov     rax, 1              ; sys_write
    mov     rdi, r8             ; fd to write to
    lea     rdx, [rsp + 16 + 1] ; get length
    sub     rdx, rsi            ; lenght with \n
    syscall

    add     rsp, 24             ; undo buffer
    ret
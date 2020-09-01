; sys_read          0
; sys_write         1
; sys_open          2
; sys_close         3
; sys_lseek         8
; sys_exit          60

; stdin             0
; stdout            1

; O_RDONLY          0
; O_WRONLY          1
; O_RDWR            2
; O_CREAT           64

; max-brightness

section .data
; -- brightness-file --
    

section .bss
    input resb 32

section .text
    global _start

_start:
    ; check for correct amount of args
    pop     rax                 ; get argc
    cmp     rax, 2              ; correct amount of args?
    jne     .exit               ; exit if more/less than one argument

    ; get argv[1]
    pop     rax                 ; skip first arg, is just program-name
    pop     rax                 ; argv[1]

    ; parse argument
    xor     r12, r12
    mov     r12b, byte [rax]    ; get first char
    cmp     r12, '+'            ; check if '+'
    je      .parse_pos          ; just parse

    cmp     r12, '-'            ; check if '-'
    je      .parse_neg
    jmp     .exit               ; else exit program

.parse_pos:
    inc     rax                 ; skip to first digit
    mov     rdi, rax            
    call    ascii_to_uint32     ; convert to uint32
    mov     r12, rax
    jmp     .get_current

.parse_neg:
    inc     rax                 ; skip to first digit
    mov     rdi, rax
    call    ascii_to_uint32     ; convert to uint32
    mov     r12, rax
    neg     r12

.get_current:
    ; open file
    mov     rax, 2              ; sys_open = 2
    mov     rdi, file           ; file = filename
    mov     rsi, 66             ; O_RDWR + O_CREAT
    mov     rdx, 0644o          ; permisions
    syscall

    mov     rbx, rax            ; save fd

    ; Read from file
    mov     rdi, rax            ; fd from input-file
    xor     eax, eax            ; sys_read = 0
    mov     rsi, input          ; buffer
    mov     rdx, 32             ; buffer length
    syscall

    ; set file offfset to beginning
    mov     rsi, rax
    neg     rsi                 ; beginning of file
    mov     rax, 8              ; sys_lseek = 8
    mov     rdi, rbx            ; fd
    mov     rdx, 1              ; SEEK_SET
    syscall

    ; convert buffer to uint32
    mov     rdi, input          ; buffer to convert
    call    ascii_to_uint32    

    ; handle offset
    add     rax, r12            ; add offset
    cmp     rax, MAX_VALUE      ; check if new value bigger than MAX_VALUE
    jge     .write_max
    cmp     rax, 0              ; check if lower than 0
    jle     .write_min
    jmp     .write_value        ; else write value

.write_max:
    mov     rax, MAX_VALUE
    jmp     .write_value

.write_min:
    xor     rax, rax

.write_value:
    ; write new number to file
    mov     rdi, rax            ; uint32 to write
    mov     rsi, rbx            ; fd to write number to
    call    print_uint32

    ; close file
    mov     rax, 3              ; sys_close = 3
    mov     rdi, rbx            ; file to close
    syscall

.exit:
    ; Exit
    mov     rax, 60             ; sys_exit = 60
    xor     edi, edi            ; return value
    syscall




; rdi:  pointer to ascii-string
; function terminates at first non digit
ascii_to_uint32:
    movzx   eax, byte [rdi]     ; first digit
    sub     eax, '0'            ; converts ascii to number
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
    sub     ecx, '0'            ; converts ascii to number
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
    add     edx, '0'            ; digit to ascii
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
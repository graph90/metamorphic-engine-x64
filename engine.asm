BITS 64
DEFAULT REL

GLOBAL mutate_region
GLOBAL engine_init

; profiles
%define PROFILE_LIGHT   1
%define PROFILE_HEAVY   2
%define PROFILE_CHAOTIC 3

SECTION .bss
engine_profile: resd 1

SECTION .text

engine_init:
    mov [engine_profile], edi
    ret

mutate_region:
    push rbp
    mov rbp, rsp
    push rbx

    mov r12, rdi
    mov r13, rsi

    ; seed RNG
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov r15, rax

    ; decide pass count by profile
    mov eax, [engine_profile]
    cmp eax, PROFILE_LIGHT
    je light
    cmp eax, PROFILE_HEAVY
    je heavy
    jmp chaotic

light:
    mov r14d, 2
    jmp start

heavy:
    mov r14d, 6
    jmp start

chaotic:
    call rand32
    and eax, 7
    add eax, 4
    mov r14d, eax

start:

pass_loop:

    ; random offset
    call rand32
    xor edx, edx
    div r13d
    mov rcx, rdx

    ; random span (1–8 bytes)
    call rand32
    and eax, 7
    inc eax
    mov r8d, eax

    ; random opcode
    call rand32
    and eax, 3
    mov ebx, eax

    ; random key
    call rand32
    mov dl, al

range_loop:
    cmp rcx, r13
    jae next_pass

    cmp ebx, 0
    je do_xor
    cmp ebx, 1
    je do_add
    cmp ebx, 2
    je do_rol
    jmp do_swap

do_xor:
    mov al, [r12 + rcx]
    xor al, dl
    mov [r12 + rcx], al
    jmp cont

do_add:
    mov al, [r12 + rcx]
    add al, dl
    mov [r12 + rcx], al
    jmp cont

do_rol:
    mov al, [r12 + rcx]
    rol al, 1
    mov [r12 + rcx], al
    jmp cont

do_swap:
    mov rdx, r13
    dec rdx
    sub rdx, rcx
    mov al, [r12 + rcx]
    mov bl, [r12 + rdx]
    mov [r12 + rcx], bl
    mov [r12 + rdx], al

cont:
    inc rcx
    dec r8d
    jnz range_loop

next_pass:
    dec r14d
    jnz pass_loop

    pop rbx
    pop rbp
    ret

rand32:
    mov rax, r15
    shr rax, 12
    xor r15, rax
    mov rax, r15
    shl rax, 25
    xor r15, rax
    mov rax, r15
    shr rax, 27
    xor r15, rax
    mov eax, r15d
    ret

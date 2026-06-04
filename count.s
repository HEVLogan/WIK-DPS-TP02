    .section .text
    .global _start

_start:
    mov     x19, #0             // counter = 0
    mov     x20, #10001         // loop limit (can't use >4095 as cmp immediate)

.Lloop:
    sub     sp, sp, #16         // allocate 16 bytes on stack

    // place newline at buf[15]
    add     x1, sp, #15
    mov     w3, #10
    strb    w3, [x1]

    // convert x19 to decimal string, right to left
    mov     x0, x19
    cmp     x0, #0
    b.ne    .Ldigits

    // special case: number is 0
    sub     x1, x1, #1
    mov     w3, #48
    strb    w3, [x1]
    b       .Lwrite

.Ldigits:
    mov     x5, #10
.Ldigit_loop:
    cbz     x0, .Lwrite
    sub     x1, x1, #1
    udiv    x4, x0, x5          // x4 = x0 / 10
    msub    x3, x4, x5, x0      // x3 = x0 % 10
    add     w3, w3, #48         // ASCII digit
    strb    w3, [x1]
    mov     x0, x4
    b       .Ldigit_loop

.Lwrite:
    // x1 = start of string, sp+16 = end
    add     x2, sp, #16
    sub     x2, x2, x1          // length

    mov     x0, #1              // stdout
    mov     x8, #64             // syscall write
    svc     #0

    add     sp, sp, #16

    add     x19, x19, #1
    cmp     x19, x20
    b.lt    .Lloop

    mov     x0, #0
    mov     x8, #93             // syscall exit
    svc     #0

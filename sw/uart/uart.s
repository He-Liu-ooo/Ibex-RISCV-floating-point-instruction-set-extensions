

.text
.align 1
.global main

main:

.set UART_ADDR           ,0x40010000


    li x2,  UART_ADDR
    li x4,  0x01

    sw x4, 0x0(x2)
Loop:
    lw x4, 0x0(x2)
    addi x4, x4, 1
    sw x4,  0x0(x2)  


    li x6, 0x80
Delay:
    addi x6, x6, -1
    bne x6, x0, Delay

    j   Loop
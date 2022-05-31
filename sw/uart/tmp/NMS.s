.text

.align 1

.global main

main:
.set UART_ADDR,         0x10000000  

    li x2,  UART_ADDR

    alu_custom x6, x2, x3

    lui   x1,0x40bc0  /*5.875*/
    lui   x3,0x40840  /*4.125*/
    lui   x4,0x40840  /*4.125*/

    alu_custom x6, x2, x3

    sw x1, 0x0(x2)    /* operand a */
    lw x1, 0x0(x2)

    sw x3, 0x0(x2)    /* operand b */
    lw x3, 0x0(x2)

    sw x4, 0x0(x2)    /* operand a */
    lw x4, 0x0(x2)
    
    add x4,x3,x1
    add x4,x3,x4

    alu_custom x5, x2, x3


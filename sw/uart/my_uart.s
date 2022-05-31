

.text
.align 1
.global main

main:

.set UART_ADDR           ,0x40010000

/* x2 is base addr
   x3 is config data
   x4 is rx_data
*/

    li x2,  UART_ADDR
    li x4,  0x01
    
    li x3, 0x1458       /*REG_BUAD*/
    sw x3, 0x14(x2)
    lw x4, 0x14(x2)      /* TEST */

    addi x3, x0, 1      /*REG_DATA*/
    sw x3, 0x18(x2)

    addi x3, x0, 0      /*REG_STOP*/
    sw x3, 0x1c(x2)

    addi x3, x0, 2      /*REG_CHECK*/
    sw x3, 0x20(x2)


/*DATA_WT 0x0(x2)
  DATA_RD 0x4(x2)
  STATE 0x8(x2)
  ERROR 0xc(x2)
  REG_ENABLE 0x10(x2)
  REG_BUAD 0x14(x2)
  REG_DATA 0x18(x2)
  REG_STOP 0x1c(x2)
  REG_CHECK 0x20(x2)
*/

Loop:
/* =================== send first data ===================== */
    addi x4, x0, 51    /* 110011 */
    sw x4, 0x0(x2)
    addi x3, x0, 2
    sw x3, 0x10(x2)    /*send enable*/

    li x6, 0x7d00      /*hold the value*/
Delay0:
    addi x6, x6, -1
    bne x6, x0, Delay0

    addi x3, x0, 0
    sw x3, 0x10(x2)    /*send unable*/

    li x6, 0xc80      /*hold the value*/
Delay1:
    addi x6, x6, -1    
    bne x6, x0, Delay1
    
/* ==================== send second data ==================== */
    addi x4, x0, 57    /* 111001 */
    sw x4, 0x0(x2)
    addi x3, x0, 2
    sw x3, 0x10(x2)    /*send enable*/

    li x6, 0x7d00      /*hold the value*/
Delay2:
    addi x6, x6, -1
    bne x6, x0, Delay2

    addi x3, x0, 0
    sw x3, 0x10(x2)    /*send unable*/

    li x6, 0xc80      /*hold the value*/
Delay3:
    addi x6, x6, -1
    bne x6, x0, Delay3

/* ==================== send third data ==================== */
    addi x4, x0, 37     /* 100101 */
    sw x4, 0x0(x2)
    addi x3, x0, 2
    sw x3, 0x10(x2)    /*send enable*/

    li x6, 0x3e80      /*hold the value*/
Delay4:
    addi x6, x6, -1
    bne x6, x0, Delay4

    addi x3, x0, 0
    sw x3, 0x10(x2)    /*send unable*/

    li x6, 0x36b0      /*hold the value*/
Delay5:
    addi x6, x6, -1
    bne x6, x0, Delay5





/* ===================== recv first data =================== */
    addi x3, x0, 1
    sw x3, 0x10(x2)    /*send enable*/

    li x6, 0x3e80      /*hold the value*/
Delay6:
    addi x6, x6, -1
    bne x6, x0, Delay6

    addi x3, x0, 0
    sw x3, 0x10(x2)    /*send unable*/

    li x6, 0x960      /*hold the value*/
Delay7:
    addi x6, x6, -1
    bne x6, x0, Delay7
    

/* ===================== recv second data =================== */
    addi x3, x0, 1
    sw x3, 0x10(x2)    /*send enable*/

    li x6, 0x3200      /*hold the value*/
Delay8:
    addi x6, x6, -1
    bne x6, x0, Delay8

    addi x3, x0, 0
    sw x3, 0x10(x2)    /*send unable*/

    li x6, 0x960      /*hold the value*/
Delay9:
    addi x6, x6, -1
    bne x6, x0, Delay9

/* ===================== recv third data ==================== */
    addi x3, x0, 1
    sw x3, 0x10(x2)    /*send enable*/

    li x6, 0x36b0      /*hold the value*/
Delay10:
    addi x6, x6, -1
    bne x6, x0, Delay10

    addi x3, x0, 0
    sw x3, 0x10(x2)    /*send unable*/





/*    li x6, 0xffff
Delay:
    addi x6, x6, -1
    bne x6, x0, Delay

    j   Loop
*/

// reset value
`define DATA_INIT 32'h0
`define STATE_INIT 32'h0
`define ERROR_INIT 32'h0

`define CFGREG_ENABLE_INIT 32'h0
`define CFGREG_BAUD_INIT 32'h0000_0020
`define CFGREG_DATA_INIT 32'h0000_0001
`define CFGREG_STOP_INIT 32'h0000_0000
`define CFGREG_CHECK_INIT 32'h0000_0000

// `define CFGREG_FIFODEPTH_INIT 32'h0000_00ff   // 16

// `define CFGREG_INTERRUPT_INIT 32'h0000_0001

// `define INTERRUPT_RD_INIT 32'h0000_0000   // 复位值为全零，意味着复位时没有任何中断正在进行


// addr
// FIXME consider to make the addr consecutive
`define DATA_WT_ADDR 32'h43c0_0000
`define DATA_RD_ADDR 32'h43c0_0004
`define STATE_ADDR 32'h43c0_001c
`define ERROR_ADDR 32'h43c0_0020

`define CFGREG_ENABLE_ADDR 32'h43c0_0008
`define CFGREG_BAUD_ADDR 32'h43c0_000c
`define CFGREG_DATA_ADDR 32'h43c0_0010
`define CFGREG_STOP_ADDR 32'h43c0_0014
`define CFGREG_CHECK_ADDR 32'h43c0_0018
// `define CFGREG_INTERRUPT_ADDR 32'h32c0_0024
// `define CFGREG_FIFODEPTH_ADDR 32'h43c0_002c

// `define INTERRUPT_RX_FULL_ADDR 32'h43c0_0030     // write only, aims to clear interrupt
// `define INTERRUPT_TX_EMPTY_ADDR 32'h43c0_003c
// `define INTERRUPT_RX_RECV_ADDR 32'h43c0_0028   // 总线只能写这两个寄存器，不能读
// `define INTERRUPT_TX_SEND_ADDR 32'h43c0_0034
// `define INTERRUPT_RD_ADDR 32'h43c0_0040    // 总线只能读这个寄存器，不能写，因为正在处理什么中断是由 uart 决定的，不是由总线决定的
//                                            // 因此总线只能通过读这个寄存器来了解目前正在进行什么中断
// reset value
`define DATA_INIT 32'h0
`define STATE_INIT 32'h0
`define ERROR_INIT 32'h0

`define CFGREG_ENABLE_INIT 32'h0
`define CFGREG_BAUD_INIT 32'h0000_0020
`define CFGREG_DATA_INIT 32'h0000_0001
`define CFGREG_STOP_INIT 32'h0000_0000
`define CFGREG_CHECK_INIT 32'h0000_0000

// addr
// FIXME consider to make the addr consecutive
`define DATA_WT_ADDR 32'h4001_0000
`define DATA_RD_ADDR 32'h4001_0004
`define STATE_ADDR 32'h4001_0008
`define ERROR_ADDR 32'h4001_000c

`define CFGREG_ENABLE_ADDR 32'h4001_0010
`define CFGREG_BAUD_ADDR 32'h4001_0014
`define CFGREG_DATA_ADDR 32'h4001_0018
`define CFGREG_STOP_ADDR 32'h4001_001c
`define CFGREG_CHECK_ADDR 32'h4001_0020


//`include "./uart_common.h"
// NOTE here no include need to be implement
//`include "../rtl/peripheral/uart/rx_div.v"
//`include "../rtl/peripheral/uart/tx_div.v"
//`include "../rtl/peripheral/uart/tx.v"
//`include "../rtl/peripheral/uart/rx.v"

module uart_top(
//uart
    input wire uart_clk,  //50MHz，或其他自定时钟频率
    input wire uart_rx,
    output wire uart_tx,

//apb interface
    input  wire              pclk,
    input  wire              prstn, 

    input  wire              penable,
    input  wire              pwrite,
    input  wire              psel,
    input  wire [31:0]       paddr,
    input  wire [31:0]       pwdata,

    output reg  [31:0]       prdata,
    output wire              pready,   // slave tells master whether it is ready
    output wire              pslverr, 

//irq
    output wire              uart_irq
);
// =================================================
// registers
// =================================================

// data register 
// NOTE set reg's value to wire is legal
    reg [31:0] reg_DATA_WT;
    reg [7:0] data_wt_d1;
    reg [7:0] data_wt_d2;

    reg [31:0] reg_DATA_RD;
    reg [7:0] data_rd_s;
    reg [7:0] data_rd_d1;


    reg [31:0] reg_ERROR;
    reg parity_check_s;
    reg parity_check_d1;

// state register
    reg [31:0] reg_STATE;       // send recv
                                // read only
    reg send_state_s;
    reg recv_state_s;
    reg send_state_d1;
    reg recv_state_d1; 

// config registers 
    reg [31:0] cfgreg_ENABLE;
    reg uart_send_d1;
    reg uart_send_d2;

    reg uart_recv_d1;
    reg uart_recv_d2;

    reg [31:0] cfgreg_BAUD;
    reg [31:0] baud_d1;
    reg [31:0] baud_d2;

    reg [31:0] cfgreg_DATA;
    reg [31:0] cfgreg_STOP;
    reg [31:0] cfgreg_CHECK;
    reg [5:0] configs_d1;
    reg [5:0] configs_d2;

// ===================================================



// ===================================================
// set signals
// ===================================================

    // CONFUSED whether the value of pready should be considered
    wire pwren = penable && pwrite && psel && pready;
    wire prden = penable && !pwrite && psel && pready;
// check whether the state is read or write correctly
// FIXME 
    assign pready = 1'b1;
    assign pslverr = 1'b0;

    wire tx_clk;   // serve as bridge
    wire rx_clk;
// =====================================================




// =================================================
// blocks
// =================================================
// rx_div and tx_div
    rx_div rx_div0(.rstN(prstn), .uart_clk(uart_clk), .cfg_baud(baud_d2), .baud_clk(rx_clk));
    tx_div tx_div0(.rstN(prstn), .uart_clk(uart_clk), .cfg_baud(baud_d2), .baud_clk(tx_clk));


// tx block
    tx tx0(.rstN(prstn), 
          .pclk(pclk), 
          .clk(tx_clk), 
          .tx_trans_en(uart_send_d2), 
          .tx_data(data_wt_d2), 
          .uart_tx(uart_tx), 
          .configs(configs_d2),
          .state_out(send_state_s));   // apb sends irq_clear to recv block

//  rx block
    rx rx0(.rstN(prstn), 
          .pclk(pclk), 
          .clk(rx_clk), 
          .rx_trans_en(uart_recv_d2), 
          .rx_data(data_rd_s), 
          .uart_rx(uart_rx), 
          .configs(configs_d2),
          .state_out(recv_state_s),
          .check_error(parity_check_s));

// ==================================================




// =====================================================
// APB read and write
// =====================================================

// write
    // NOTE in the apb's clock domain
    always@(posedge pclk or negedge prstn) begin
        if(!prstn) begin   // apb reset, set config regiter to default value
            reg_DATA_WT <= `DATA_INIT;
            //reg_DATA_RD <= `DATA_INIT;
            cfgreg_ENABLE <= `CFGREG_ENABLE_INIT;
            cfgreg_BAUD <= `CFGREG_BAUD_INIT;
            cfgreg_DATA <= `CFGREG_DATA_INIT;
            cfgreg_STOP <= `CFGREG_STOP_INIT;
            cfgreg_CHECK <= `CFGREG_CHECK_INIT;
        end
        else if(pwren) begin   // NOTE dont forget the condition
            case(paddr)
                `DATA_WT_ADDR: reg_DATA_WT <= pwdata;
                `CFGREG_ENABLE_ADDR: cfgreg_ENABLE <= pwdata;
                `CFGREG_BAUD_ADDR: cfgreg_BAUD <= pwdata;
                `CFGREG_DATA_ADDR: cfgreg_DATA <= pwdata;
                `CFGREG_STOP_ADDR: cfgreg_STOP <= pwdata;
                `CFGREG_CHECK_ADDR: cfgreg_CHECK <= pwdata;
            endcase 
        end
        else;  // if it is not write_enabled, dont change the registers
    end

// read
    // NOTE as soon as read is enabled, we put the data on the bus
    // what the data is like when read is unabled is not important
    always@(prden) begin
        if(prden) begin
            case(paddr)
                `DATA_WT_ADDR: prdata <= reg_DATA_WT;
                `DATA_RD_ADDR: prdata <= reg_DATA_RD;
                `STATE_ADDR: prdata <= reg_STATE;
                `ERROR_ADDR: prdata <= reg_ERROR;

                `CFGREG_ENABLE_ADDR: prdata <= cfgreg_ENABLE;
                `CFGREG_BAUD_ADDR: prdata <= cfgreg_BAUD;
                `CFGREG_DATA_ADDR: prdata <= cfgreg_DATA;
                `CFGREG_STOP_ADDR: prdata <= cfgreg_STOP;
                `CFGREG_CHECK_ADDR: prdata <= cfgreg_CHECK;
                default: prdata <= 'd0;    // FIXME not sure whether default value should be zero
            endcase
        end
    end

// ======================================================




// ======================================================
// sychronize
// ======================================================

// sychronize to tx
// CONFUSED whether the dest clk domain is uart_clk
    always@(posedge uart_clk) begin
        // 总线要求串口发送的数据无需同步到 uart 时钟域，在 pclk 时钟域下即可

        data_wt_d1 <= reg_DATA_WT[7:0];
        data_wt_d2 <= data_wt_d1;

        // 同步配置到 uart 时钟域
        uart_send_d1 <= cfgreg_ENABLE[1];
        uart_send_d2 <= uart_send_d1;

        uart_recv_d1 <= cfgreg_ENABLE[0];
        uart_recv_d2 <= uart_recv_d1;

        baud_d1 <= cfgreg_BAUD;
        baud_d2 <= baud_d1;

        configs_d1 <= {cfgreg_CHECK[1:0], 1'b0, cfgreg_STOP[0], cfgreg_DATA[1:0]};
        configs_d2 <= configs_d1;
    end

// sychronize to rx
    always@(posedge pclk) begin
        if(!prstn) begin
            reg_DATA_RD <= 'd0;
            //irq_RD <= 'd0;
            reg_STATE <= 'd0;
        end
        else begin
            // 此数据是要在 apb 使用的，因此也需要同步到 uart 时钟域
            data_rd_d1 <= data_rd_s;
            reg_DATA_RD[7:0] <= data_rd_d1;

            send_state_d1 <= send_state_s;
            reg_STATE[1] <= send_state_d1;

            recv_state_d1 <= recv_state_s;
            reg_STATE[0] <= recv_state_d1;

            parity_check_d1 <= parity_check_s;
            reg_ERROR[0] <= parity_check_d1;
            
        end
    end

//=======================================================

endmodule

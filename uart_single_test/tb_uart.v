`timescale 1ns/1ps
//`include "./uart_top.v"
//`include "./APB3_BFM.sv"
//`include "src/FIFO.v"

`define UART_CLK_FREQ 50000000
`define ADDR_WIDTH 32

module tb();
    reg pclk;
    reg prst_n;
    reg psel;
    reg penable;
    reg pwrite;
    reg [`ADDR_WIDTH-1:0] paddr;
    reg [31:0] pwdata;
    reg [31:0] prdata;
    reg pready;
    reg pslverr;

    reg uart_clk;
    reg uart_rx;
    reg uart_tx;
    reg uart_irq;

    integer i;
    integer j;

    //APB
    APB3_BFM /*#(.ADDR_WIDTH(`ADDR_WIDTH))*/ APB(.pclk(pclk), 
                                            .prst_n(prst_n), 
                                            .psel(psel), 
                                            .penable(penable), 
                                            .pwrite(pwrite), 
                                            .paddr(paddr), 
                                            .pwdata(pwdata),
                                            .prdata(prdata),
                                            .pready(pready),
                                            .pslverr(pslverr));
    
    // uart_top
    uart_top uart(.uart_clk(uart_clk), 
                  .uart_rx(uart_rx),
                  .uart_tx(uart_tx),
                  .pclk(pclk),
                  .prstn(prst_n),
                  .penable(penable),
                  .pwrite(pwrite),
                  .psel(psel),
                  .paddr(paddr),
                  .pwdata(pwdata),
                  .prdata(prdata),
                  .pready(pready),
                  .pslverr(pslverr),
                  .uart_irq(uart_irq));

    initial begin
        prst_n = 1'b0;
        pclk = 1'b1;
        uart_clk = 1'b1;
        # 100 
        prst_n = 1'b1;
    end

    initial begin
        $fsdbDumpfile("tb_uart.fsdb");
	$fsdbDumpvars;
    end

    initial begin
        uart_rx = 1'b1;
        # 3300000
        // first frame  0110_1011
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 800000
        // 001011       ??? right
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;   // parity
        # 104167
        uart_rx = 1'b1;

        // 3789169
        # 400000
        
        // second frame    0110_1100
        // NOTE  ??????????????????????????????????????????????????
        // uart_rx = 1'b0; 
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 800000

        // 4189169
        // 000101
        uart_rx = 1'b0; 
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;    // parity wrong
        # 104167
        uart_rx = 1'b1;

        // 4918388

        # 400000
        // third frame    1010_0011
        // uart_rx = 1'b0; 
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b0;
        // # 104167
        // uart_rx = 1'b1;
        // # 104167
        // uart_rx = 1'b1;
        
        // 010011 

        // 5318388
        uart_rx = 1'b0; 
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;
        # 104167
        uart_rx = 1'b0;
        # 104167
        uart_rx = 1'b1;   // parity correct
        # 104167
        uart_rx = 1'b1;
        
    end

    initial begin
        for(i=0;i<1000000;i=i+1) begin
            # 10
            uart_clk = ~uart_clk;
        end
    end

    initial begin
        for(j=0;j<5000000;j=j+1) begin
            # 2
            pclk = ~pclk;
        end
    end

    // reg rstN;
    // reg pclk;
    // reg wr_en;

    // reg [7:0] tx_data;
    // reg [3:0] fifosize = 'd16;

    // reg rd_clk;
    // reg rd_en;
    // //reg valid;
    // wire [7:0] dout;
    // wire is_empty;

    // integer j;
    // integer i;

    // FIFO FIFO(.rstN(rstN), 
    //           .wr_clk(pclk), 
    //           .wr_en(wr_en), 
    //           .din(tx_data),
    //           //.fifosize(fifosize),

    //           .rd_clk(rd_clk),
    //           .rd_en(rd_en),
    //           //.valid(valid),
    //           .dout(dout),
    //           .isempty(is_empty)
    //           );

    // initial begin
    //     rstN <= 0;
    //     pclk <= 1;
    //     rd_clk <= 1;
    //     wr_en <= 0;
    //     rd_en <= 0;
    //     # 100
    //     rstN <= 1; 
    // end

    // initial begin
    //     $dumpfile("sim/sim.vcd");
    //     $dumpvars;
    // end
    
    // initial begin
    //     for(j=0;j<5000000;j=j+1) begin
    //         # 10
    //         pclk = ~pclk;
    //     end
        
    // end

    // initial begin
    //     for(i=0;i<5000;i=i+1) begin
    //         # 54
    //         rd_clk = ~rd_clk;
    //     end
    // end

    // initial begin
    //     # 200 
    //     tx_data = 8'd20;
    //     # 20
    //     wr_en = 1;
    //     # 20 
    //     wr_en = 0;

    //     # 200 
    //     tx_data = 8'd30;
    //     # 20
    //     wr_en = 1;
    //     # 20 
    //     wr_en = 0;

    //     # 200 
    //     tx_data = 8'd40;
    //     # 20
    //     wr_en = 1;
    //     # 20 
    //     wr_en = 0;

    //     # 200 
    //     tx_data = 8'd50;
    //     # 20
    //     wr_en = 1;
    //     # 20 
    //     wr_en = 0;

    //     # 200 
    //     tx_data = 8'd60;
    //     # 20
    //     wr_en = 1;
    //     # 20 
    //     wr_en = 0;

    //     # 84
    //     //240*5+84=1284

    //     # 400 
    //     # 152
    //     rd_en = 1;
    //     # 108
    //     rd_en = 0;

    //     // 1944

    //     # 1080
    //     rd_en = 1;
    //     # 108
    //     rd_en = 0;

    //     // 3132

    //     # 1080
    //     rd_en = 1;
    //     # 108 
    //     rd_en = 0;

    //     // 4320

    //     # 200
    //     tx_data = 8'd70;
    //     # 20
    //     wr_en = 1;
    //     # 20 
    //     wr_en = 0;
        
    //     // 4560

    //     # 300
    //     rd_en = 1;
    //     # 108 
    //     rd_en = 0;
    // end
endmodule

// minimalistic simulation top module with clock gen and initial reset
`timescale 1ns/100ps
module ibex_soc_tb;

    logic clk, rst;
    logic rx, tx;
    
    localparam RAM_FPATH = "../sw/inst.pat";
    ibex_soc #(
        .RAM_FPATH  ( RAM_FPATH )
    )i_ibex_soc (
        .sys_clk_i  ( clk       ),
        .sys_rst_ni ( ~rst      ),
        .uart_rx_i  ( rx        ),
        .uart_tx_o  ( tx        )
    );

    initial begin
        rst = 1'b1;
        #20
        rst = 1'b0;
        #300;
        $finish(2);
    end

    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    localparam int unsigned           UART_RX_STRLEN = 4;
    localparam [UART_RX_STRLEN*8-1:0] UART_RX_STR    = "TEST";
    initial begin
        // keep rx line initially high for 100 us
        rx = 1'b1;
        #100000;

        for (int i = 0; i < UART_RX_STRLEN; i++) begin
            // start bit
            rx = 1'b0;
            #8681;

            for (int j = 0; j < 8; j++) begin
                rx = UART_RX_STR[i*8+j];
                #8681;
            end

            // stop bit
            rx = 1'b1;
            #8681;
        end
    end

  initial begin
    $fsdbDumpfile("tb_ibex_soc.fsdb");
    $fsdbDumpvars();
  end

endmodule

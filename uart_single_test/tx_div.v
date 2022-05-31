`define DEBUG

// NOTE rstN 低复位

module tx_div
(
    input rstN,
    input uart_clk,
    input[31:0] cfg_baud,
    output reg baud_clk
);
    integer counter = 0;
    reg[31:0] threshold;

    always@(posedge uart_clk) begin
        threshold <= cfg_baud/2;
    end

    // initial begin
    //     // FIXME how to use an input for calculation
    //     // threshold = UART_CLK_FREQ/cfg_baud/2;   // NOTE dont forget divide 2 !!!
    //     threshold = cfg_baud/2;
    //     `ifdef DEBUG
    //     $display("tx_div threshold is %d\n", threshold);
    //     `endif 
    // end

    always@(posedge uart_clk or negedge rstN) 
    begin
        if (!rstN) begin
            baud_clk <= 1'b1;  // init here
            counter <= 0;
        end
        else if (counter == threshold-1) begin  // dont forget minus one
            counter <= 0;
            baud_clk = ~baud_clk;
        end
        else begin
            counter <= counter+1;
        end        
    end

endmodule
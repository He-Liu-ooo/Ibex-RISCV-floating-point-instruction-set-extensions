// minimalistic simulation top module with clock gen and initial reset
`timescale 1ns/100ps
module tb_soc;

    logic clk, rstn;
    logic uart_rx;
    logic uart_tx;

soc_ahblite x_soc
(
  .clk   ( clk  ),
  .rstn  ( rstn ),

  .uart_rx  (uart_rx),
  .uart_tx  (uart_tx)
);
    initial begin
        rstn = 1'b0;
        #20
        rstn = 1'b1;
        #60000;
        $finish(2);
    end

    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

initial begin

    $display("*****start to load program*****");
    $readmemh("../sw/uart/uart.vmem",x_soc.x_isram_ahbl.sram_mem);

end

  initial begin
    $fsdbDumpfile("tb_soc.fsdb");
    $fsdbDumpvars();
  end

endmodule

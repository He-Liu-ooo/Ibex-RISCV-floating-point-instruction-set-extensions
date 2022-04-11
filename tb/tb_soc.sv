// minimalistic simulation top module with clock gen and initial reset
`timescale 1ns/100ps
module tb_soc;

    logic clk, rstn;
    
soc_ahblite x_soc
(
  .clk   ( clk  ),
  .rstn  ( rstn )
);
    initial begin
        rstn = 1'b0;
        #20
        rstn = 1'b1;
        #600;
        $finish(2);
    end

    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

  initial begin
    $fsdbDumpfile("tb_soc.fsdb");
    $fsdbDumpvars();
  end

endmodule

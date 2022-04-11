module sram_8x1024
(
  input  logic       CLK,
  input  logic       CEN,
  input  logic       WEN,
  input  logic [9:0] A,
  input  logic [7:0] D,
  output logic [7:0] Q
);

  logic [7:0] mem [1023:0];

  always_ff@(posedge CLK) begin
    if(!CEN&&!WEN)
      mem[A] <= D;
  end

  always_ff@(posedge CLK) begin
    if(!CEN&&WEN)
      Q <= mem[A];
  end
  
endmodule

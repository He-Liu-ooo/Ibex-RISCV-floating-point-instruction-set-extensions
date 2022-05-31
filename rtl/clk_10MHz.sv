
module clk_10MHz(
    input  logic  clk_i,   
    input  logic  rstn_i,
    output logic  clk_o  
); 

reg [7:0] count;
parameter  CNT = 'd5;

always_ff @(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        count <= 'd0;
        clk_o <= '0;
    end else begin
        count <= (count==CNT-1) ? 'd0 : count + 'd1;
        clk_o <= (count=='d0) ? ~clk_o : clk_o;
    end
end
endmodule

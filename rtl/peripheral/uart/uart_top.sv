
module uart_top#(
    parameter ADDR_W = 4,           //apb byte address.
    parameter DATA_W = 32
    )(
    //uart.
    input  wire uart_clk,
    input  wire uart_rx,    //uart receive.
    output wire uart_tx,    //uart transmit.

    //apb.
    input  wire              pclk,
    input  wire              prstn, 
    input  wire              penable,
    input  wire              pwrite,
    input  wire              psel,
    input  wire [ADDR_W-1:0] paddr,
    input  wire [DATA_W-1:0] pwdata,
    output reg  [DATA_W-1:0] prdata,
    output wire              pready,  //tie high.
    output wire              pslverr, 

    //irq.
    output wire              uart_irq

    );

wire pwren =  penable &&  pwrite && psel;
wire prden =  penable && !pwrite && psel;

logic [31:0]    cfg_reg1;
logic [31:0]    cfg_reg2;

//config registers.
always@(posedge pclk or negedge prstn)
if(!prstn) begin
    cfg_reg1 <= 0;
    cfg_reg2 <= 0;

end
else if(pwren) begin
    case(paddr[ADDR_W-1:2])
        0 : cfg_reg1 <= pwdata;
        1 : cfg_reg2 <= pwdata;
        default    : ;
    endcase
end

//read.
always@(prden)
begin
    case(paddr[ADDR_W-1:2])
        0  : prdata <= cfg_reg1;
        0  : prdata <= cfg_reg2;
        default:      prdata <= 'd0;
    endcase
end



endmodule
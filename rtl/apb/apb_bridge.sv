
// uart
`define PS1_BASE_START 32'h40010000
`define PS1_BASE_END   32'h40010fff
// Timer
`define PS2_BASE_START 32'h40011000
`define PS2_BASE_END   32'h40011fff
// PMU
`define PS3_BASE_START 32'h40012000
`define PS3_BASE_END   32'h40012fff
//GPIO
`define PS4_BASE_START 32'h40013000
`define PS4_BASE_END   32'h40013fff
//STimer
`define PS5_BASE_START 32'h40014000
`define PS5_BASE_END   32'h40014fff
//CLKGEN
`define PS6_BASE_START 32'h40015000
`define PS6_BASE_END   32'h40015fff
//SMPU
`define PS7_BASE_START 32'h40016000
`define PS7_BASE_END   32'h40016fff
//SMPU
`define PS8_BASE_START 32'h40017000
`define PS8_BASE_END   32'h40017fff


module apb_bridge (
  input     logic   clk,
  input     logic   rstn,
  ahblite_interconnection.ahblite_slave     ahbl_slave, 
  
  //apb interface
  output    logic [31:0]    paddr,
  output    logic           penable,
  output    logic [31:0]    pwdata,
  output    logic           pwrite,
  input     logic [31:0]    prdata_s1,
  input     logic [31:0]    prdata_s2,
  input     logic [31:0]    prdata_s3,
  input     logic [31:0]    prdata_s4,
  input     logic [31:0]    prdata_s5,
  input     logic [31:0]    prdata_s6,
  input     logic [31:0]    prdata_s7,
  input     logic [31:0]    prdata_s8,
  output    logic           psel_s1,
  output    logic           psel_s2,
  output    logic           psel_s3,
  output    logic           psel_s4,
  output    logic           psel_s5,
  output    logic           psel_s6,
  output    logic           psel_s7,
  output    logic           psel_s8

);

logic   [2:0]   cur_state;
logic   [2:0]   nxt_state;

logic   idle_latch;
logic   idle_r_select;
logic   enable_latch;
logic   enable_r_select;

logic   [31:0]  haddr_latch;
logic           hwrite_latch;

logic           psel;



assign ahbl_slave.hresp = 0; //always OK

parameter IDLE     = 3'b000;
parameter LATCH    = 3'b001;
parameter W_SELECT = 3'b010;
parameter R_SELECT = 3'b011;
parameter ENABLE   = 3'b100;

always @(posedge clk or negedge rstn)
begin
    if(!rstn) 
    begin
        cur_state[2:0] <= IDLE;
    end else begin
        cur_state[2:0] <= nxt_state[2:0];
    end
end

assign idle_latch       = ahbl_slave.hsel && ahbl_slave.hwrite;
assign idle_r_select    = ahbl_slave.hsel && !ahbl_slave.hwrite;
assign enable_latch     = ahbl_slave.hsel && ahbl_slave.hwrite;
assign enable_r_select  = ahbl_slave.hsel && !ahbl_slave.hwrite;

//always @(cur_state[2:0] or ahbl_slave.hsel or ahbl_slave.hwrite)
//begin
// &CombBeg; @86
always @( enable_r_select
       or idle_latch
       or idle_r_select
       or enable_latch
       or cur_state[2:0])
begin
    nxt_state[2:0] = IDLE;
    case(cur_state[2:0])
    IDLE: 
        begin
            if(idle_latch) 
            begin
                nxt_state[2:0] = LATCH;
            end
            else if(idle_r_select)
            begin
                nxt_state[2:0] = R_SELECT;
            end
            else
            begin
                nxt_state[2:0] = IDLE;
            end
        end
    LATCH: 
        begin
            nxt_state[2:0] = W_SELECT;
        end
    W_SELECT: 
        begin
            nxt_state[2:0] = ENABLE;
        end
    R_SELECT: 
        begin
            nxt_state[2:0] = ENABLE;
        end
    ENABLE: 
        begin
            if(enable_latch) 
            begin
                nxt_state[2:0] = LATCH;
            end
            else if(enable_r_select)
            begin
                nxt_state[2:0] = R_SELECT;
            end
            else
            begin
                nxt_state[2:0] = IDLE;
            end
        end
    endcase
end


always @(posedge clk or negedge rstn)
begin
    if(!rstn) 
    begin
        haddr_latch[31:0]  <= 32'b0;
        hwrite_latch       <= 1'b0;
    end
    else if(nxt_state[2:0]==LATCH) 
    begin
        haddr_latch[31:0] <= ahbl_slave.haddr[31:0];
        hwrite_latch      <= ahbl_slave.hwrite;
    end
    else 
    begin
        haddr_latch[31:0] <= haddr_latch[31:0];
        hwrite_latch      <= hwrite_latch;
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn) 
    begin
        paddr[31:0]  <= 32'b0;
        pwrite       <= 1'b0;
    end
    else if(nxt_state[2:0]==W_SELECT) 
    begin
        paddr[31:0]  <= haddr_latch[31:0];
        pwrite       <= hwrite_latch;
    end
    else if(nxt_state[2:0]==R_SELECT) 
    begin
        paddr[31:0]  <= ahbl_slave.haddr[31:0];
        pwrite       <= ahbl_slave.hwrite;
    end
    else 
    begin
        paddr[31:0]  <= paddr[31:0];
        pwrite       <= pwrite;
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn) 
    begin
        pwdata[31:0] <= 32'b0;
    end
    else if(nxt_state[2:0]==W_SELECT) 
    begin
        pwdata[31:0] <= ahbl_slave.hwdata[31:0];
    end
    else 
    begin
        pwdata[31:0] <= pwdata[31:0];
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        psel <= 1'b0;
    end
    else if(nxt_state[2:0]==W_SELECT)
    begin
        psel <= 1'b1;
    end
    else if(nxt_state[2:0]==R_SELECT)
    begin
        psel <= 1'b1;
    end
    else if(nxt_state[2:0]==ENABLE)
    begin
        psel <= 1'b1;
    end
    else
    begin
        psel <= 1'b0;
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        penable <= 1'b0;
    end
    else if(nxt_state[2:0]==ENABLE)
    begin
        penable <= 1'b1;
    end
    else
    begin
        penable <= 1'b0;
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        ahbl_slave.hready <= 1'b1;
    end
    else if(nxt_state[2:0]==LATCH)
    begin
        ahbl_slave.hready <= 1'b0;
    end
    else if(nxt_state[2:0]==W_SELECT)
    begin
        ahbl_slave.hready <= 1'b0;
    end
    else if(nxt_state[2:0]==R_SELECT)
    begin
        ahbl_slave.hready <= 1'b0;
    end
    else
    begin
        ahbl_slave.hready <= 1'b1;
    end
end

assign psel_s1 = psel && (paddr>=`PS1_BASE_START) && (paddr<=`PS1_BASE_END);
assign psel_s2 = psel && (paddr>=`PS2_BASE_START) && (paddr<=`PS2_BASE_END);
assign psel_s3 = psel && (paddr>=`PS3_BASE_START) && (paddr<=`PS3_BASE_END);
assign psel_s4 = psel && (paddr>=`PS4_BASE_START) && (paddr<=`PS4_BASE_END);
assign psel_s5 = psel && (paddr>=`PS5_BASE_START) && (paddr<=`PS5_BASE_END);
assign psel_s6 = psel && (paddr>=`PS6_BASE_START) && (paddr<=`PS6_BASE_END);
assign psel_s7 = psel && (paddr>=`PS7_BASE_START) && (paddr<=`PS7_BASE_END);
assign psel_s8 = psel && (paddr>=`PS8_BASE_START) && (paddr<=`PS8_BASE_END);


assign busy_s1 = penable && psel_s1;
assign busy_s2 = penable && psel_s2;
assign busy_s3 = penable && psel_s3;
assign busy_s4 = penable && psel_s4;
assign busy_s5 = penable && psel_s5;
assign busy_s6 = penable && psel_s6;
assign busy_s7 = penable && psel_s7;
assign busy_s8 = penable && psel_s8;

// &CombBeg; @275
always @( 
    busy_s1 or 
    busy_s2 or
    busy_s3 or
    busy_s4 or
    busy_s5 or
    busy_s6 or
    busy_s7 or
    busy_s8 or
    prdata_s1[31:0] or
    prdata_s2[31:0] or
    prdata_s3[31:0] or
    prdata_s4[31:0] or
    prdata_s5[31:0] or
    prdata_s6[31:0] or
    prdata_s7[31:0] or
    prdata_s8[31:0]
)
begin
    case({busy_s1,busy_s2,busy_s3,busy_s4,busy_s5,busy_s6,busy_s7,busy_s8})
    8'b10000000:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s1[31:0];
    end
    8'b01000000:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s2[31:0];
    end
    8'b00100000:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s3[31:0];
    end
    8'b00010000:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s4[31:0];
    end
    8'b00001000:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s5[31:0];
    end
    8'b00000100:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s6[31:0];
    end
    8'b00000010:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s7[31:0];
    end
    8'b00000001:
    begin
        ahbl_slave.hrdata[31:0] = prdata_s8[31:0];
    end
    default:
    begin
        ahbl_slave.hrdata[31:0] = 32'b0;
    end
    endcase
end

endmodule
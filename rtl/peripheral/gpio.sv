module gpio 
import system_pkg::*;
#(
    parameter int unsigned PS4_BASE_START    = 32'h40013000
) 
(
  input  logic                    pclk_i,
  input  logic                    prstn_i,
  input  logic [4:0]              gpio_reg_i,
  output logic [7:0]              gpio_reg_data_o, 

  input  logic                    penable_i,
  input  logic                    pwrite_i,
  input  logic                    psel_i,
  input  logic [ADDR_WIDTH-1:0]   paddr_i,
  input  logic [DATA_WIDTH-1:0]   pwdata_i,

  output logic                    pready_o,
  output logic                    pslverr_o 
);

  reg [DATA_WIDTH-1:0] gpio_reg [31:0];
  reg [DATA_WIDTH-1:0] gpio_reg_q [31:0];

  logic [ADDR_WIDTH:0] reg_addr;
  logic [4:0] ADDR;

  
  assign reg_addr = paddr_i - PS4_BASE_START;
  assign ADDR = reg_addr[6:2];
  
  
  logic [31:0] g0;
  logic [31:0] g1;
  logic [31:0] g2;
  logic [31:0] g3;
  logic [31:0] g4;
  logic [31:0] g5;
  logic [31:0] g6;
  //logic [31:0] g7;
  
  assign g0 = gpio_reg[0];
  assign g1 = gpio_reg[1];
  assign g2 = gpio_reg[2];
  assign g3 = gpio_reg[3];
  assign g4 = gpio_reg[4];
  assign g5 = gpio_reg[5];
  assign g6 = gpio_reg[6];  
  //assign g7 = gpio_reg[7];


  wire pwren = penable_i && pwrite_i && psel_i && pready_o;
  assign pready_o = 1'b1;
  assign pslverr_o = 1'b0;

  
  always_ff @(posedge pclk_i or negedge prstn_i) begin
    if (!prstn_i) begin
      gpio_reg_q[ADDR] <= '0;
    end else if(pwren) begin
      if (pwdata_i) begin
        gpio_reg_q[ADDR] <= pwdata_i;
      end
      else begin
	gpio_reg_q[ADDR] <= 32'hffff_ffff;
      end
    end
  end
 

  assign gpio_reg[31:0] = gpio_reg_q[31:0];

  assign gpio_reg_data_o = gpio_reg[gpio_reg_i][7:0];

endmodule

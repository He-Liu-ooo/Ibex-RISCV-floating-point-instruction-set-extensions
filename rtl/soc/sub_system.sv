module sub_system
import system_pkg::*;
(
  input   logic                    sys_clk_i          ,
  input   logic                    sys_rstn_i         ,
  // interrupr signals
  input   logic   [14:0]           irq                ,
  // instruction bus,AHB-Lite
  output  logic   [ADDR_WIDTH-1:0] iahbl_haddr_o      ,
  output  logic   [2:0]            iahbl_hburst_o     ,
  output  logic                    iahbl_hmastlock_o  ,
  output  logic   [3:0]            iahbl_hprot_o      ,
  output  logic   [2:0]            iahbl_hsize_o      ,
  output  logic   [1:0]            iahbl_htrans_o     ,
  output  logic   [DATA_WIDTH-1:0] iahbl_hwdata_o     ,
  output  logic                    iahbl_hwrite_o     ,
  input   logic   [DATA_WIDTH-1:0] iahbl_hrdata_i     ,
  input   logic                    iahbl_hready_i     ,
  input   logic                    iahbl_hresp_i      ,
  // data bus,AHB-Lite
  output  logic   [ADDR_WIDTH-1:0] dahbl_haddr_o      ,
  output  logic   [2:0]            dahbl_hburst_o     ,
  output  logic                    dahbl_hmastlock_o  ,
  output  logic   [3:0]            dahbl_hprot_o      ,
  output  logic   [2:0]            dahbl_hsize_o      ,
  output  logic   [1:0]            dahbl_htrans_o     ,
  output  logic   [DATA_WIDTH-1:0] dahbl_hwdata_o     ,
  output  logic                    dahbl_hwrite_o     ,
  input   logic   [DATA_WIDTH-1:0] dahbl_hrdata_i     ,
  input   logic                    dahbl_hready_i     ,
  input   logic                    dahbl_hresp_i      
);

  //----------variable declarations----------//
  logic        clk_cpu       ;
  logic        rstn_cpu      ;
  logic        test_en       ;
  logic        instr_req     ;
  logic        instr_gnt     ;
  logic        instr_rvalid  ;
  logic        instr_err     ;
  logic        data_req      ;
  logic        data_gnt      ;
  logic        data_rvalid   ;
  logic        data_we       ;
  logic        data_err      ;
  logic        irq_software  ;
  logic        irq_timer     ;
  logic        irq_external  ;
  logic        irq_nm        ;
  logic        debug_req     ;
  logic        fetch_enable  ;
  logic        core_sleep    ;//core sleep signal
  logic [3:0]  data_be       ;
  logic [31:0] hart_id       ;
  logic [31:0] boot_addr     ;
  logic [31:0] instr_addr    ;
  logic [31:0] instr_rdata   ;
  logic [31:0] data_addr     ;
  logic [31:0] data_wdata    ;
  logic [31:0] data_rdata    ;

  // sub_system interconnect
  logic        inst_ac_valid ;// instruction address & control valid
  logic        inst_dr_valid ;// instruction data & response valid
  logic        data_ac_valid ;// data address & control valid
  logic        data_dr_valid ;// data data & response valid
  logic        data_we_d0    ;
  logic [2:0]  data_size     ;// data size
  // core interconnect
  assign clk_cpu      = sys_clk_i  ;
  assign rstn_cpu     = sys_rstn_i ;
  assign test_en      = 1'b0       ;
  assign hart_id      = 32'h0      ;
  assign boot_addr    = 32'h0      ;
  assign irq_software = 1'b0       ;
  assign irq_external = 1'b0       ;
  assign irq_nm       = 1'b0       ;
  assign debug_req    = 1'b0       ;
  assign fetch_enable = 1'b1       ;

ibex_core
#(
  .DmHaltAddr             ( 32'h00000000  ),
  .DmExceptionAddr        ( 32'h00000000  )
)
x_core
(
  .clk_i                  ( clk_cpu       ),
  .rst_ni                 ( rstn_cpu      ),
  .test_en_i              ( test_en       ),
  .hart_id_i              ( hart_id       ),
  .boot_addr_i            ( boot_addr     ),

  .instr_req_o            ( instr_req     ),
  .instr_gnt_i            ( instr_gnt     ),
  .instr_rvalid_i         ( instr_rvalid  ),
  .instr_addr_o           ( instr_addr    ),
  .instr_rdata_i          ( instr_rdata   ),
  .instr_err_i            ( instr_err     ),

  .data_req_o             ( data_req      ),
  .data_gnt_i             ( data_gnt      ),
  .data_rvalid_i          ( data_rvalid   ),
  .data_we_o              ( data_we       ),
  .data_be_o              ( data_be       ),
  .data_addr_o            ( data_addr     ),
  .data_wdata_o           ( data_wdata    ),
  .data_rdata_i           ( data_rdata    ),
  .data_err_i             ( data_err      ),

  .irq_software_i         ( irq_software  ),
  .irq_timer_i            ( irq_timer     ),
  .irq_external_i         ( irq_external  ),
  .irq_fast_i             ( irq           ),
  .irq_nm_i               ( irq_nm        ),
  .debug_req_i            ( debug_req     ),
  .fetch_enable_i         ( fetch_enable  ),
  .core_sleep_o           ( core_sleep    )
);

  // Instruction AHB-Lite Bus
  assign instr_gnt     = instr_req && iahbl_hready_i;
  assign inst_ac_valid = instr_gnt;
  always_ff@(posedge clk_cpu or negedge rstn_cpu) begin
    if(!rstn_cpu)
      inst_dr_valid <= 1'b0;
    else if(iahbl_hready_i)
      inst_dr_valid <= instr_req;
  end
  assign instr_rvalid      = inst_dr_valid&&iahbl_hready_i;
  assign instr_err         = 1'b0;
  assign iahbl_hsize_o     = 3'b010;
  assign iahbl_haddr_o     = instr_addr;
  assign iahbl_hburst_o    = 3'b000;// only support single burst mode
  assign iahbl_hmastlock_o = 1'b0;  // None lock
  assign iahbl_hprot_o     = 4'b0011;
  assign iahbl_htrans_o[0] = 1'b0; 
  assign iahbl_htrans_o[1] = instr_gnt; 
  assign iahbl_hwdata_o    = 32'h0;
  assign iahbl_hwrite_o    = 1'b0;  // only read mode
  assign instr_rdata       = inst_dr_valid ? (iahbl_hrdata_i) : 32'h0;

  // Data AHB-Lite Bus
  assign data_gnt      = (data_req&&dahbl_hready_i);
  assign data_ac_valid = data_gnt;
  always_comb begin
    case(data_be)
      4'b0001,4'b0010,4'b0100,4'b1000 : data_size = 3'b000;
      4'b0011,4'b1100                 : data_size = 3'b001;
      default                         : data_size = 3'b010;
    endcase
  end
  always_ff@(posedge clk_cpu or negedge rstn_cpu) begin
    if(!rstn_cpu)
      data_dr_valid <= 1'b0;
    else if(dahbl_hready_i)
      data_dr_valid <= data_ac_valid;
  end
  assign data_rvalid       = data_dr_valid&&dahbl_hready_i;
  assign data_err          = 1'b0;
  assign dahbl_hsize_o     = data_size;
  assign dahbl_haddr_o     = data_ac_valid ? data_addr : 32'h0;
  assign dahbl_hburst_o    = 3'b000;// only support single burst mode
  assign dahbl_hmastlock_o = 1'b0;  // None lock
  assign dahbl_hprot_o     = 4'b0011;
  assign dahbl_htrans_o[0] = 1'b0; 
  assign dahbl_htrans_o[1] = data_ac_valid; 
  assign dahbl_hwdata_o    = (data_dr_valid&&dahbl_hready_i) ? data_wdata : 32'h0;
  assign dahbl_hwrite_o    = data_we;
  always_ff@(posedge clk_cpu or negedge rstn_cpu) begin
    if(!rstn_cpu)
      data_we_d0 <= 1'b0;
    else if(data_gnt)
      data_we_d0 <= data_we;
  end
  assign data_rdata = (data_dr_valid&&dahbl_hready_i) ? dahbl_hrdata_i : 32'h0;

endmodule:sub_system

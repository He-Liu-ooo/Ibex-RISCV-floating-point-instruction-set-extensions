
module ibex_soc
    #(
        parameter              RAM_FPATH  = "",
        parameter int unsigned RAM_SIZE   = 262144,
        parameter int unsigned PLL_MUL    = 10,
        parameter int unsigned PLL_DIV    = 25
    )
    (
        input  sys_clk_i,
        input  sys_rst_ni,

        input  uart_rx_i,
        output uart_tx_o
    );


    localparam logic [31:0] MEM_START = 32'h00000000;
    localparam logic [31:0] MEM_MASK  = RAM_SIZE-1;


    logic clk_raw, pll_lock, pll_fb;
    logic clk;
//    PLLE2_BASE #(
//        .CLKIN1_PERIOD  ( 10.0        ),
//        .CLKFBOUT_MULT  ( PLL_MUL     ),
//        .CLKOUT0_DIVIDE ( PLL_DIV     )
//    ) pll_inst (
//        .CLKIN1         ( sys_clk_i   ),
//        .CLKOUT0        ( clk_raw     ),
//        .CLKOUT1        (             ),
//        .CLKOUT2        (             ),
//        .CLKOUT3        (             ),
//        .CLKOUT4        (             ),
//        .CLKOUT5        (             ),
//        .LOCKED         ( pll_lock    ),
//        .PWRDWN         ( 1'b0        ),
//        .RST            ( ~sys_rst_ni ),
//        .CLKFBOUT       ( pll_fb      ),
//        .CLKFBIN        ( pll_fb      )
//    );

    assign clk_raw = sys_clk_i;
    assign pll_lock = 1'b1;
    //BUFG clkbuf (
    //    .I ( clk_raw ),
    //    .O ( clk     )
    //);

    assign clk = clk_raw;

    logic rst_n;
    assign rst_n = sys_rst_ni & pll_lock;


    // Instruction fetch
    logic        instr_req;
    logic        instr_gnt;
    logic        instr_rvalid;
    logic [31:0] instr_addr;
    logic [31:0] instr_rdata;
    logic        instr_err;

    // Data read/write for IBEX
    logic        data_req;
    logic        data_gnt;
    logic        data_rvalid;
    logic        data_we;
    logic  [3:0] data_be;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic [31:0] data_rdata;
    logic        data_err;

    // memory access arbitration
    logic        mem_req;
    logic [31:0] mem_addr;
    logic        mem_we;
    logic  [3:0] mem_be;
    logic [31:0] mem_wdata;
    logic        sram_rvalid;
    logic [31:0] sram_rdata;
    logic        hwreg_rvalid;
    logic [31:0] hwreg_rdata;

    // Interrupts
    logic irq_timer, irq_uart_rx, irq_uart_tx;

    ibex_core #(
        .DmHaltAddr             ( 32'h00000000                      ),
        .DmExceptionAddr        ( 32'h00000000                      )
    ) u_core (
        .clk_i                  ( clk                               ),
        .rst_ni                 ( rst_n                             ),
        .test_en_i              ( 1'b0                              ),
        .hart_id_i              ( 32'b0                             ),
        .boot_addr_i            ( 32'h00000000                      ),

        .instr_req_o            ( instr_req                         ),
        .instr_gnt_i            ( instr_gnt                         ),
        .instr_rvalid_i         ( instr_rvalid                      ),
        .instr_addr_o           ( instr_addr                        ),
        .instr_rdata_i          ( instr_rdata                       ),
        .instr_err_i            ( instr_err                         ),

        .data_req_o             ( data_req                          ),
        .data_gnt_i             ( data_gnt                          ),
        .data_rvalid_i          ( data_rvalid                       ),
        .data_we_o              ( data_we                           ),
        .data_be_o              ( data_be                           ),
        .data_addr_o            ( data_addr                         ),
        .data_wdata_o           ( data_wdata                        ),
        .data_rdata_i           ( data_rdata                        ),
        .data_err_i             ( data_err                          ),

        .irq_software_i         ( 1'b0                              ),
        .irq_timer_i            ( irq_timer                         ),
        .irq_external_i         ( 1'b0                              ),
        .irq_fast_i             ( {13'b0, irq_uart_tx, irq_uart_rx} ),
        .irq_nm_i               ( 1'b0                              ),
        .debug_req_i            ( 1'b0                              ),
        .fetch_enable_i         ( 1'b1                              ),
        .core_sleep_o           (                                   )
    );


    // instr / data access arbiter
    assign data_gnt  = data_req;
    assign instr_gnt = instr_req & ~data_req;
    always_comb begin
        mem_req   = data_req | instr_req;
        mem_addr  = data_req ? data_addr : instr_addr;
        mem_we    = data_req & data_we;
        mem_be    = data_be;
        mem_wdata = data_wdata;
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_rvalid <= 1'b0;
            data_rvalid  <= 1'b0;
        end else begin
            instr_rvalid <= instr_gnt;
            data_rvalid  <= data_gnt;
        end
    end
    // fetch, load or store access faults:
    assign instr_err = instr_rvalid & (~ sram_rvalid                );
    assign data_err  = data_rvalid  & (~(sram_rvalid | hwreg_rvalid));

    assign instr_rdata = sram_rdata;
    assign data_rdata  = hwreg_rvalid ? hwreg_rdata : sram_rdata;

    ram32 #(
        .SIZE      ( RAM_SIZE / 4                                    ),
        .INIT_FILE ( RAM_FPATH                                       )
    ) u_ram (
        .clk_i     ( clk                                             ),
        .rst_ni    ( rst_n                                           ),
        .req_i     ( mem_req & ((mem_addr & ~MEM_MASK) == MEM_START) ),
        .we_i      ( mem_req & mem_we                                ),
        .be_i      ( mem_be                                          ),
        .addr_i    ( mem_addr                                        ),
        .wdata_i   ( mem_wdata                                       ),
        .rvalid_o  ( sram_rvalid                                     ),
        .rdata_o   ( sram_rdata                                      )
    );

    hwreg_iface hwregs (
        .clk_i         ( clk                                       ),
        .rst_ni        ( rst_n                                     ),
        .req_i         ( data_req & (data_addr[31:16] == 16'hFF00) ),
        .we_i          ( data_we                                   ),
        .addr_i        ( data_addr[15:0]                           ),
        .wdata_i       ( data_wdata                                ),
        .rvalid_o      ( hwreg_rvalid                              ),
        .rdata_o       ( hwreg_rdata                               ),
        .irq_timer_o   ( irq_timer                                 ),
        .uart_rx_rdy_o ( irq_uart_rx                               ),
        .uart_tx_rdy_o ( irq_uart_tx                               ),
        .rx_i          ( uart_rx_i                                 ),
        .tx_o          ( uart_tx_o                                 )
    );

endmodule



module hwreg_iface #(
        parameter int unsigned TIMER_PERIOD = 400000 // period in clk cycles
    )(
        input           clk_i,
        input           rst_ni,
        input           req_i,
        input           we_i,
        input  [15:0]   addr_i,
        input  [31:0]   wdata_i,
        output          rvalid_o,
        output [31:0]   rdata_o,

        output          irq_timer_o,
        output          uart_rx_rdy_o,
        output          uart_tx_rdy_o,

        input           rx_i,
        output          tx_o
    );

    localparam logic [7:0] ADDR_UART_DATA   = 8'h00;
    localparam logic [7:0] ADDR_UART_STATUS = 8'h01;

    localparam logic [7:0] ADDR_INTERRUPTS  = 8'h80;

    logic       uart_req;
    logic       uart_wbusy;
    logic       uart_rvalid;
    logic [7:0] uart_rdata;

    assign uart_req = req_i && addr_i[9:2] == ADDR_UART_DATA;

    uart_iface uart (
        .clk_i          ( clk_i             ),
        .we_i           ( uart_req && we_i  ),
        .wdata_i        ( wdata_i[7:0]      ),
        .wbusy_o        ( uart_wbusy        ),
        .read_i         ( uart_req && !we_i ),
        .rvalid_o       ( uart_rvalid       ),
        .rdata_o        ( uart_rdata        ),

        .rx_i           ( rx_i              ),
        .tx_o           ( tx_o              )
    );


    // Periodic timer interrupt
    logic [$clog2(TIMER_PERIOD)-1:0] timer_cnt;
    logic                            timer_irq;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            timer_cnt <= '0;
            timer_irq <= '0;
        end else begin
            if (timer_cnt != (TIMER_PERIOD - 1)) begin
                timer_cnt <= timer_cnt + 1;
            end else begin
                timer_cnt <= '0;
                timer_irq <= 1'b1; // signal timer interrupt upon counter reset
            end
            if (req_i & we_i & (addr_i[9:2] == ADDR_INTERRUPTS) & wdata_i[0]) begin
                timer_irq <= 1'b0; // clear from software
            end
        end
    end


    logic [31:0] rdata;
    logic        rvalid;

    always_ff @(posedge clk_i) begin
        unique case (addr_i[9:2])
            ADDR_UART_DATA:   rdata <= uart_rvalid ? uart_rdata : 32'hFFFFFFFF;
            ADDR_UART_STATUS: rdata <= { 30'h0, uart_rvalid, uart_wbusy };

            ADDR_INTERRUPTS:  rdata <= {31'b0, timer_irq};

            default:          rdata <= 0;
        endcase
        rvalid <= req_i;
    end

    assign rdata_o  = rdata;
    assign rvalid_o = rvalid;

    assign irq_timer_o   = timer_irq;
    assign uart_rx_rdy_o = uart_rvalid;
    assign uart_tx_rdy_o = ~uart_wbusy;
endmodule


module uart_iface (
        input           clk_i,
        input           we_i,
        input  [7:0]    wdata_i,
        output          wbusy_o,
        input           read_i,
        output          rvalid_o,
        output [7:0]    rdata_o,

        input           rx_i,
        output          tx_o
    );

    localparam UART_RX_QUEUE_LEN = 8;

    async_transmitter uart_tx (
        .clk        ( clk_i     ),
        .TxD_start  ( we_i      ),
        .TxD_data   ( wdata_i   ),
        .TxD        ( tx_o      ),
        .TxD_busy   ( wbusy_o   )
    );

    logic       rx_ready;
    logic [7:0] rx_data;

    async_receiver uart_rx (
        .clk            ( clk_i     ),
        .RxD            ( rx_i      ),
        .RxD_data_ready ( rx_ready  ),
        .RxD_data       ( rx_data   ),
        .RxD_idle       (),
        .RxD_endofpacket()
    );

    logic       rvalid [UART_RX_QUEUE_LEN-1:0] = '{default: 0};
    logic [7:0] rdata  [UART_RX_QUEUE_LEN-1:0] = '{default: 0};

    always @(posedge clk_i) begin
        if (rvalid[0] == 0) begin
            for (int i = 0; i < UART_RX_QUEUE_LEN-1; i++) begin
                rvalid[i] <= rvalid[i+1];
                rdata [i] <= rdata [i+1];
            end
            rvalid[UART_RX_QUEUE_LEN-1] <= 0;
        end

        if (rx_ready) begin
            rvalid[UART_RX_QUEUE_LEN-1] <= 1;
            rdata [UART_RX_QUEUE_LEN-1] <= rx_data;
        end
        if (rvalid[0] && read_i)
            rvalid[0] <= 0;
    end

    assign rvalid_o = rvalid[0];
    assign rdata_o = rdata[0];
endmodule



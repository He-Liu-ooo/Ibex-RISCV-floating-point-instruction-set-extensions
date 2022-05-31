
module apb
import system_pkg::*;
(
  input     logic   clk,
  input     logic   rstn,
  ahblite_interconnection.ahblite_slave     ahbl_slave, 
  

  //uart
  input     logic   uart_rx,
  output    logic   uart_tx,

  //gpio
  input     logic [4:0]  gpio_reg_i,
  output    logic [7:0]  gpio_reg_data_o,
  
  //spi/i2c...


  //irq signal
  output    logic [14:0] irq                     
);

logic           uart_irq;
assign irq = {14'b0, uart_irq};

logic [31:0]    paddr;
logic [31:0]    pwdata;
logic           penable;
logic           pwrite;
logic [31:0]    prdata_s1;
logic [31:0]    prdata_s2;
logic [31:0]    prdata_s3;
logic [31:0]    prdata_s4;
logic [31:0]    prdata_s5;
logic [31:0]    prdata_s6;
logic [31:0]    prdata_s7;
logic [31:0]    prdata_s8;
logic           psel_s1;
logic           psel_s2;
logic           psel_s3;
logic           psel_s4;
logic           psel_s5;
logic           psel_s6;
logic           psel_s7;
logic           psel_s8;

// -----------------------------------------------------------
// ----------- Instantiate apb bridge  -----------------------
// ----------------------------------------------------------- 
apb_bridge  x_apb_bridge (
    .clk        (clk        ),
    .rstn       (rstn       ),
    .ahbl_slave (ahbl_slave ),
    .paddr      (paddr      ),
    .penable    (penable    ),
    .pwdata     (pwdata     ),
    .pwrite     (pwrite     ),
    .prdata_s1  (prdata_s1  ),
    .prdata_s2  (prdata_s2  ),
    .prdata_s3  (prdata_s3  ),
    .prdata_s4  (prdata_s4  ),
    .prdata_s5  (prdata_s5  ),
    .prdata_s6  (prdata_s6  ),
    .prdata_s7  (prdata_s7  ),
    .prdata_s8  (prdata_s8  ),
    .psel_s1    (psel_s1    ),
    .psel_s2    (psel_s2    ),
    .psel_s3    (psel_s3    ),
    .psel_s4    (psel_s4    ),
    .psel_s5    (psel_s5    ),
    .psel_s6    (psel_s6    ),
    .psel_s7    (psel_s7    ),
    .psel_s8    (psel_s8    )
);



// -----------------------------------------------------------
// ----------- Instantiate uart ------------------------------
// ----------------------------------------------------------- 

uart_top x_uart_top (
    .uart_clk   (clk    ),
    .uart_rx    (uart_rx),
    .uart_tx    (uart_tx),

    .pclk       (clk    ),
    .prstn      (rstn   ),
    .penable    (penable),
    .pwrite     (pwrite ),
    .psel       (psel_s1),
    .paddr      (paddr  ),
    .pwdata     (pwdata ),

    .prdata     (prdata_s1),
    .pready     (),
    .pslverr    (),

    .uart_irq   (uart_irq)
);

// -----------------------------------------------------------
// ----------- Instantiate xxxx ------------------------------
// ----------------------------------------------------------- 
gpio x_gpio (
    .pclk_i            ( clk             ),
    .prstn_i           ( rstn            ),
    .gpio_reg_i        ( gpio_reg_i      ), 
    .gpio_reg_data_o   ( gpio_reg_data_o ), 

    .penable_i         ( penable         ),
    .pwrite_i          ( pwrite          ),
    .psel_i            ( psel_s4         ),
    .paddr_i           ( paddr           ),
    .pwdata_i          ( pwdata          ),

    .pready_o          (),
    .pslverr_o         ()
);


endmodule

/****************************************Copyright (c)**************************************************
**
**                                    _ ____      _             
**                              _ __ (_)___ \ ___| |_ __ _ _ __ 
**                             | '_ \| | __) / __| __/ _` | '__|
**                             | |_) | |/ __/\__ \ || (_| | |   
**                             | .__/|_|_____|___/\__\__,_|_|   
**                             |_|                              
**
**
**---------------------------------------File Info-----------------------------------------------------
** File name:			APB3_BFM.sv
** Last modified Date:	2020-08-31
** Last Version:		1.0
** Descriptions:		Bus Functional Model
**------------------------------------------------------------------------------------------------------
** Created by:			Author
** Created date:		2020-08-31
** Version:				1.0
** Descriptions:		The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
`timescale 1ns/1ps
`define ADDR_WIDTH 32
`include "./uart_common.h"

module APB3_BFM 
  // #(
  //   ADDR_WIDTH = 32
  // )
  (
    input  logic                         pclk,
    input  logic                         prst_n,

    output logic                         psel,
    output logic                         penable,
    output logic                         pwrite,
    output logic [`ADDR_WIDTH-1:0]        paddr,
    output logic [31:0]                  pwdata,

    input  logic [31:0]                  prdata,
    input  logic                         pready,

    // this input is not used, ignore
    input  logic                         pslverr
  );

  reg[31:0] rd_data;

  initial begin
    psel = 1'b0;
    penable = 1'b0;
    pwrite = 1'b0;
    paddr = 32'b0;
    pwdata = 32'b0;
  end

  // change the data when uart is transfering
  initial begin
    # 200
    WRITE(`CFGREG_BAUD_ADDR, 'd5208);    // config baud
    # 200
    WRITE(`CFGREG_DATA_ADDR, 2'b01);
    # 200
    WRITE(`CFGREG_STOP_ADDR, 1'b0);
    # 200 
    WRITE(`CFGREG_CHECK_ADDR, 2'b10);    // config parity   偶校验
    # 200


// =============================== without irq ====================================== //
    WRITE(`DATA_WT_ADDR, 8'b11_0011);  // 0110_0110_1
    // send first data
    # 200
    WRITE(`CFGREG_ENABLE_ADDR, 'b10);     // send enable
    # 1500000   // NOTE 此时间间隔为中断处理时间
    WRITE(`CFGREG_ENABLE_ADDR, 'b00);     // send unable

    // 1501200

    // send second data
    // NOTE the transfering interval of two data should at least 2 uart_baud_clk cycle
    # 210000
    WRITE(`DATA_WT_ADDR, 8'b10_0001);    //0100_0011_1
    # 200
    WRITE(`CFGREG_ENABLE_ADDR, 'b10);     // send enable
    # 1500000   // NOTE 此时间间隔为中断处理时间
    WRITE(`CFGREG_ENABLE_ADDR, 'b00);     // send unable

    // 3016400

    // recv enable, read first data
    # 30000
    // 3046400
    WRITE(`CFGREG_ENABLE_ADDR, 'b01);     // send enable
    # 1000000
    WRITE(`CFGREG_ENABLE_ADDR, 'b00);     // send unable 
    # 200
    APB3_READ(`DATA_RD_ADDR, rd_data);

    // 4046600

    # 150000
    // 4076600
    WRITE(`CFGREG_ENABLE_ADDR, 'b01);     // send enable
    # 1050000
    WRITE(`CFGREG_ENABLE_ADDR, 'b00);     // send unable 
    # 200
    APB3_READ(`DATA_RD_ADDR, rd_data);

    // 5076800

    # 300000
    // 5106800
    WRITE(`CFGREG_ENABLE_ADDR, 'b01);     // send enable
    # 1100000
    WRITE(`CFGREG_ENABLE_ADDR, 'b00);     // send unable 
    # 200
    APB3_READ(`DATA_RD_ADDR, rd_data);

// =============================== without irq ====================================== //

  end

  // transfer three frames of data in a row


// APB3.0 Write task
task WRITE;
  input [`ADDR_WIDTH-1:0] Wtask_Addr;
  input [31:0] Wtask_Data;//data write in
  begin   // serial execution
    psel = 0;
    penable = 0;
    // first rise edge, get data/addr/write_mode/sel bit ready
    @(posedge pclk)
    begin
      paddr = Wtask_Addr;
      pwrite = 1;
      psel = 1;
      pwdata = Wtask_Data;
    end
    // second rise edge, get enable ready
    @(posedge pclk)
    penable = 1;
    wait(pready);   // wait until pready is true
    // third rise edge, reset bits, but addr/write_mode holds
    @(posedge pclk)
    penable = 0;
    psel = 0;
    pwdata = 0;
  end
endtask
    
//APB3.0 READ task
task APB3_READ;
  input  [`ADDR_WIDTH-1:0]  Rtask_Addr;
  output [31:0]  Rtask_Data;//data read out
  begin
    psel = 0;
  	penable = 0;
  	@(posedge pclk)
  	begin
  	  paddr = Rtask_Addr;
  	  pwrite = 0;    
  	  psel = 1;
  	end
  	@(posedge pclk)
  	penable = 1;
    wait(pready);
    @(posedge pclk)
    Rtask_Data = prdata;
    penable = 0;
    psel = 0;
  end
endtask


endmodule:APB3_BFM

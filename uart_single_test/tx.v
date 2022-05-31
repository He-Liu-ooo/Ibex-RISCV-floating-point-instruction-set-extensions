// `define SINGLE_MODULE_TEST

// 使能信号在 apb 域下一个周期，同步到 uart 域下
// 若现在正在发送数据，则保持当前数据不变化
// 若现在为空闲状态，则保持 data_buffer 里的数据和 DATA 寄存器；里的数据一致

`define IDLE 0
`define START 1
`define DATA 2
`define CHECK 3
`define STOP 4
`define FINISH 5

module tx(
    input rstN,
    input pclk,   // same as baud
    input clk,
    input tx_trans_en,      // this is from config file
    input [7:0] tx_data,
    input [5:0] configs,    // {stop_bits_s, data_bits_s};  


    output reg uart_tx,                                     
    output state_out
);
// NOTE stop bit and idle bit are all set to high 

    reg [3:0] count_bit;    // record which bit is sending now, define a state machine
    reg is_idle = 1'b1;            // record whether the bus is idle
    reg done;               // set if a frame transfer is done
    reg [10:0] serial_data;
    reg send;

    reg [2:0] state;
    reg [2:0] next_state;

    reg parity;
    reg[3:0] num_of_one;
    
    wire state_out = ~is_idle;


    initial begin
        num_of_one <= 'd0;
    end

    wire [1:0] stop_bits = configs[2] ? 2'b10 : 2'b01;
    wire [3:0] total_data_bits = configs[1:0] + 5;

// ====================================================================================
// init serial_data 
// ====================================================================================
    // when orgnize serial_data, remember to reverse the whole series in the end 
    // serial_data = stop_bit MSB LSB start_bit
    always@(posedge clk or negedge rstN) begin
        if (!rstN) begin
            serial_data <= 0;
        end
        else if (is_idle) begin   // we are not transfering, keep serial_data consistent with DATA reg
            case(stop_bits)
                2'b01: begin
                case(total_data_bits)
                    'd5: serial_data <= {1'b1,tx_data[4:0],1'd0};
                    'd6: serial_data <= {1'b1,tx_data[5:0],1'd0};
                    'd7: serial_data <= {1'b1,tx_data[6:0],1'd0};
                    'd8: serial_data <= {1'b1,tx_data[7:0],1'd0};
                endcase
                end
                2'b10: begin 
                case(total_data_bits)
                    'd5: serial_data <= {2'b11,tx_data[4:0],1'd0};
                    'd6: serial_data <= {2'b11,tx_data[5:0],1'd0};
                    'd7: serial_data <= {2'b11,tx_data[6:0],1'd0};
                    'd8: serial_data <= {2'b11,tx_data[7:0],1'd0};
                endcase
                end
            endcase 
        // otherwise we keep serial data as before 
        end 
    end 

    // CONFUSED whether this is controlled by uart_clk
    // if this is controlled by uart_baud, there's no possibility of capturing tx_trans_en
    always@(posedge clk or negedge rstN) begin
        if (tx_trans_en && is_idle)  // nothing is transfering and transfer enabled, we change send
            send <= 1'b1;
        else if (done) begin    // if transfer is done, we change send into invaild and done into invalid, waiting for next transfer
            send <= 1'b0;
            done <= 1'b0;
        end
        //end  
    end

    always@(posedge clk or negedge rstN) begin
        if(!rstN) begin
            state <= `IDLE;
            next_state <= `IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always@(*) begin
        case(state) 
        `IDLE: begin
            if(send & !done) begin
                next_state = `START;
            end
            else begin
                next_state = `IDLE;
            end
        end
        `START: begin  
             next_state = `DATA;
        end
        `DATA: begin
            if(count_bit == total_data_bits-1) begin
                if(configs[5:4] == 2'b00) begin
                    next_state = `STOP;
                end
                else begin
                    next_state = `CHECK;   
                end
            end
            else begin
                next_state = `DATA;
            end
        end
        `CHECK: begin
            next_state = `STOP;
        end
        `STOP: begin
            if(count_bit == stop_bits-1) begin
                next_state = `FINISH;
            end
            else begin
                next_state = `STOP;
            end
        end
        `FINISH: begin
            next_state = `IDLE;
        end
        endcase
    end 

    always@(posedge clk or negedge rstN) begin
        if(!rstN) begin
            uart_tx <= 1'b1;   // idle is 1
            count_bit <= 'd0;

            done <= 1'b0;
            is_idle <= 1'b1;

            num_of_one <= 'd0;
        end
        else if(send & !done) begin  
            case(state)
            `IDLE: begin
                uart_tx <= 1'b1;   // 高位表示空闲
            end
            `START: begin
                uart_tx <= serial_data[0];
                is_idle <= 1'b0;   
            end
            `DATA: begin
                uart_tx <= serial_data[count_bit+1];
                count_bit <= count_bit + 1;
                if(serial_data[count_bit+1]) begin
                    num_of_one <= num_of_one + 1;
                end

                if(count_bit == total_data_bits-1 & configs[5:4] == 2'b00) begin
                    count_bit <= 1'b0;
                end
            end
            `CHECK: begin
                if(configs[5:4] == 2'b01) begin    // 奇校验
                    
                    uart_tx <= ~num_of_one[0];   // 让1的个数为奇数
                end
                else if(configs[5:4] == 2'b10) begin      // 偶校验
                    uart_tx <= num_of_one[0];
                end
                count_bit <= 1'b0;   
            end
            `STOP: begin
                count_bit <= count_bit + 1;
                uart_tx <= serial_data[total_data_bits+count_bit+1];
            end
            `FINISH: begin
                count_bit <= 1'b0;
                is_idle <= 1'b1;
                num_of_one <= 'd0;
                uart_tx <= 1'b1;
                done <= 1'b1;
            end
            endcase
        end
    end
    
endmodule
`define IDLE 0
`define START 1
`define RECV_DATA 2
`define CHECK 3
`define FINISH 5    // CONFUSED why the macro definition of FINISH in rx will be detected in tx?


module rx(
    input rstN,
    input pclk,
    input clk,
    input rx_trans_en,
    input [5:0] configs,   // configs[3] tells us whether there's an interrupt or not
    input uart_rx,

    output reg[7:0] rx_data,
    output reg state_out,
    output reg check_error
);
    reg[2:0] state;
    reg[2:0] next_state;
    
    reg parity;
    reg[3:0] num_of_one;

    reg [7:0] data_buffer;   // 当前正在接收的数据

    wire [3:0] total_data_bits = configs[1:0]+5;

    reg is_start;  // 为真则起始位判断正确，开始进入 start 阶段,冲刷多余采样点
    reg recv;      // 为真则多余的低电平采样点冲刷完毕，开始进入真正的数据接收阶段
    reg done;    // 接收完一帧数据后马上置真，直到收到接收不使能后才置假
    reg check_done;

    reg[3:0] count_start_valid;  // record among sample points, how many of them are low
    reg[3:0] count_start;   // record how many times we sample

    reg[4:0] count_empty;       // 若满十六个点则正式接收数据阶段

    reg[2:0] sample_points_sum;   // 记录6-11个采样点数值之和
    reg[4:0] count_sample_points;    // 记录当前是第几个采样点
    reg[3:0] count_bits;   // 记录当前是第几比特数据


    initial begin
        num_of_one <= 'd0;
    end

    always@(posedge pclk) begin
        if (!rx_trans_en) begin
            done <= 1'b0;    // 彻底结束
        end
    end

    // NOTE seperate sequencing and conbinational
    // state change
    always@(posedge clk or negedge rstN) begin
        if(!rstN) begin
            state <= `IDLE;
            next_state <= `IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // state jump 
    // NOTE 组合逻辑，阻塞赋值
    // 任何下述提到的变量改变都会使得状态改变
    always@(*) begin
        case(state)
        `IDLE: begin
            if(is_start) begin   // TODO 若半个波特率周期内的信号均为低，则启动接收
                next_state = `START;
            end
            else begin
                next_state = `IDLE;
            end  
        end
        `START: begin
            if(recv) begin
                next_state = `RECV_DATA;
            end
            else begin
                next_state = `START;
            end
        end
        `RECV_DATA: begin
            if(count_bits == total_data_bits) begin
                if(configs[5:4] == 2'b00) begin
                    next_state = `FINISH;
                end
                else begin 
                    next_state = `CHECK;
                end
            end
            else begin
                next_state = `RECV_DATA;
            end
        end
        `CHECK: begin
            if(check_done) begin
                next_state = `FINISH;
            end
            else begin
                next_state = `CHECK;
            end
        end
        `FINISH: begin
            next_state = `IDLE;
        end
        endcase
    end

    // control signal 
    // check whether start recving
    always@(posedge clk or negedge rstN) begin
        if(!rstN) begin
            is_start <= 1'b0;
            recv <= 1'b0;
            count_empty <= 'b0;
            count_start <= 'b0;
            count_start_valid <= 'b0;
            sample_points_sum <= 'd0;   // 记录十六个采样点各是多少
            count_sample_points <= 'd0;    // 记录当前是第几个采样点
            count_bits <= 'd0;   // 记录当前是第几比特数据

            data_buffer <= 'd0;
            done <= 1'b0;
            check_done <= 1'b0;
            num_of_one <= 'd0;
            parity <= 1'd0;
            check_error <= 1'd0;
        end
        else begin
                if (rx_trans_en & !done) begin    // 只有被使能了才能接收数据
                    case(state)
                    `IDLE: begin
                        if(uart_rx == 1'b0 && count_start != 4'd8) begin  // low and haven't finish sampling
                            count_start <= count_start + 1;
                            count_start_valid <= count_start_valid + 1;
                        end
                        else if(uart_rx == 1'b1 && count_start != 4'd8) begin  // high and haven't finished sampling
                            count_start <= count_start + 1;
                        end
                        else if(count_start == 4'd8 && count_start_valid == 4'd8) begin  // detect the start bit
                            is_start <= 1'b1;   // 是起始位，进入 START 状态开始冲刷多余零位
                            // NOTE 事实上在判断转换的时候这一位 rx 就漏检测了，此细节可以通过修改 count_empty 的阈值弥补
                            count_empty <= count_empty + 4'd8;
                            count_start_valid <= 'd0;  // 清零，重新开始下一波检测
                            count_start <= 'd0;     // 也清零
                        end
                        else if(count_start == 4'd8 && count_start_valid == 'd0) begin   // 完全不可能是起始位，清零并开始下一波检测
                            is_start <= 1'b0;    // not all the sampling points are low, dont start is_start
                            count_start <= 'd0;
                            count_start_valid <= 'd0;  // 清零，重新开始下一波检测
                            count_empty <= 'd0;     // 也清零
                        end
                        else if(count_start == 4'd8 && count_start_valid > 'd0 && count_start_valid < 'd8) begin  // 有成为起始位的潜力，要看下一波检测是否全0
                            count_empty <= count_start_valid;
                            is_start <= 1'b0;  // 不能确定是起始位
                            count_start <= 'd0;  // 清零以进行下一波检测
                            count_start_valid <= 'd0;  // 清零，重新开始下一波检测
                        end
                    end
                    `START: begin
                        state_out <= 1'b1;
                        if(count_empty < 'd13) begin
                            count_empty <= count_empty + 1;
                        end 
                        else begin   // 多余零位集满了，现在必是第一个有效数据位的上升沿
                            recv <= 1'b1;
                            count_empty <= 'd0;
                        end
                    end
                    `RECV_DATA: begin    // NOTE 这里应该是15而不是16，否则从波形来看会采17个点
                        if(count_sample_points!='d15) begin   // 采样点不到 16 个，一直采样
                            if(count_sample_points > 'd5 && count_sample_points < 'd12) begin
                                sample_points_sum <= sample_points_sum + uart_rx;
                            end
                            count_sample_points <= count_sample_points + 1;
                        end
                        else begin// 采样点满16个，判断
                            if(sample_points_sum > 'd3) begin
                                data_buffer[count_bits] <= 1'b1;
                                num_of_one <= num_of_one + 1;
                            end
                            else if(sample_points_sum < 'd3) begin
                                data_buffer[count_bits] <= 1'b0;
                            end
                            else; // TODO    若高低电平一半一半怎么办？
                            count_sample_points <= 'd0;
                            sample_points_sum <= 'd0;
                            count_bits <= count_bits + 1;
                        end
                    end
                    `CHECK: begin
                        if(count_sample_points!='d15) begin   // 采样点不到 16 个，一直采样
                            if(count_sample_points > 'd5 && count_sample_points < 'd12) begin
                                sample_points_sum <= sample_points_sum + uart_rx;
                            end
                            count_sample_points <= count_sample_points + 1;
                        end
                        else begin// 采样点满16个，判断
                            if(sample_points_sum > 'd3) begin
                                parity <= 1'b1;
                            end
                            else if(sample_points_sum < 'd3) begin
                                parity <= 1'b0;
                            end
                            else;   // TODO    若高低电平一半一半怎么办？
                            check_done <= 1'b1;
                            count_sample_points <= 'd0;
                            sample_points_sum <= 'd0;

                            if(configs[5:4] == 2'b01) begin  // 奇
                                check_error <= num_of_one[0] ^ parity;
                            end
                            else if(configs[5:4] == 2'b10) begin
                                check_error <= ~(num_of_one[0] ^ parity);
                            end
                        end
                    end
                    `FINISH: begin
                        data_buffer <= 'd0;
                        is_start <= 1'b0;
                        recv <= 1'b0;
                        count_start <= 'b0;
                        count_start_valid <= 'b0;
                        sample_points_sum <= 'd0;   // 记录十六个采样点各是多少
                        count_sample_points <= 'd0;    // 记录当前是第几个采样点
                        count_bits <= 'd0;   // 记录当前是第几比特数据
                        done <= 1'b1;
                        state_out <= 1'b0;
                        check_done <= 1'b0;
                        num_of_one <= 'd0;
                        parity <= 1'd0;

                        rx_data <= data_buffer;
                        end
                    endcase
                end
        end
    end

endmodule


    


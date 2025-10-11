`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2025 11:20:46 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx(
    input logic clk,
    input logic rst_n, // active low
    input logic i_tx_start,
    input logic [7:0] i_tx_data,
    output logic o_tx_serial, // physical pin
    output logic o_tx_busy
    );
    
    typedef enum logic [1:0] {
        IDLE, START_BIT, DATA_BITS, STOP_BIT
    } tx_states_t;
    
    tx_states_tx current_state, next_state;
    
    // Counters & Registers
    logic [7:0] data_reg;
    logic [3:0] tick_cnt;
    logic [2:0] bits_sent_reg;
    
    // Initialize our baud tick generator
    logic baud_tick;
    baud_tick_generator tick_gen (
        .clk(clk),
        .rst_n(rst_n),
        .tick(baud_tick)
    );
    
    // Sequential
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end 
    end
    
    // Logic for next state and output
     always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_tx_serial <= 1'b1;
            o_tx_busy <= 1'b0;
            data_reg <= 8'b0;
            tick_cnt <= 4'b0;
            bits_sent_reg <= 3'b0;
            
            next_state <= IDLE;
        end
        else begin
            next_state <= current_state;
            
            if (baud_tick) begin
                tick_cnt <= tick_cnt + 1;
                
                case(current_state)
                    IDLE: 
                        begin
                            o_tx_serial <= 1'b1;
                            o_tx_busy <= 1'b0;
                            if (i_tx_start) begin
                                data_reg <= i_tx_data;
                                bits_sent_reg <= 3'b0;
                                o_tx_busy <= 1'b1;
                                tick_cnt <= 4'b0;
                                
                                next_state <= START_BIT;
                            end
                        end
                        
                    START_BIT:
                        begin
                            o_tx_serial <= 1'b0;
                            if (tick_cnt == 15) begin // Pre defined by our baud tick generator
                                tick_cnt <= 4'b0;
                                next_state <= DATA_BITS;
                            end
                        end
                        
                    DATA_BITS:
                        begin
                            o_tx_serial <= data_reg[0];
                            if (tick_cnt == 15) begin
                                tick_cnt <= 4'b0;
                                data_reg <= data_reg >> 1;
                                
                                if (bits_sent_reg == 7) begin
                                    bits_sent_reg <= 0;
                                    next_state <= STOP_BIT;
                                end
                                else begin
                                    bits_sent_reg <= bits_sent_reg + 1;
                                    next_state <= DATA_BITS;
                                end
                            end
                        end
                   STOP_BIT:
                        begin
                            o_tx_serial <= 1'b1;
                            if (tick_cnt == 15) begin
                                tick_cnt <= 4'b0;
                                next_state <= IDLE;
                            end
                        end
                        
                   default:
                        begin
                            next_state <= IDLE;
                        end
                endcase
                
            end
            
        end
        
     end
    
endmodule

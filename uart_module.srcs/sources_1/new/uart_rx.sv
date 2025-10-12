`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Company:        Personal Project - UTSA
// Engineer:       Carlos Torres
// 
// Create Date:    [Date of creation]
// Design Name:    Simple UART System
// Module Name:    uart_rx
// Project Name:   FPGA Projects Portfolio
// Target Devices: Xilinx Artix-7 (Digilent Nexys A7-100T)
// Tool Versions:  Vivado 2025.1
// Description:
//   A UART Receiver module that detects a start bit, samples 8 data bits
//   serially, and validates a stop bit. It uses a 16x oversampling clock
//   to reliably sample the incoming data in the middle of each bit period.
//
// Dependencies:   
//   - baud_tick_generator.sv
//
// Revision:
//   Revision 1.00 - 10/12/2025 - Initial working version with corrected timing.
//
//////////////////////////////////////////////////////////////////////////////////



module uart_rx(
    input logic clk,
    input logic rst_n, // active-low
    input logic i_rx_serial,
    output logic [7:0] o_rx_data,
    output logic o_rx_data_valid
);

    enum logic [1:0] {
        IDLE, START_BIT, DATA_BITS, STOP_BIT
    } current_state;

    logic baud_tick;
    baud_tick_generator tick_gen (
        .clk(clk),
        .rst_n(rst_n),
        .tick(baud_tick)
    );

    logic [7:0] data_reg;
    logic [2:0] bits_received_cnt;
    logic [3:0] tick_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state     <= IDLE;
            o_rx_data         <= '0;
            o_rx_data_valid   <= 1'b0;
            tick_cnt          <= '0;
            bits_received_cnt <= '0;
            data_reg          <= '0;
        end
        else begin
            o_rx_data_valid <= 1'b0;

            case (current_state)
                IDLE: begin
                    if (i_rx_serial == 1'b0) begin
                        tick_cnt      <= '0;
                        current_state <= START_BIT;
                    end
                end

                START_BIT: begin
                    if (baud_tick) begin
                        // wait until the middle of the start bit period
                        if (tick_cnt == 7) begin
                            if (i_rx_serial == 1'b0) begin
                                tick_cnt          <= 1'b0;
                                bits_received_cnt <= 1'b0;
                                current_state     <= DATA_BITS;
                            end else begin
                                current_state <= IDLE; // False start, go back to idle
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                DATA_BITS: begin
                    if (baud_tick) begin
                        if (tick_cnt == 15) begin
                            tick_cnt <= 1'b0;
                            data_reg <= {i_rx_serial, data_reg[7:1]};

                            if (bits_received_cnt == 7) begin
                                current_state <= STOP_BIT;
                            end else begin
                                bits_received_cnt <= bits_received_cnt + 1;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                STOP_BIT: begin
                    if (baud_tick) begin
                        if (tick_cnt == 15) begin
                            o_rx_data       <= data_reg;
                            o_rx_data_valid <= 1'b1;
                            current_state   <= IDLE;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end

endmodule

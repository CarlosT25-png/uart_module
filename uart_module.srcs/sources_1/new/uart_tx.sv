`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

// Company: Personal Project - UTSA
// Engineer: Carlos Torres
// Create Date: 10/09/2025 11:20:46 PM
// Design Name: Simple UART System
// Module Name: uart_tx
// Project Name: FPGA Projects Portafolio
// Target Devices: Xilinx Artyx-7 ( Diligent Nexys A7-100T )
// Tool Versions: Vivado 2025.1
// Description: 
// A single-process FSM implementation of a UART transmitter. Supports a configurable baud rate via parameters and sends a standard 8-N-1 (8 data bits, no parity, 1 stop bit) frame
// Dependencies: baud_tick_generator.sv
// Revision 0.01 - File Created

//////////////////////////////////////////////////////////////////////////////////

module uart_tx(
    input logic clk, // clock
    input logic rst_n, // active low
    input logic i_tx_start, // start transimitting signal
    input logic [7:0] i_tx_data, // 8-bit input data
    output logic o_tx_serial, // physical output pin
    output logic o_tx_busy // signal
);

    typedef enum logic [1:0] {
        IDLE, START_BIT, DATA_BITS, STOP_BIT
    } tx_states_tx;

    tx_states_tx current_state;

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

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= 8'b0;
            bits_sent_reg <= 3'b0;
            tick_cnt <= 4'b0;

            o_tx_serial <= 1'b1;
            o_tx_busy <= 1'b0;

            current_state <= IDLE;
        end
        else begin
            if (current_state == IDLE & i_tx_start) begin
                o_tx_busy <= 1;
                data_reg <= i_tx_data;
                tick_cnt <= 0;
                current_state <= START_BIT;
            end
            else begin
                if (baud_tick) begin
                    // Signal needs to be high for 15 baud tick to be recognized as a bit
                    if (tick_cnt == 15) begin
                        tick_cnt <= 0;
                    end
                    else begin
                        tick_cnt <= tick_cnt + 1;
                    end

                    case (current_state)
                        START_BIT:
                        begin
                            o_tx_serial <= 1'b0;
                            bits_sent_reg <= 3'b0;

                            if (tick_cnt == 15) begin
                                current_state <= DATA_BITS;
                            end
                        end

                        DATA_BITS:
                        begin
                            o_tx_serial <= data_reg[0];
                            if (tick_cnt == 15) begin
                                data_reg <= data_reg >> 1;
                                bits_sent_reg <= bits_sent_reg + 1;
                                if (bits_sent_reg == 7) begin
                                    current_state <= STOP_BIT;
                                end
                            end
                        end

                        STOP_BIT:
                        begin
                            o_tx_serial <= 1'b1;
                            if (tick_cnt == 15) begin
                                o_tx_busy <= 1'b0;
                                bits_sent_reg <= 0;
                                data_reg <= 8'b0;

                                current_state <= IDLE;
                            end
                        end
                    endcase
                end
            end
        end
    end

endmodule
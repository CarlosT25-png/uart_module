`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Company:        Personal Project - UTSA
// Engineer:       Carlos Torres
// 
// Create Date:    10/06/2025 11:49:29 PM
// Design Name:    Simple UART System
// Module Name:    baud_tick_generator
// Project Name:   FPGA Projects Portfolio
// Target Devices: Xilinx Artix-7 (Digilent Nexys A7-100T)
// Tool Versions:  Vivado 2025.1
// Description:
//   Generates a single-cycle 'tick' pulse based on a system clock and 
//   configurable parameters. This module acts as a clock enable to drive 
//   slower logic, such as a UART, at a precise rate (using 16x oversampling).
//
// Dependencies:   None
//
// Revision:
//   Revision 1.00 - 10/12/2025 - Final version after debugging.
//   Revision 0.01 - 10/06/2025 - File Created
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module baud_tick_generator(
    input  logic clk,
    input  logic rst_n,
    output logic tick
);

    parameter CLK_FREQUENCY = 100_000_000;
    parameter BAUD_RATE = 9_600;
    localparam COUNTER_MAX = (CLK_FREQUENCY / (BAUD_RATE * 16)) - 1;

    logic [$clog2(COUNTER_MAX):0] counter_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 0;
            tick <= 0;
        end else begin
            if (counter_reg == COUNTER_MAX) begin
                counter_reg <= 0;
                tick <= 1;
            end else begin
                counter_reg <= counter_reg + 1;
                tick <= 0;
            end
        end
    end

endmodule


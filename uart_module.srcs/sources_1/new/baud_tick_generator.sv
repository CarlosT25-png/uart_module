`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 11:49:29 PM
// Design Name: 
// Module Name: baud_rate_generator
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


module baud_tick_generator(
    input logic clk,
    input logic rst_n, // active low reset
    
    output reg tick
    );
    
    
    parameter CLK_FREQUENCY = 100_000_000; // system clock frequency (For Basys 3 is 100Mhz)
    parameter BAUD_RATE = 9_600;           // desired baud rate
    
    localparam COUNTER_MAX = (CLK_FREQUENCY / (BAUD_RATE * 16)) - 1;
    
    // -- Internal Counter --
    reg [$clog2(COUNTER_MAX)-1:0] counter_reg;

    // -- Logic --
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 0;
            tick <= 1'b0;
        end 
        else begin
            if (counter_reg == COUNTER_MAX) begin
                counter_reg <= 0; 
                tick <= 1'b1;
            end 
            else begin
                counter_reg <= counter_reg + 1; 
                tick <= 1'b0;                   
            end
        end
    end
    
endmodule

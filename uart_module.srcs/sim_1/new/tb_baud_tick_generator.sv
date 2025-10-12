`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Company:        Personal Project - UTSA
// Engineer:       Carlos Torres
// 
// Create Date:    10/11/2025 11:59:32 PM
// Design Name:    Simple UART System
// Module Name:    tb_baud_tick_generator
// Project Name:   FPGA Projects Portfolio
// Target Devices: Simulation Only (AMD Vivado Simulator)
// Tool Versions:  Vivado 2025.1
// Description:
//   A minimal testbench to verify the functionality of the baud_tick_generator 
//   module in isolation. This testbench generates a 100 MHz clock and an 
//   active-low reset. It overrides the default BAUD_RATE parameter to test the 
//   generator at 115200 baud. The simulation runs long enough to ensure at 
//   least one 'tick' is generated.
//
// Dependencies:   
//   - baud_tick_generator.sv
//
// Revision:
//   Revision 1.00 - 10/12/2025 - Initial working version.
//   Revision 0.01 - 10/11/2025 - File Created
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module tb_baud_tick_generator();

    logic clk;
    logic rst_n;
    logic tick;

    // Use the same frequency as the DUT to calculate the period
    localparam CLK_FREQUENCY = 100_000_000;
    localparam CLK_PERIOD = 1_000_000_000 / CLK_FREQUENCY; // in ns

    baud_tick_generator #(
    .BAUD_RATE(115200)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick)
    );

    // Generate the correct clock period (10 ns for 100MHz)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = 0;

        #20;
        rst_n = 1;

        // Wait long enough for at least one tick
        // A tick will occur after (650+1)*10ns = 6510 ns
        #7000;

        $finish;
    end

endmodule

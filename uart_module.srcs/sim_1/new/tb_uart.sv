`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Company:        Personal Project - UTSA
// Engineer:       Carlos Torres
// 
// Create Date:    10/11/2025 03:47:15 PM
// Design Name:    Simple UART System
// Module Name:    tb_uart
// Project Name:   FPGA Projects Portfolio
// Target Devices: Simulation Only (AMD Vivado Simulator)
// Tool Versions:  Vivado 2025.1
// Description:
//   A testbench for the uart_tx module. This testbench generates a 100 MHz 
//   clock, provides an active-low reset, and then initiates a single-byte 
//   transmission by pulsing i_tx_start. It tests the transmission of the 
//   ASCII character 'A' (0x41) and waits for the negative edge of o_tx_busy signal before 
//   finishing the simulation.
//
// Dependencies:   
//   - uart_tx.sv
//   - baud_tick_generator.sv
//
// Revision:
//   Revision 1.00 - 10/12/2025 - Initial working version.
//   Revision 0.01 - 10/11/2025 - File Created
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module tb_uart_tx();
    logic clk, rst_n, i_tx_start;
    logic [7:0] i_tx_data;
    logic o_tx_serial, o_tx_busy;


    uart_tx dut(
        .clk(clk),
        .rst_n(rst_n),
        .i_tx_start(i_tx_start),
        .i_tx_data(i_tx_data),
        .o_tx_serial(o_tx_serial),
        .o_tx_busy(o_tx_busy)
    );

    // initialize clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        i_tx_start = 0;
        i_tx_data = 0;

        #20
        rst_n = 1;

        #20
        i_tx_start = 1;
        i_tx_data = 8'hA; // ASCII code for A

        @(negedge o_tx_serial)
        i_tx_start = 0;

        @(posedge o_tx_busy);
        // wait until tx finish
        @(negedge o_tx_busy);

        #50;
        $finish;
    end

endmodule

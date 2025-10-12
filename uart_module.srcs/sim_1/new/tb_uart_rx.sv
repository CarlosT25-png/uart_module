`timescale 1ns / 1ps

module tb_uart_rx();

    logic       clk;
    logic       rst_n;
    logic       i_rx_serial;
    logic [7:0] o_rx_data;
    logic       o_rx_data_valid;

    uart_rx dut (.*);

    parameter CLK_PERIOD = 10; 
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;
    end

    parameter BAUD_RATE = 9600;
    localparam BIT_PERIOD = 1_000_000_000 / BAUD_RATE; 

    task send_byte(input [7:0] data);
        $display("TB: Sending byte 0x%h ('%c')...", data, data);

        i_rx_serial = 1'b0;
        #(BIT_PERIOD);

        for (int i = 0; i < 8; i++) begin
            i_rx_serial = data[i];
            #(BIT_PERIOD);
        end

        // Stop bit
        i_rx_serial = 1'b1;
        #(BIT_PERIOD);

        $display("TB: Finished sending byte.");
    endtask

    initial begin
        i_rx_serial = 1'b1; 
        
        @(posedge rst_n);
        #100;

        // Test 1: Send the letter 'A'
        send_byte(8'h41); // 'A' in ASCII

        @(posedge o_rx_data_valid);
        #1;

        if (o_rx_data == 8'h41) begin
            $display("TEST PASSED: Received 0x%h ('%c') correctly.", o_rx_data, o_rx_data);
        end else begin
            $error("TEST FAILED: Expected 0x41 but received 0x%h", o_rx_data);
        end

        #1000;
        $finish;
    end

endmodule
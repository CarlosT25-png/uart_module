# UART (Universal Asynchronous Receiver-Transmitter) Module in SystemVerilog

![SystemVerilog](https://img.shields.io/badge/SystemVerilog-2E8B57?style=for-the-badge&logo=systemverilog&logoColor=white)
![Vivado](https://img.shields.io/badge/AMD_Vivado-F8981D?style=for-the-badge&logo=amd&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)

## 📖 Overview

This repository contains a synthesizable UART module written in SystemVerilog. It provides a standard, byte-oriented serial communication interface, a fundamental building block for any larger digital system or System-on-a-Chip (SoC).

The design is fully implemented and has been verified using basic testbenches to ensure correct functionality of the transmitter, receiver, and baud rate generator. The next phase for this project will focus on advanced verification and hardware implementation.

---

## ✨ Features

-   **Full-Duplex Communication:** Includes both a transmitter (TX) and a receiver (RX) for simultaneous sending and receiving.
-   **Configurable Baud Rate:** The baud rate is generated from a system clock and can be easily configured through parameters.
-   **Standard 8-N-1 Frame Format:**
    -   1 Start Bit
    -   8 Data Bits
    -   No Parity Bit
    -   1 Stop Bit
-   **Modular and Synthesizable:** Written in clean, synthesizable SystemVerilog, ready for implementation on FPGAs.

---

## 🏛️ Architecture & Modules

The UART is comprised of three core modules, which are integrated in a top-level wrapper.

<br>

![image](https'//user-images.githubusercontent.com/8936949/196024950-c68910b8-2023-45a8-944a-e4905f88451d.png')
*(A generic UART block diagram for reference)*

<br>

### Key Modules

* **`baud_rate_generator.sv`**: Generates a periodic clock enable signal (`tick`) at the specified baud rate. It uses a counter and a parameterized divisor calculated from the system clock frequency.
* **`uart_rx.sv`**: The receiver module. It oversamples the incoming serial line (`rx_in`) to detect the start bit, then samples the center of each subsequent data bit to deserialize the byte. It performs basic error checking for the stop bit.
* **`uart_tx.sv`**: The transmitter module. When a parallel byte of data is loaded, it serializes it into a standard UART frame and transmits it bit-by-bit on the `tx_out` line at the specified baud rate.
* **`uart_top.sv`**: The top-level module that instantiates and connects the baud rate generator, transmitter, and receiver into a single, cohesive UART system.

## 🚀 Getting Started & Simulation

This project was developed and simulated using **AMD Vivado ML Edition**.

1.  **Clone the Repository:**
    ```sh
    git clone [https://github.com/CarlosT25-png/uart_module.git](https://github.com/CarlosT25-png/uart_module.git)
    ```
2.  **Set up in Vivado:** Create a new project, add the source files from the `rtl/` directory, and add the testbenches from the `sim/` directory.
3.  **Run Simulation:** Set the desired testbench as the top simulation module and run a behavioral simulation to observe the module's functionality.

---

## 🔮 Future Work

While the core design is complete and functional, the next steps for this project focus on professional-grade verification and physical implementation.

-   [ ] **Advanced Verification with UVM:**
    -   Develop a complete, reusable verification environment using the **Universal Verification Methodology (UVM)**.
    -   This will include creating a UVM agent with a driver, monitor, and scoreboard to perform constrained-random testing and functional coverage analysis.
-   [ ] **Hardware Implementation:**
    -   Synthesize the design for the **Digilent Nexys A7-100T** FPGA board.
    -   Create a top-level wrapper to connect the UART's `rx_in` and `tx_out` ports to the board's USB-UART bridge.
    -   Verify the hardware by performing a loopback test and communicating with a serial terminal (e.g., PuTTY) on a PC.

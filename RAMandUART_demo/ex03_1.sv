module ex03_1(
    input           MAX10_CLK1_50,  // 50 MHz clock
    input  [1:0]    KEY,            // Buttons
    //inout  [9:0]    ARDUINO_IO,     // Header pins (unused)
    output [9:0]    LEDR,           // LEDs
    input  [9:0]    SW,             // Switches
    output [7:0]    HEX0, HEX1, HEX2, HEX3, HEX4,
    output logic    TXD
);

    // RAM signals
    logic [7:0] ram_data_in, ram_data_out;
    logic [3:0] addr;
    logic       we;

    assign ram_data_in = SW[7:0];    // Byte from switches
    assign addr = 4'd0;              // Fixed address 0 for now
    assign we = ~KEY[0];             // Active-low write when KEY[0] is pressed

    // Uart signals
    logic rst;
    logic clk;
    logic tick;
    logic trigger; 

    assign rst = ~KEY[1];
    assign clk = MAX10_CLK1_50;
    assign trigger = ~KEY[0];
    // UART signals
    wire uart_busy;
    wire uart_tx;

    // Instantiate RAM
    simple_dual_port_ram_dual_clock ram_inst (
        .data       (ram_data_in),
        .read_addr  (addr),
        .write_addr (addr),
        .we         (we),
        .read_clock (MAX10_CLK1_50),
        .write_clock(MAX10_CLK1_50),
        .q          (ram_data_out)
    );

     uart_tx uart_instance (
        .clk_50M     (clk),
        .data_raw    (ram_data_out),
        .trigger_raw (trigger),      // Always triggered
        .busy        (uart_busy),
        .serial_out  (uart_tx)
    );

    assign LEDR[7:0] = ram_data_out;
    assign LEDR[8] = 2'b00;
    assign TXD = uart_tx;
    // assign RXD = uart_tx;
    assign LEDR[9] = uart_busy;
    
    // Turn off HEX displays for now
    assign HEX0 = 8'hFF;
    assign HEX1 = 8'hFF;
    assign HEX2 = 8'hFF;
    assign HEX3 = 8'hFF;
    assign HEX4 = 8'hFF;

endmodule

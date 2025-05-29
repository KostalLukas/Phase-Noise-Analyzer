module simple_dual_port_ram_dual_clock
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)
(
    input  logic [(DATA_WIDTH-1):0]      data,
    input  logic [(ADDR_WIDTH-1):0]      read_addr, write_addr,
    input  logic                         we,
    input  logic                         read_clock, write_clock,
    output logic [(DATA_WIDTH-1):0]      q
);

    // Declare the RAM variable (and tell Quartus to use RAM blocks)
    logic [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

    // Write logic
    always_ff @ (posedge write_clock) begin
        if (we) begin
            ram[write_addr] <= data;
        end
    end

    // Read logic
    always_ff @ (posedge read_clock) begin
        q <= ram[read_addr];
    end

endmodule

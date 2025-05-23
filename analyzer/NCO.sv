// module for a numerically controlled oscillator
module NCO #(
    parameter amp = 32000
    ) (
    input logic clk,
    input logic rst,
    input logic tick, 
    input logic signed [15:0] num_i,
    output logic signed [15:0] signal_o
    );

    // phase accumulator register
    logic unsigned [15:0] phase;
    always_ff @(posedge clk)
    begin
        if (rst == 1) begin
            phase <= 0;
        end
        else begin
            phase <= phase + num_i;
        end 
    end

    // cordic algorithm using finite state machine
    logic signed [15:0] cos;
    logic signed [15:0] sin;
    CORDIC cordic(
        .clk(clk),
        .reset(rst),
        .tick(tick),

        .angle(phase),
        .x_i(amp),

        .x_o(sin),
        .y_o(cos)
    );

endmodule

    


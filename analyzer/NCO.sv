// module for a numerically controlled oscillator
module NCO #(
    parameter amp = 32000
    ) (
    input logic clk_i,
    input logic rst_i,
    input logic tick_i, 
    input logic signed [15:0] freq_i,
    input logic signed [15:0] ofst_i,
    output logic signed [15:0] signal_o
    );

    // phase accumulator register
    logic unsigned [15:0] step;
    logic unsigned [15:0] phase;
    always_ff @(posedge clk_i)
    begin
        if (rst_i == 1) begin
            step <= 13107; // 40 kHz
            phase <= 0;
        end
        else if (tick_i == 1) begin
            step <= step + freq_i;
            phase <= phase + step + ofst_i;
        end 
    end

    // cordic algorithm using finite state machine
    logic signed [15:0] signal_sin;
    logic signed [15:0] signal_cos;
    CORDIC cordic(
        .clk(clk_i),
        .reset(rst_i),
        .tick(tick_i),

        .angle(phase),
        .x_i(amp),

        .x_o(signal_sin),
        .y_o(signal_cos)
    );

    assign signal_o = signal_cos;

endmodule

    


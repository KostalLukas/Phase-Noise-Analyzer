// module for a phase locked loop
module PLL (
    input clk,
    input rst,
    input tick,
    input signal_i,
    output phase_o,
    output error_o
    );

    // mixer phase detector
    Mixer mixer(
        .lo_i(lo),
        .qlo_i(0),
        .signalr_i(signal_i),
        .signali_i(0),
        .signalr_o(phase_o),
        .signali_o()
    );

    // low pass filter
    // TODO add low pass filter here

    // numerically controlled oscillator
    logic signed [15:0] lo;
    NCO #(50) oscillator (
        .clk(clk),
        .rst(rst),
        .tick(tick), 
        .num_i(phase_o),
        .signal_o(lo)
    );

endmodule


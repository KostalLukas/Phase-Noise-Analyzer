// module for a phase locked loop
module PLL #(
    parameter offset =  0
    ) (
    input logic clk_i,
    input logic rst_i,
    input logic tick_i,
    input logic signed [15:0] signal_i,
    output logic signed [15:0] signal_o,
    output logic signed [15:0] phase_o
    );

    // mixer phase detector
    logic signed [15:0] phase;
    Mixer mixer(
        .lo_i(lo),
        .qlo_i(0),
        .signalr_i(signal_i),
        .signali_i(0),
        .signalr_o(phase),
        .signali_o()
    );

    // low pass filter (fs=200kHz, fc=100Hz, a=10dB, ft=200Hz)
   FIR #(
      .stages(229),
      .coeffs('{-0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0})
   ) filter(
        .clk_i(clk),
        .rst_i(rst),
        .tick_i(tick), 
        .signal_i(phase),
        .signal_o(phase_lp)
    );

    // numerically controlled oscillator
    logic signed [15:0] signal;
    NCO #(50) oscillator (
        .clk(clk),
        .rst(rst),
        .tick(tick), 
        .num_i(phase + offset),
        .signal_o(signal)
    );

    assign signal_o = signal;
    assign phase_o = phase; 

endmodule


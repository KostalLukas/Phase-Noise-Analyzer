// module for a phase locked loop
module PLL #(
    parameter gain = 1000, // 100 kHz
    parameter ofst = 0 // 16384
    ) (
    input logic clk_i,
    input logic rst_i,
    input logic tick_i,
    input logic signed[15:0] signal_i,
    output logic signed[15:0] signal_o,
    output logic signed[15:0] phase_o
    );

    // mixer phase detector
    logic signed[15:0] signal_mix;
    Mixer mixer(
        .lo_i(signal_nco),
        .qlo_i(0),
        .signalr_i(signal_i),
        .signali_i(0),
        .signalr_o(signal_mix),
        .signali_o()
    );

    // low pass filter (fs=200kHz, fc=100Hz, a=10dB, ft=200Hz)
    logic signed[15:0] signal_lp;
    FIR #(
      .stages(229),
      .coeffs('{0, -0, -2, -4, -6, -9, -12, -14, -16, -17, -17, -16, -13, -7, 0, 11, 26, 44, 66, 94, 126, 165, 211, 264, 324, 394, 473, 561, 661, 773, 897, 1034, 1186, 1353, 1536, 1736, 1954, 2191, 2447, 2724, 3023, 3344, 3688, 4057, 4450, 4870, 5316, 5790, 6291, 6822, 7381, 7970, 8590, 9240, 9921, 10634, 11377, 12152, 12958, 13796, 14664, 15563, 16492, 17451, 18439, 19455, 20499, 21568, 22663, 23782, 24924, 26087, 27270, 28471, 29688, 30920, 32165, 33420, 34683, 35953, 37226, 38502, 39776, 41047, 42313, 43570, 44816, 46049, 47266, 48464, 49641, 50794, 51920, 53017, 54083, 55114, 56109, 57065, 57979, 58850, 59676, 60454, 61183, 61860, 62485, 63054, 63568, 64024, 64422, 64761, 65039, 65256, 65411, 65505, 65536, 65505, 65411, 65256, 65039, 64761, 64422, 64024, 63568, 63054, 62485, 61860, 61183, 60454, 59676, 58850, 57979, 57065, 56109, 55114, 54083, 53017, 51920, 50794, 49641, 48464, 47266, 46049, 44816, 43570, 42313, 41047, 39776, 38502, 37226, 35953, 34683, 33420, 32165, 30920, 29688, 28471, 27270, 26087, 24924, 23782, 22663, 21568, 20499, 19455, 18439, 17451, 16492, 15563, 14664, 13796, 12958, 12152, 11377, 10634, 9921, 9240, 8590, 7970, 7381, 6822, 6291, 5790, 5316, 4870, 4450, 4057, 3688, 3344, 3023, 2724, 2447, 2191, 1954, 1736, 1536, 1353, 1186, 1034, 897, 773, 661, 561, 473, 394, 324, 264, 211, 165, 126, 94, 66, 44, 26, 11, 0, -7, -13, -16, -17, -17, -16, -14, -12, -9, -6, -4, -2, -0, 0})
    ) filter(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .tick_i(tick_i), 
        .signal_i(signal_mix),
        .signal_o(signal_lp)
    );

    // apply gain
    logic signed[15:0] signal_freq;
    logic signed[15:0] signal_ofst;
    always_comb begin
        signal_freq = signal_lp / 16'(5 * gain);
        signal_ofst = signal_lp / 16'(gain) + 16'(ofst);
    end

    // numerically controlled oscillator
    logic signed[15:0] signal_nco;
    NCO oscillator (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .tick_i(tick_i), 
        .freq_i(signal_freq),
        .ofst_i(signal_ofst),
        .signal_o(signal_nco)
    );

    assign signal_o = signal_nco;
    assign phase_o = signal_mix; 

endmodule


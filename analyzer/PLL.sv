// module for a phase locked loop
module PLL #(
    parameter gain = 80,
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

    // low pass filter (fs=200kHz, fc=200Hz, a=10dB, ft=200Hz)
    logic signed[15:0] signal_lp;
    FIR #(
      .stages(229),
      .coeffs('{-0, 4, 16, 37, 66, 104, 151, 206, 271, 345, 428, 522, 625, 739, 864, 1001, 1149, 1309, 1481, 1666, 1864, 2076, 2303, 2544, 2799, 3071, 3358, 3662, 3982, 4320, 4676, 5049, 5441, 5852, 6283, 6732, 7202, 7691, 8201, 8732, 9283, 9855, 10448, 11062, 11698, 12354, 13032, 13730, 14450, 15190, 15950, 16730, 17530, 18350, 19188, 20045, 20919, 21811, 22720, 23644, 24584, 25538, 26506, 27486, 28478, 29481, 30493, 31514, 32543, 33578, 34618, 35663, 36710, 37758, 38806, 39854, 40898, 41939, 42975, 44003, 45024, 46035, 47035, 48022, 48995, 49954, 50895, 51818, 52722, 53604, 54465, 55302, 56113, 56899, 57657, 58386, 59086, 59754, 60391, 60994, 61563, 62098, 62596, 63058, 63482, 63868, 64215, 64522, 64790, 65017, 65203, 65349, 65453, 65515, 65536, 65515, 65453, 65349, 65203, 65017, 64790, 64522, 64215, 63868, 63482, 63058, 62596, 62098, 61563, 60994, 60391, 59754, 59086, 58386, 57657, 56899, 56113, 55302, 54465, 53604, 52722, 51818, 50895, 49954, 48995, 48022, 47035, 46035, 45024, 44003, 42975, 41939, 40898, 39854, 38806, 37758, 36710, 35663, 34618, 33578, 32543, 31514, 30493, 29481, 28478, 27486, 26506, 25538, 24584, 23644, 22720, 21811, 20919, 20045, 19188, 18350, 17530, 16730, 15950, 15190, 14450, 13730, 13032, 12354, 11698, 11062, 10448, 9855, 9283, 8732, 8201, 7691, 7202, 6732, 6283, 5852, 5441, 5049, 4676, 4320, 3982, 3662, 3358, 3071, 2799, 2544, 2303, 2076, 1864, 1666, 1481, 1309, 1149, 1001, 864, 739, 625, 522, 428, 345, 271, 206, 151, 104, 66, 37, 16, 4, -0})
    ) filter_lp(
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
        signal_freq = signal_mix / 16'(4 * gain);
        signal_ofst = signal_mix / 16'(gain) + 16'(ofst);
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


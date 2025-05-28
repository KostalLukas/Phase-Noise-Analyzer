// main module
module Main(

   // input and output logic
   input logic MAX10_CLK1_50,      // 50 HMz clock
   input logic[1:0] KEY,           // buttons
   inout logic[9:0] ARDUINO_IO,    // header pins
   output logic[9:0] LEDR,         // LEDs
   input logic[9:0] SW,            // switches
   output logic[7:0] HEX0,         // 7 segment display
   output logic[7:0] HEX1,         // 7 segment display
   output logic[7:0] HEX2,         // 7 segment display
   output logic[7:0] HEX3,         // 7 segment display
   output logic[7:0] HEX4,         // 7 segment display
   output logic[7:0] HEX5          // 7 segment display
   );

   // internal logic for reset, clock and tick
   logic rst;
   logic clk;
   logic tick;
   logic tick_dec;

   // assign wires for reset and clock
   assign rst = !KEY[0];
   assign clk = MAX10_CLK1_50;
   
   // internal logic for ADC and DAC
   logic adc_clk;        // SPI clk
   logic adc_mosi;       // MOSI: always 1
   logic adc_cnv;        // Start conversion (SPI CS)
   logic adc_miso;       // MISO: The DAC data
   
   logic dac_clk;        // SPI clock
   logic dac_mosi;       // SPI MOSI
   logic dac_cs;         // chip select
   logic dac_reset_n;    // reset of the DAC

   // internal logic for signal processing chain
   logic signed[15:0] signal_adc;
   logic signed[15:0] signal_dac;
   logic signed[15:0] signal_dec;
   logic signed[15:0] signal_ref;
   logic signed[15:0] signal_err;
   logic signed[15:0] signal_phs;

   // display text
   always_comb begin
        HEX5 = ~8'd064; // -
        HEX4 = ~8'd115; // P
        HEX3 = ~8'd084; // N
        HEX2 = ~8'd119; // A
        HEX1 = ~8'd064; // -
   end

   // divide 50 MHz clock signal to 1 MHz for interfacing ADC and DAC
   TickGen #(50) tickGen (
      .clk_i(clk),
      .rst_i(rst),
      .tick_o(tick)
   );

   // ADC writer at 1 MHz
   AdcReader reader (
      .clk_i(clk),
      .reset_i(rst),
      .start_i(tick),
      .data_o(signal_adc),
      .spi_clk_o(adc_clk),
      .spi_mosi_o(adc_mosi),
      .cnv_o(adc_cnv),
      .spi_miso_i(adc_miso),
      .is_idle_o()
   );
   
   // CIC decimator filter (stages=4, factor=5)
   CICdec decimator (
      .clk_i(clk),
      .rst_i(rst),
      .tick_i(tick),
      .signal_i(signal_adc),
      .tick_dec_o(tick_dec),
      .signal_o(signal_dec)
   );

   // compensation filter for CIC decimator

   // phase locked loop oscillator
   PLL reference (
      .clk_i(clk),
      .rst_i(rst),
      .tick_i(tick_dec),
      .signal_i(signal_dec),
      .signal_o(signal_ref),
      .phase_o(signal_phs)
   );

   // low pass filter (fs=200kHz, fc=20kHz, a=10dB, ft=200Hz)
   logic signed [15:0] phase_lp;
   FIR #(
      .stages(229),
      .coeffs('{-0, 0, 0, 0, -0, -1, -2, -3, -3, 0, 4, 8, 10, 7, -0, -10, -19, -22, -15, 0, 20, 36, 40, 28, -0, -34, -61, -67, -45, 0, 55, 96, 105, 70, -0, -83, -146, -157, -105, 0, 122, 212, 227, 150, -0, -173, -299, -319, -210, 0, 240, 413, 439, 288, -0, -326, -558, -592, -387, 1, 435, 743, 785, 512, -1, -572, -977, -1030, -670, 1, 746, 1271, 1338, 870, -1, -966, -1645, -1731, -1125, 1, 1249, 2127, 2239, 1457, -1, -1621, -2766, -2919, -1904, 1, 2132, 3653, 3873, 2541, -1, -2883, -4980, -5330, -3536, 2, 4120, 7239, 7903, 5366, -2, -6644, -12156, -13956, -10103, 2, 15253, 32975, 49538, 61289, 65536, 61289, 49538, 32975, 15253, 2, -10103, -13956, -12156, -6644, -2, 5366, 7903, 7239, 4120, 2, -3536, -5330, -4980, -2883, -1, 2541, 3873, 3653, 2132, 1, -1904, -2919, -2766, -1621, -1, 1457, 2239, 2127, 1249, 1, -1125, -1731, -1645, -966, -1, 870, 1338, 1271, 746, 1, -670, -1030, -977, -572, -1, 512, 785, 743, 435, 1, -387, -592, -558, -326, -0, 288, 439, 413, 240, 0, -210, -319, -299, -173, -0, 150, 227, 212, 122, 0, -105, -157, -146, -83, -0, 70, 105, 96, 55, 0, -45, -67, -61, -34, -0, 28, 40, 36, 20, 0, -15, -22, -19, -10, -0, 7, 10, 8, 4, 0, -3, -3, -2, -1, -0, 0, 0, 0, -0})
   ) filter_lp (
      .clk_i(clk),
      .rst_i(rst),
      .tick_i(tick_dec),
      .signal_i(signal_phs),
      .signal_o()
   );

   // shot controller
   logic shot;

   // FIFO buffer

   // switch output between reference and phase
   logic signed[15:0] signal_int;
   always_comb begin
      if (SW[0] == 1) begin
         signal_int <= signal_ref;
         HEX0 = ~8'd001;
      end
      else begin
         signal_int <= signal_phs;
         HEX0 = ~8'd008;
      end
   end

   // CIC interoplator filter (stages=4, factor=5)
   CICint interpolator (
      .clk_i(clk),
      .rst_i(rst),
      .tick_dec_i(tick_dec),
      .tick_i(tick),
      .signal_i(signal_int),
      .signal_o(signal_dac)
   );

   // compensation filter for CIC interpolator

   // DAC writer at 1 MHz
   DacWriter writer (
      .clk_i(clk),
      .reset_i(rst),
      .start_i(tick),
      .data_i(signal_dac),
      .spi_clk_o(dac_clk),
      .spi_mosi_o(dac_mosi),
      .spi_cs_o(dac_cs),
      .dac_reset_no(dac_reset_n),
      .is_idle_o()
   );   
   
   // assign wiresthe ADC &  DAC to the FPGA via Arduino pins
   assign ARDUINO_IO[0] = dac_cs;
   assign ARDUINO_IO[1] = dac_clk;
   assign ARDUINO_IO[2] = dac_mosi;
   assign ARDUINO_IO[3] = dac_reset_n;
   
   assign ARDUINO_IO[4] = adc_cnv;
   assign ARDUINO_IO[5] = adc_clk;
   assign ARDUINO_IO[6] = adc_mosi;
   assign adc_miso = ARDUINO_IO[7];

endmodule

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
    output logic[7:0] HEX4          // 7 segment display
   );

   // internal logic for reset, clock and tick
   logic rst;
   logic clk;
   logic tick;

   // assign wires for reset and clock
   assign rst = !KEY[0]; // Pushbutton on FPGA board. Need to push this when switching filter.
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
   logic signed[15:0] phase_signal;
   logic signed[15:0] phase_error;

   // divide 50 MHz clock signal to 1 MHz for interfacing ADC and DAC
   TickGen #(50) tickGen (
      .clk_i(clk),
      .reset_i(rst),
      .tick_o(tick)
   );

   // instantiate ADC writer at 1 MHz
   AdcReader reader(
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
   
   // instantiate phase locked loop oscillator
   PLL reference(
      .clk(clk),
      .signal_i(signal_adc),
      .phase_o(phase_signal),
      .error_o(phase_error),
   );

   // instantiate DAC writer at 1 MHz
   DacWriter writer(
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

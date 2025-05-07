
// Here we define the inputs / outputs
module Main(
    input  logic         MAX10_CLK1_50,  // 50 HMz clock
    input  logic[1:0]    KEY,            // Buttons
    inout  logic[9:0]    ARDUINO_IO,     // Header pins
    output logic[9:0]    LEDR,           // LEDs
    input  logic[9:0]    SW,             // Switches
    output logic[7:0]    HEX0,           // 7-segment dieplay
    output logic[7:0]    HEX1,           // 7-segment dieplay
    output logic[7:0]    HEX2,           // 7-segment dieplay
    output logic[7:0]    HEX3,           // 7-segment dieplay
    output logic[7:0]    HEX4            // 7-segment dieplay
);
    
   // This project implements the following signal processing chain
   //
   // ADC --> CIC decimator --> FIR --> CIC interpolator --> DAC
   //
   // The ADC (and DAC) are both run at their proper update rate of 1 MHz for which their analog filters (anti-aliasing & reconstruction) were designed.
   // The CIC decimator internally lowers the sampling rate by a factor of 8 from 1 MHz down to 125 kHz
   // The FIR can compensate for the frequency response of the CIC, and additionally also do whatever filtering YOU might want
   // The CIC interpolator increasaes the sampling rate back up to 1 MHz to then feed the DAC
   // The DAC outputs the samples from the interpolator at 1 MHz
   //
   // Using these tricks, we can overcome the shortcoming of our previous design :)

   
   // Internal signals along signal processing chain
   logic signed[15:0] signal_from_adc;
   logic signed[15:0] signal_cic_decimated;
   logic signed[15:0] signal_fir_filtered;
   logic signed[15:0] signal_to_interpolator;
   logic signed[15:0] signal_cic_interpolated;
   logic signed[15:0] signal_to_dac;
   logic signed[15:0] up_i;
   logic signed[15:0] up_r;
   logic signed[15:0] down_i;
   logic signed[15:0] down_r;
   logic signed[15:0] filtered_i;
   logic signed[15:0] filtered_r;


   
   // Misc. internal signals
   logic reset;
   logic clk;
   logic tick;         //   1 MHz ticks from tick generator
   logic tick_reduced; // 125 kHz ticks from CIC decimator
    
   // Wire reset & Clk
   assign reset = !KEY[0]; // Pushbutton on FPGA board. Need to push this when switching filter.
   assign clk = MAX10_CLK1_50;
   
   // Internals for ADC/DAC communication
   logic              adc_clk;        // SPI clk
   logic              adc_mosi;       // MOSI: always 1
   logic              adc_cnv;        // Start conversion (SPI CS)
   logic              adc_miso;       // MISO: The DAC data
   
   logic              dac_clk;        // SPI clock
   logic              dac_mosi;       // SPI MOSI
   logic              dac_cs;         // chip select
   logic              dac_reset_n;    // reset of the DAC
   
   
   // FIR Filter 1: CIC compensation
   parameter num_of_stages_f1 = 40; // don't need many stages to compensate for CIC
   parameter logic signed [18-1:0] coeffs_f1[num_of_stages_f1] = '{-1470, 293, 596, -3015, 4029, -5425, 1666, 2570, -12645, 16702, -19881, 6435, 10109, -39622, 52964, -53914, 8434, 64223, -162061, 164102, 164102, -162061, 64223, 8434, -53914, 52964, -39622, 10109, 6435, -19881, 16702, -12645, 2570, 1666, -5425, 4029, -3015, 596, 293, -1470};
   
   //parameter num_of_stages_f1 = 3; // don't need many stages to compensate for CIC
   //parameter logic signed [18-1:0] coeffs_f1[num_of_stages_f1] = '{0, 1000, 0};

   // Tick generator to divide the 50 MHz clock down to 1 MHz used to run the ADC & DAC
   TickGen #(50) tickGen (
      .clk_i(clk),
      .reset_i(reset),
      .tick_o(tick)
   );

   
   // Instantiate the AdcReader for communication with the ADC
   AdcReader reader(
      .clk_i(clk),
      .reset_i(reset),
      .start_i(tick),
      .data_o(signal_from_adc),
      .spi_clk_o(adc_clk),
      .spi_mosi_o(adc_mosi),
      .cnv_o(adc_cnv),
      .spi_miso_i(adc_miso),
      .is_idle_o()
   );
   
   // CIC decimator to reduce the effective sampling rate by a factor of 20, from 1 MHz down to 50 kHz
   CicDecimator decimator(
      .clk_i(clk),
      .reset_i(reset),
      .tick_i(tick),
      .signal_i(signal_from_adc),
      .signal_o(signal_cic_decimated),
      .tick_reduced_o(tick_reduced)
   );
   
   // Instantiate FIR compensation filter 
   FirFSM #(
      .num_of_stages(num_of_stages_f1),
      .coeffs(coeffs_f1)
   ) fir1(
      .clk_i(clk),
      .reset_i(reset),
      .tick_i(tick_reduced),
      .signal_i(signal_cic_decimated),
      .signal_o(signal_fir_filtered)
   );

   // Instantiate the Shifter
   Shifter shifter(
      .clk(clk),
      .reset(reset),
      .tick_reduced(tick_reduced),
      .signal_fir_filtered(signal_fir_filtered),
      .down_r(down_r),
      .down_i(down_i)
   );
    
 
   
   // Instantiate the CIC Interpolator to raise the effective sampling rate back from 50 kHz up to 1 MHz
   CicInterpolator interpolator(
      .clk_i(clk),
      .reset_i(reset),
      .tick_reduced_i(tick_reduced),
      .tick_i(tick),
      .signal_i(down_r),
      //.signal_i(signal_fir_filtered),
      .signal_o(signal_cic_interpolated)
   );
   
   
   // Instantiate the DacWriter for communication with the DAC at 1 MHz
   DacWriter writer(
      .clk_i(clk),
      .reset_i(reset),
      .start_i(tick),
      .data_i(signal_cic_interpolated),
      .spi_clk_o(dac_clk),
      .spi_mosi_o(dac_mosi),
      .spi_cs_o(dac_cs),
      .dac_reset_no(dac_reset_n),
      .is_idle_o()
   );

   always_comb begin
        HEX0 = ~8'd120; // T
        HEX1 = ~8'd113; // F
        HEX2 = ~8'd4; // I
        HEX3 = ~8'd116; // H
        HEX4 = ~8'd109; // S
   end
   
   
   // Wire the ADC &  DAC to the FPGA via Arduino pins
   assign ARDUINO_IO[0] = dac_cs;
   assign ARDUINO_IO[1] = dac_clk;
   assign ARDUINO_IO[2] = dac_mosi;
   assign ARDUINO_IO[3] = dac_reset_n;
   
   assign ARDUINO_IO[4] = adc_cnv;
   assign ARDUINO_IO[5] = adc_clk;
   assign ARDUINO_IO[6] = adc_mosi;
   assign adc_miso = ARDUINO_IO[7]; // note that the order matters!

endmodule

# Phase Noise Analyzer
#### phase noise analyzer implemented on an FPGA

### Hardware
- Terasic DE10-Lite board
- Altera MAX 10 FPGA
- AD8422 variable gain amplifier 1x, 10x, 100x
- LTC1569 low pass filter 300 kHz cutoff
- AD8137 differential ADC driver
- AD4001 ADC 16bit resolution
- FTDI 2232 USB interface

### Theory
- [Mastering Phase Noise R&S](https://www.mpdigest.com/wp-content/uploads/2020/05/Rohde_Schwarz_Phase_Noise_App_Note_Allparts.pdf)
- [UART interface](https://nandland.com/uart-serial-port-module/)
- [digital PLL](https://zipcpu.com/dsp/2017/12/14/logic-pll.html)
- [NCO](https://zipcpu.com/dsp/2017/12/09/nco.html)

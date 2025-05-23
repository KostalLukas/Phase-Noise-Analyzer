// module for a complex IQ mixer
module Mixer #(
        parameter num_of_bits_internal = 32,
        parameter num_of_bits_io       = 16
    )
    ( 
        input logic signed[num_of_bits_io-1:0] lo_i,         // LO cosine component
        input logic signed[num_of_bits_io-1:0] qlo_i,        // LO sine component
        input logic signed[num_of_bits_io-1:0] signalr_i,    // Real part of input signal
        input logic signed[num_of_bits_io-1:0] signali_i,    // Imaginary part of input signal
        output logic signed[num_of_bits_io-1:0] signalr_o,   // Real part of output signal
        output logic signed[num_of_bits_io-1:0] signali_o    // Imaginary part of output signal
    );

    // internal logic for intermediate products
    logic signed[num_of_bits_internal-1:0] product_rr;
    logic signed[num_of_bits_internal-1:0] product_ii;
    logic signed[num_of_bits_internal-1:0] product_ri;
    logic signed[num_of_bits_internal-1:0] product_ir;

    // perform multiplication
    assign product_rr = signalr_i * lo_i;
    assign product_ii = signali_i * qlo_i;
    assign product_ri = signalr_i * qlo_i;
    assign product_ir = signali_i * lo_i;

    // calculate real and imaginary outputs
    assign signalr_o = num_of_bits_io'((product_rr - product_ii) >>> (num_of_bits_internal - num_of_bits_io));
    assign signali_o = num_of_bits_io'((product_ri + product_ir) >>> (num_of_bits_internal - num_of_bits_io));

endmodule
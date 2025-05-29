// module for dividing 50 MHz clock down to 1 MHz
module TickGen #(
        parameter DIVIDER = 50
    )
    (
        input clk_i,
        input rst_i, 
        output tick_o
    );

    logic unsigned [23:0] counter;    
    always_ff @(posedge clk_i)
    begin
        if (rst_i)
            counter <= 0;
        else
            if (counter < DIVIDER)
                counter <= counter + 24'd1;
            else
                counter <= 0;
    end

    assign tick_o = (counter == 0);
    
endmodule

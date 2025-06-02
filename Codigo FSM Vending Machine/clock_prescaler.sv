`timescale 1ns / 1ps




module clock_prescaler(
                        input logic clk,
                        output logic clk_out
                       );
                
        logic [31:0]myreg;
        
        always @ (posedge clk)
                    myreg +=1;
        assign clk_out = myreg[26];
endmodule



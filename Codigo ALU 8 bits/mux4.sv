`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2025 23:23:28
// Design Name: 
// Module Name: mux4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux4(
             input logic d0,d1,d2,d3,
             input logic [1:0]s,
            output logic mux4_out 
           );
          assign mux4_out = s[1] ? (s[0]?d3:d2)
                                 : (s[0]?d1:d0);
endmodule

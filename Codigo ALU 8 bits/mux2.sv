module mux2(
            input logic d0, d1,
            input logic s,
           output logic [3:0] mux2_out
           );
        
       assign mux2_out = s ? d1 : d0;
endmodule
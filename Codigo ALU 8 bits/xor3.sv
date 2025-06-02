module xor_3a1n(input logic a1,a2,a3,output logic y2);
                wire y1;
                      assign y1 = a1 ^ a2;
                      assign y2 = ~(y1 ^ a3);
endmodule
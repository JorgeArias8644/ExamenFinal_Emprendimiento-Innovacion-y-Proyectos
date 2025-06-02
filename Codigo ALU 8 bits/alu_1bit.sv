module alu_1bit(
             input logic at,bt,
             input logic [1:0]ALUcontrol,// ALU control
            output logic result,Z,N,C,V
          );
//              señales internas
            wire int1,int2,int3,sum_out,cout_sum;
            logic n;

           assign int1 = at & bt;
           assign int2 = at | bt;
           assign int3 = ~bt;
  

//      Instanciando multiplexor 2_1                               
    mux2 mux2_1(.d0(bt),.d1(int3),.mux2_out(mym),.s(ALUcontrol[0]));
 
//      Instanciando sumador                                                                                           
    CLA  Carry_Lookahead_Adder(.a(at),.b(mym),.Cin(ALUcontrol[0]),.Sum(sum_out),.Cout(cout_sum));
                      
//      Instanciando multiplexor 4-1                             
    mux4 mux4_1(.d0(sum_out),.d1(sum_out),.d2(int1),.d3(int2),.mux4_out(result),.s(ALUcontrol));
 /*  FLags*/               
//      Instanciando xor_3-1
    xor_3a1n xor31 (.a1(at),.a2(bt),.a3(ALUcontrol[0]),.y2(V));

    always_comb begin 
       Z = ~& result;
       C = ~ALUcontrol[1] & cout_sum;
    end
               
endmodule
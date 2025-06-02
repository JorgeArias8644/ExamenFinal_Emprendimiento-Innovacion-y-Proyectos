module CLA (
                input logic a,
                input logic b,
                input logic Cin,
               output logic Sum,
               output logic Cout
                );

    // Señales de generación (G) y propagación (P)
    logic G;
    logic P;

    // Calcular G y P
    assign G = a & b;
    assign P = a ^ b;

    // Calcular Suma
    assign Sum = P ^ Cin;

    // Calcular Acarreo de Salida (Cout)
    // Cout se genera si G es alto (A y B son 1)
    // O si P es alto (uno de A o B es 1) Y hay un acarreo de entrada (Cin)
    assign Cout = G | (P & Cin);

endmodule
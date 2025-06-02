## FPGA 1
Utilizando una FPGA, implemente el boque ALU HDL diseñado en el parcial anterior pero estandarizado a 8 bits.
La implementación es en hardware real utilizando entradas y salidas reales de una placa de evaluación con una
FPGA Basys3. En la operación de suma, utilice el modulo de sumador correspondiente al rango de su ultimo
numero de carne.

- Terminacion: 4-6 Lookahead

Para el desarrollo de esta parte fue necesario crear varios modulos que deben trabajar en conjunto para lo cual se tienen los siguientes bloques de codigo

Compuerta XOR para realizar la salida de la bandera V (overflow)
~~~ SystemVerilog
module xor_3a1n(input logic a1,a2,a3,output logic y2);
                wire y1;
                      assign y1 = a1 ^ a2;
                      assign y2 = ~(y1 ^ a3);
endmodule
~~~
___

Multiplexor de 2 entradas y una salida con selector de operacion

~~~ SystemVerilog
module mux2(
            input logic d0, d1,
            input logic s,
           output logic [3:0] mux2_out
           );
        
       assign mux2_out = s ? d1 : d0;
endmodule
~~~
___





Multiplexor de 4 entradas a una salida con selector de operación
~~~ SystemVerilog
module mux4(
             input logic d0,d1,d2,d3,
             input logic [1:0]s,
            output logic mux4_out 
           );
          assign mux4_out = s[1] ? (s[0]?d3:d2)
                                 : (s[0]?d1:d0);
endmodule
~~~
___

Carrie Lookahead Adder encargado de hacer la suma de los bits

~~~ SystemVerilog
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
~~~
___

ALU 8 bits

~~~ SystemVerilog
module ALU_8bit(
                input logic [7:0]a,
                input logic [15:8]b,
                
                input logic [1:0]PB,
                /*
                ///////////////////////////
                00 | Carry-Lookahead Adder
                01 | Substract
                10 | AND
                11 | OR
                ///////////////////////////
                */
               output logic [7:0]led
                );


 
    alu_1bit alu_bit0(.at(a[0]),
                      .bt(b[8]),
                      .ALUcontrol(PB),
                      .result(led[0])
                     
                   
                      );
    
    alu_1bit alu_bit1(.at(a[1]),
                      .bt(b[9]),
                      .ALUcontrol(PB),
                      .result(led[1])
                                            
                      );    
    
    
    alu_1bit alu_bit2(
                        .at(a[2]),
                        .bt(b[10]),
                        .ALUcontrol(PB),
                        .result(led[2])
                                                
                      );    
    
    alu_1bit alu_bit3(
                        .at(a[3]),
                        .bt(b[11]),
                        .ALUcontrol(PB),
                        .result(led[3])
                      );    
    
    
    alu_1bit alu_bit4(
                        .at(a[4]),
                        .bt(b[12]),
                        .ALUcontrol(PB),
                        .result(led[4])
                      );    
    
    alu_1bit alu_bit5(
                      .at(a[5]),
                      .bt(b[13]),
                      .ALUcontrol(PB),
                      .result(led[5])
                      );    
    
    alu_1bit alu_bit6(
                      .at(a[6]),
                      .bt(b[14]),
                      .ALUcontrol(PB),
                      .result(led[6])
                      );    

    alu_1bit alu_bit7(
                       .at(a[7]),
                       .bt(b[15]),
                       .ALUcontrol(PB),
                       .result(led[7])
                       );  
endmodule

~~~

El funcionamiento de una ALU (Arithmetic Logic Unit) esta basado en el uso de compuertas que realizan operaciones las cuales se pueden agrupar para poder formar unidades aritmeticas mas grandes y potentes.
En este proyecto se realizó el diagrama propuesto en el libro *Digital Design and Computer Architecture*.

Para esto fue necesario realizar la operacion de suma utilizando el sumador de tipo Lookahead el cual tiene una ventaja sobre el full adder al tener una mayor velocidad de propagacion 
y generacion de las señales internas para realizar la suma. Este modulo se utiliza tambien para realizar la operacion de resta por lo que es necesario colocar un complemento a 2 y para esto es 
necesario colocar un multiplexor de 2 entradas y 1 salida pudiendo asi cambiar el signo de la variable ==b== para ser restada de la variable A. 

Tambien fue necesario implementar una compuerta AND que realiza la operacion de ==multiplicacion== y una compuerta OR que realiza la operacion de ==suma==.
Todas las operaciones anteriores llegan a un multiplexor de 4 entradas y una salida para obtener el resultado.

Todo lo anterior conforma un bloque de 1 bit de ALU por lo que es necesario formar un bloque con 8 bloques de 1 bit ALU para formarlo, esto se realiza de manera jerarquica de acuerdo al orden de los bits.


## Imagenes de la implementación

![CLA](https://github.com/JorgeArias8644/ExamenFinal_Emprendimiento-Innovacion-y-Proyectos/blob/main/Imagenes%20ALU/CLA.png)
![ALU 1bit](https://github.com/JorgeArias8644/ExamenFinal_Emprendimiento-Innovacion-y-Proyectos/blob/main/Imagenes%20ALU/ALU_1bit.png)
![ALU 8bits](https://github.com/JorgeArias8644/ExamenFinal_Emprendimiento-Innovacion-y-Proyectos/blob/main/Imagenes%20ALU/ALU_8bits.png)

## Video explicativo











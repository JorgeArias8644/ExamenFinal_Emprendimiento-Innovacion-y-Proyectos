

module fsm_top(
                input logic clk,
                input logic m,a,
                input logic btnC,
                input logic btnD,
                output logic d,
                output logic [2:0]p,
                output logic [2:0]c
              );
    
 logic int1_clk,int2_clk,int1,int2,m0,m1,a0,a1;
 logic [2:0]c0;
 logic [2:0]c1;
 
 
clock_prescaler clk_prsc1 (
                           .clk(clk),
                           .clk_out(int_clk)
                          );
                          
assign a0=a;
assign a1=a;
assign m0 = m;
assign m1 = m;     
 assign credit=c0;  
  assign credit=c1;
moore moore(

    .clk(int_clk),          // Señal de reloj
    .reset(btnC),       // Señal de reset asíncrona
    .m(m0),             // Input: Moneda insertada    (1 = moneda,      0 = no moneda)
    .a(a0),             // Input: Avanzar/Seleccionar (1 = seleccionar, 0 = no seleccionar)
    .dispense(d),       // Output: Dispensar producto (1 = dispensar)
    .c(c0)               // Output: Muestra el crédito acumulado (Q0.00 a Q5.00)
     );



/*

mealy_no_clock(
                .K(m0),           // Input: Moneda insertada (1 = moneda, 0 = no moneda)
                .A(a1),                // Input: Avanzar/Seleccionar (1 = seleccionar)
                .s_in(c1),         // Input: Crédito actual (que reemplaza current_state para la lógica combinacional)
                .P(p)
                );           // Output: Señales de dispensación de producto (P[1]=P1, P[0]=P0)
 */                   












    
  
   mealy mealy(
           .clk(int_clk),          // Señal de reloj
           .reset(btnD),           // Señal de reset asíncrona
           .K(m0),                  // Input: Moneda insertada (1 = moneda, 0 = no moneda)
           .A(a1),                  // Input: Avanzar/Seleccionar (1 = seleccionar)
        //   .P(p)                  // Output: Señales de dispensación de producto (P[1]=P1, P[0]=P0)
          .s_out(p)               // Output: Muestra el crédito acumulado (C2, C1, C0)
        );
            
     
     
     
     
endmodule

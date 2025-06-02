`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2025 01:25:30
// Design Name: 
// Module Name: moore
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


module moore(

    input logic clk,         // Señal de reloj
    input logic reset,       // Señal de reset asíncrona
    input logic m,           // Input: Moneda insertada (1 = moneda, 0 = no moneda)
    input logic a,           // Input: Avanzar/Seleccionar (1 = seleccionar, 0 = no seleccionar)
    output logic dispense,   // Output: Dispensar producto (1 = dispensar)
    output logic [2:0] c     // Output: Muestra el crédito acumulado (Q0.00 a Q5.00)
);

    // Definición de los estados de la FSM
    typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5} statetype;

    // Variables para el estado actual y el próximo estado
    statetype current_state, next_state;

    // --- Componente 1: Registro de Estado (Lógica Secuencial) ---
    // Este bloque actualiza el estado actual en cada flanco de reloj positivo,
    // o lo resetea a S0 si 'reset' está activo.
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0; // Reset asíncrono al estado inicial (S0)
        end else begin
            current_state <= next_state; // Transición al próximo estado
        end
    end

    // --- Componente 2: Lógica del Próximo Estado (Lógica Combinacional) ---
    // Este bloque determina el próximo estado basado en el estado actual y las entradas.
    always_comb begin
        next_state = current_state; // Por defecto, mantenerse en el estado actual
        dispense = 1'b0;            // Por defecto, no dispensar

        // Lógica de transición de estados según la tabla de verdad
        case (current_state)
            S0: begin // Estado 0: Crédito 0
                if (m == 1'b1 && a == 1'b0) begin
                    next_state = S1; // Moneda insertada, avanza a S1 (Crédito 1)
                end else if (m == 1'b0 && a == 1'b1) begin
                    // "Aceptado sin moneda, no action" - No se mueve de S0
                    next_state = S0;
                end else if (m == 1'b1 && a == 1'b1) begin
                    // "No es posible" - Se queda en S0
                    next_state = S0;
                end else begin // m=0, a=0
                    next_state = S0; // "No action, stay" - Se queda en S0
                end
            end

            S1: begin // Estado 1: Crédito 1
                if (m == 1'b1 && a == 1'b0) begin
                    next_state = S2; // Moneda insertada, avanza a S2 (Crédito 2)
                end else if (m == 1'b0 && a == 1'b1) begin
                    next_state = S0;      // Seleccionado, regresa a S0
                    dispense = 1'b1;      // Dispensar producto
                end else if (m == 1'b1 && a == 1'b1) begin
                    // "No es posible" - Se queda en S1
                    next_state = S1;
                end else begin // m=0, a=0
                    next_state = S1; // "No action, stay" - Se queda en S1
                end
            end

            S2: begin // Estado 2: Crédito 2
                if (m == 1'b1 && a == 1'b0) begin
                    next_state = S3; // Moneda insertada, avanza a S3 (Crédito 3)
                end else if (m == 1'b0 && a == 1'b1) begin
                    next_state = S0;      // Seleccionado, regresa a S0
                    dispense = 1'b1;      // Dispensar producto
                end else if (m == 1'b1 && a == 1'b1) begin
                    // "No es posible" - Se queda en S2
                    next_state = S2;
                end else begin // m=0, a=0
                    next_state = S2; // "No action, stay" - Se queda en S2
                end
            end

            S3: begin // Estado 3: Crédito 3
                if (m == 1'b1 && a == 1'b0) begin
                    next_state = S4; // Moneda insertada, avanza a S4 (Crédito 4)
                end else if (m == 1'b0 && a == 1'b1) begin
                    next_state = S0;      // Seleccionado, regresa a S0
                    dispense = 1'b1;      // Dispensar producto
                end else if (m == 1'b1 && a == 1'b1) begin
                    // "No es posible" - Se queda en S3
                    next_state = S3;
                end else begin // m=0, a=0
                    next_state = S3; // "No action, stay" - Se queda en S3
                end
            end

            S4: begin // Estado 4: Crédito 4
                if (m == 1'b1 && a == 1'b0) begin
                    next_state = S5; // Moneda insertada, avanza a S5 (Crédito 5)
                end else if (m == 1'b0 && a == 1'b1) begin
                    next_state = S0;      // Seleccionado, regresa a S0
                    dispense = 1'b1;      // Dispensar producto
                end else if (m == 1'b1 && a == 1'b1) begin
                    // "No es posible" - Se queda en S4
                    next_state = S4;
                end else begin // m=0, a=0
                    next_state = S4; // "No action, stay" - Se queda en S4
                end
            end

            S5: begin // Estado 5: Crédito 5
                if (m == 1'b0 && a == 1'b1) begin
                    next_state = S0;      // Seleccionado, regresa a S0
                    dispense = 1'b1;      // Dispensar producto
                end else if (m == 1'b1 && a == 1'b0) begin
                    next_state = S5;      // Permanece en S5, no acepta más dinero
                end else if (m == 1'b1 && a == 1'b1) begin
                    // "No es posible" - Se queda en S5
                    next_state = S5;
                end else begin // m=0, a=0
                    next_state = S5; // "No action, stay" - Se queda en S5
                end
            end

            default: begin // Estado por defecto (en caso de un estado no definido)
                next_state = S0; // Volver al estado inicial
                dispense = 1'b0;
            end
        endcase
    end

    // --- Componente 3: Lógica de Salida (Lógica Combinacional) ---
    // Este bloque mapea el estado actual a la salida de visualización de crédito.
    always_comb begin
        case (current_state)
            S0: c = 3'b000; // Q0.00
            S1: c = 3'b001; // Q1.00
            S2: c = 3'b010; // Q2.00
            S3: c = 3'b011; // Q3.00
            S4: c = 3'b100; // Q4.00
            S5: c = 3'b101; // Q5.00
            default: c = 3'b000;
        endcase
    end

endmodule
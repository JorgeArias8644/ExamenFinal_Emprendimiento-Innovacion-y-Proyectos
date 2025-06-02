`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2025 00:23:36
// Design Name: 
// Module Name: mealy
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


module mealy(


    input logic clk,         // Señal de reloj
    input logic reset,       // Señal de reset asíncrona
    input logic K,           // Input: Moneda insertada (1 = moneda, 0 = no moneda)
    input logic A,           // Input: Avanzar/Seleccionar (1 = seleccionar)
    output logic [2:0] P,    // Output: Señales de dispensación de producto (P[1]=P1, P[0]=P0)
    output logic [2:0] s_out // Output: Muestra el crédito acumulado (C2, C1, C0)
);

    // Definición de los estados de la FSM
    // Los estados S0 a S5 representan el crédito acumulado (Q0.00 a Q5.00)
    typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5} statetype;

    // Variables para el estado actual y el próximo estado
    statetype current_state, next_state;

    // --- Componente 1: Registro de Estado (Lógica Secuencial) ---
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0; // Reset asíncrono al estado inicial (S0)
        end else begin
            current_state <= next_state; // Transición al próximo estado
        end
    end

    // --- Componente 2: Lógica del Próximo Estado y Salidas (Lógica Combinacional - Mealy) ---
    always_comb begin
        // Valores por defecto para evitar latches inferidos y para las salidas
        next_state = current_state; // Por defecto, el estado no cambia
        P = 3'b000;                 // Por defecto, todas las salidas de producto están en 0
        s_out = 3'b000;             // Valor por defecto para el display, se sobrescribirá

        // Mapeo de la salida s_out (crédito) según el estado actual
        case (current_state)
            S0: s_out = 3'b000; // Q0.00
            S1: s_out = 3'b001; // Q1.00
            S2: s_out = 3'b010; // Q2.00
            S3: s_out = 3'b011; // Q3.00
            S4: s_out = 3'b100; // Q4.00
            S5: s_out = 3'b101; // Q5.00
            default: s_out = 3'b000;
        endcase


        // Lógica de transición de estados y salidas (P) basada en K y A
        case (current_state)
            S0: begin // Estado S0 (Crédito Q0.00)
                if (K == 1'b0 && A == 1'b0) begin
                    next_state = S0; // No hay entradas, permanece en S0
                end else if (K == 1'b1 && A == 1'b0) begin
                    next_state = S1; // Moneda insertada, avanza a S1
                    P[0] = 1'b1;     // Entrega P0 (Producto de Q1.00)
                end else if (K == 1'b0 && A == 1'b1) begin
                    next_state = S1; // Avanza sin moneda (según tabla, pasa a S1, es Q0.00)
                end else begin // K=1 y A=1 (según tabla, "No es posible")
                    next_state = S0;
                end
            end

            S1: begin // Estado S1 (Crédito Q1.00)
                if (K == 1'b0 && A == 1'b0) begin
                    next_state = S1; // Permanece en S1
                end else if (K == 1'b1 && A == 1'b0) begin
                    next_state = S2; // Moneda insertada, avanza a S2
                    P[0] = 1'b1;     // Entrega P0 (Producto de Q1.00 si se seleccionó)
                end else if (K == 1'b0 && A == 1'b1) begin
                    next_state = S2; // Avanza a S2 (implica un producto de Q2.00 si A fuera selección aquí)
                end else begin // K=1 y A=1 (según tabla, "No es posible")
                    next_state = S1;
                end
            end

            S2: begin // Estado S2 (Crédito Q2.00)
                if (K == 1'b0 && A == 1'b0) begin
                    next_state = S2; // Permanece en S2
                end else if (K == 1'b1 && A == 1'b0) begin
                    next_state = S3; // Moneda insertada, avanza a S3
                    P[0] = 1'b1;     // Entrega P0 (Producto de Q2.00 si se seleccionó)
                end else if (K == 1'b0 && A == 1'b1) begin
                    next_state = S3; // Avanza a S3 (implica un producto de Q3.00 si A fuera selección aquí)
                end else begin // K=1 y A=1 (según tabla, "No es posible")
                    next_state = S2;
                end
            end

            S3: begin // Estado S3 (Crédito Q3.00)
                if (K == 1'b0 && A == 1'b0) begin
                    next_state = S3; // Permanece en S3
                end else if (K == 1'b1 && A == 1'b0) begin
                    next_state = S4; // Moneda insertada, avanza a S4
                    P[0] = 1'b1;     // Entrega P0 (Producto de Q3.00 si se seleccionó)
                end else if (K == 1'b0 && A == 1'b1) begin
                    next_state = S4; // Avanza a S4 (implica un producto de Q4.00 si A fuera selección aquí)
                end else begin // K=1 y A=1 (según tabla, "No es posible")
                    next_state = S3;
                end
            end

            S4: begin // Estado S4 (Crédito Q4.00)
                if (K == 1'b0 && A == 1'b0) begin
                    next_state = S4; // Permanece en S4
                end else if (K == 1'b1 && A == 1'b0) begin
                    next_state = S5; // Moneda insertada, avanza a S5
                    P[0] = 1'b1;     // Entrega P0 (Producto de Q4.00 si se seleccionó)
                end else if (K == 1'b0 && A == 1'b1) begin
                    next_state = S5; // Avanza a S5 (implica un producto de Q5.00 si A fuera selección aquí)
                end else begin // K=1 y A=1 (según tabla, "No es posible")
                    next_state = S4;
                end
            end

            S5: begin // Estado S5 (Crédito Q5.00)
                if (K == 1'b0 && A == 1'b0) begin
                    next_state = S5; // Permanece en S5 (no puede guardar más crédito)
                end else if (K == 1'b1 && A == 1'b0) begin
                    next_state = S5; // Moneda insertada, pero ya en S5, se queda en S5.
                    P[0] = 1'b1;     // Notifica aceptación o entrega P0 (según tu descripción de la tabla)
                end else if (K == 1'b0 && A == 1'b1) begin
                    next_state = S0; // Selecciona producto de Q5.00, regresa a S0
                    P[1] = 1'b1;     // Entrega Producto P1
                end else begin // K=1 y A=1 (según tabla, "No es posible")
                    next_state = S5;
                end
            end

            default: begin // Estado por defecto (en caso de un estado no definido)
                next_state = S0; // Volver al estado inicial
                P = 3'b000;
            end
        endcase

    end // end always_comb



 
endmodule

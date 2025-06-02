## FPGA 2
Implemente en una FPGA la maquina/proceso industrial diseñado en el parcial anterior (Combinacion de FSM
Moore + Mealy). No olvide de generar un clock apropiado para apreciar la transición de estados.
Entregable: Video mostrando la ejecución de operaciones en hardware real, explicación del código y discusión
sobre la estrategia utilizado por el “compilador” de hardware para la síntesis e implementación. Comente sobre los
slices, CLBBS, LUTs, Constraints etc.

Para esta entrega se desarrolló una maquina de estado finito de tipo "Vending Machine" la cual puede recibir desde Q.1 a Q.5 y en cada opcion entregará un producto.

Productos			
|P2	|P1	|P0	|Descripcion|
| --- | --- | ---- | --- |
|0	|0|	0	|Ningun producto|
|0	|0	|1	|Entrego un chocolate pequeño|
|0	|1	|0	|Entrego un nacho|
|0	|1	|1	|Entrego una galleta|
|1	|0	|0	|Entrego una gaseosa en lata|
|1	|0	|1|	Entrego una gaseosa en botella de 450ml|

Y tambien es necesario establecer el precio de cada producto con la siguiente tabla de valores

|Credit |    Encoding|

|Credito|	C2|	C1|	C0|
|-|-|-|-|
|Q0.00	|0	|0	|0|
|Q1.00	|0	|0	|1|
|Q2.00	|0	|1	|0|
|Q3.00	|0	|1	|1|
|Q4.00	|1  |0	|0|
|Q5.00  |1  |0  |1|

Se requiere crear una maquina de estado Moore 

~~~ SystemVerilog

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
~~~

Y se requiere crear una maquina de estado Mealy

~~~ SystemVerilog
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
~~~

Y tambien es necesario realizar un codigo escalador de clock para que sea controlable ya que la placa Basys3 tiene de base 100MHz

~~~ SystemVerilog

module clock_prescaler(
                        input logic clk,
                        output logic clk_out
                       );
                
        logic [31:0]myreg;
        
        always @ (posedge clk)
                    myreg +=1;
        assign clk_out = myreg[26];
endmodule

~~~

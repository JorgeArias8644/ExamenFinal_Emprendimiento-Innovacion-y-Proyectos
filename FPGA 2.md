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
    input logic m,           // Moneda insertada
    input logic a,           // Seleccionar producto
    output logic dispense,   // Señal de dispensación
    output logic [2:0] c     // Crédito acumulado
);

    typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5} statetype;
    statetype current_state, next_state;

    // Registro de estado
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Lógica de transición y salida
    always_comb begin
        next_state = current_state;
        dispense = 1'b0;

        case (current_state)
            S0: begin
                if (m && !a) next_state = S1;
                end
            S1: begin
                if (m && !a) next_state = S2;
                else if (!m && a) begin
                    next_state = S0;
                    dispense = 1'b1;
                end
            end
            S2: begin
                if (m && !a) next_state = S3;
                else if (!m && a) begin
                    next_state = S0;
                    dispense = 1'b1;
                end
            end
            S3: begin
                if (m && !a) next_state = S4;
                else if (!m && a) begin
                    next_state = S0;
                    dispense = 1'b1;
                end
            end
            S4: begin
                if (m && !a) next_state = S5;
                else if (!m && a) begin
                    next_state = S0;
                    dispense = 1'b1;
                end
            end
            S5: begin
                if (!m && a) begin
                    next_state = S0;
                    dispense = 1'b1;
                end
            end
            default: begin
                next_state = S0;
                dispense = 1'b0;
            end
        endcase
    end

    // Lógica de salida del crédito
    always_comb begin
        case (current_state)
            S0: c = 3'b000;
            S1: c = 3'b001;
            S2: c = 3'b010;
            S3: c = 3'b011;
            S4: c = 3'b100;
            S5: c = 3'b101;
            default: c = 3'b000;
        endcase
    end
endmodule
~~~

## Descripción del Módulo "moore" 

Este módulo SystemVerilog, llamado moore, implementa una máquina de estados finita de tipo Moore. Las máquinas de Moore se distinguen porque sus salidas dependen únicamente del estado actual en el que se encuentra la máquina, no directamente de las entradas en el mismo ciclo de reloj. Este módulo parece simular la lógica de acumulación de crédito y selección en una máquina expendedora.

#### Entradas y Salidas
El módulo tiene las siguientes conexiones:

clk: La señal de reloj, que sincroniza todas las operaciones del módulo.
reset: Una señal de reinicio asíncrono que, cuando está activa, fuerza a la máquina a su estado inicial.
m (input logic): Representa la inserción de una moneda. Cuando está en 1, indica que se ha insertado una moneda.
a (input logic): Representa la selección de un producto por parte del usuario. Cuando está en 1, indica que se ha presionado un botón de selección.
dispense (output logic): Una señal de salida que se activa (1'b1) cuando la máquina ha alcanzado el crédito suficiente y el usuario ha seleccionado un producto, indicando que un producto debe ser dispensado.
c (output logic [2:0]): Representa el crédito acumulado o el código del producto seleccionado, que es una salida de 3 bits.
Estados Internos
El módulo define seis estados posibles utilizando un typedef enum logic [2:0]:

S0: Estado inicial, probablemente 0 crédito.
S1: Acumulado un nivel de crédito (por ejemplo, 1 unidad de crédito).
S2: Acumulado un segundo nivel de crédito (por ejemplo, 2 unidades de crédito).
S3: Acumulado un tercer nivel de crédito (por ejemplo, 3 unidades de crédito).
S4: Acumulado un cuarto nivel de crédito (por ejemplo, 4 unidades de crédito).
S5: Acumulado un quinto nivel de crédito (por ejemplo, 5 unidades de crédito).
Las variables current_state y next_state se usan para gestionar el estado actual y el próximo estado al que la máquina transicionará.

#### Comportamiento Lógico
El módulo se divide en tres bloques always principales, cada uno con una función específica:

Registro de Estado (always_ff):
Este bloque síncrono (always_ff @(posedge clk, posedge reset)) es responsable de actualizar el current_state en cada flanco de subida del reloj.

Si reset está activo, current_state se fuerza a S0.
De lo contrario, current_state toma el valor de next_state calculado en el ciclo anterior.
Lógica de Transición y Salida (always_comb):
Este bloque combinacional (always_comb) determina el next_state y la salida dispense basándose en el current_state y las entradas m y a.

#### Transición de Estados:

Desde S0 hasta S4: Si se inserta una moneda (m es 1) y no se ha seleccionado un producto (a es 0), la máquina avanza al siguiente estado secuencial (ej. S0 a S1, S1 a S2, etc.), acumulando crédito.
Desde S1 hasta S5: Si el usuario selecciona un producto (a es 1) y no está insertando una moneda (m es 0), la máquina regresa al estado S0 (crédito consumido/transacción completada) y se activa la señal dispense. Esto implica que se ha alcanzado suficiente crédito para una compra y se ha solicitado un producto.
El estado S5 solo permite la transición de vuelta a S0 si se selecciona un producto.
Salida dispense:
La señal dispense se activa (1'b1) solo cuando se transiciona de cualquier estado (S1 a S5) de vuelta a S0 debido a una selección de producto (a). Por defecto, dispense se mantiene en 0.

Lógica de Salida del Crédito (always_comb):
Este bloque combinacional asigna el valor de la salida c (crédito acumulado/código de producto) directamente en función del current_state. Esto es una característica clave de una máquina de Moore, ya que la salida depende únicamente del estado actual, no de las entradas directas en el mismo ciclo para la salida c.

S0 corresponde a 3'b000 (0 crédito).
S1 corresponde a 3'b001 (1 crédito).
S2 corresponde a 3'b010 (2 créditos).
S3 corresponde a 3'b011 (3 créditos).
S4 corresponde a 3'b100 (4 créditos).
S5 corresponde a 3'b101 (5 créditos).
Para cualquier estado no definido (por ejemplo, default), c se establece en 3'b000.
#### Funcionalidad General
En resumen, este módulo moore simula la acumulación de "crédito" (representado por los estados S0 a S5) en una máquina expendedora. Cada vez que se inserta una moneda (m), la máquina avanza un estado, incrementando el crédito. Cuando el usuario decide seleccionar un producto (a) y el crédito es suficiente (desde S1 hasta S5), la máquina dispensa el producto (dispense se activa) y el crédito se reinicia a cero (S0). La salida c proporciona una representación del crédito acumulado en cada momento.



___
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

// Divisor secuencial con restauracion: 4 bits / 4 bits -> cociente y residuo de 4 bits
// Mismo protocolo init/done del multiplicador_fsm.
// Division por cero: cociente = 15 y residuo = dividendo (no se bloquea).
module divisor_fsm (
    input  wire       clk,
    input  wire       rst,       // reset asincrono
    input  wire       init,      // pulso de inicio
    input  wire [3:0] DV,        // dividendo
    input  wire [3:0] DR,        // divisor
    output wire       done,
    output wire [3:0] cociente,
    output wire [3:0] residuo
);
    localparam START = 2'b00;
    localparam SHIFT = 2'b01;   // desplaza {R,Q} a la izquierda
    localparam SUB   = 2'b10;   // si R >= divisor: resta y pone un 1 en el cociente
    localparam END   = 2'b11;

    reg [1:0] state, next_state;
    reg [4:0] R;     // residuo parcial (1 bit extra para el desplazamiento)
    reg [3:0] Q;     // dividendo que se va convirtiendo en cociente
    reg [3:0] D;     // divisor
    reg [1:0] cnt;   // iteraciones restantes (4 en total)

    wire cabe    = (R >= {1'b0, D});
    wire ultima  = (cnt == 2'd0);
    wire load_dp = ((state == START) || (state == END)) && init;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= START;
        else     state <= next_state;
    end

    always @(*) begin
        case (state)
            START:   next_state = init   ? SHIFT : START;
            SHIFT:   next_state = SUB;
            SUB:     next_state = ultima ? END   : SHIFT;
            END:     next_state = init   ? SHIFT : END;
            default: next_state = START;
        endcase
    end

    assign done = (state == END);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R <= 5'd0; Q <= 4'd0; D <= 4'd0; cnt <= 2'd0;
        end else if (load_dp) begin
            R   <= 5'd0;
            Q   <= DV;
            D   <= DR;
            cnt <= 2'd3;
        end else if (state == SHIFT) begin
            R <= {R[3:0], Q[3]};
            Q <= {Q[2:0], 1'b0};
        end else if (state == SUB) begin
            if (cabe) begin
                R    <= R - {1'b0, D};
                Q[0] <= 1'b1;
            end
            cnt <= cnt - 1'b1;
        end
    end

    assign cociente = Q;
    assign residuo  = R[3:0];
endmodule

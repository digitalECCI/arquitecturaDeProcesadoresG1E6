 
module selector(
    input  [3:0] a,
    input  [3:0] b,
    input  [2:0] op,
    output reg [7:0] salidaoperacion,
    output reg signo
);
    wire [3:0] R_sumres;
    wire       Co_sumres;
 
    wire [3:0] or_res;
    wire [3:0] not_res;
    wire [3:0] exnor_res;
    wire [7:0] shift_left_res;
 
    wire Ma_cmp, I_cmp, Mb_cmp;
 
    // Sel = 0 -> suma, Sel = 1 -> resta (mismo modulo probado de sumador_restador_4bits.v)
    sumador_restador_4_bits sumares (
        .A(a),
        .B(b),
        .Sel(op[0]),
        .So(R_sumres),
        .Co(Co_sumres)
    );
 
    assign or_res    = a | b;
    assign not_res   = ~a;
    assign exnor_res = ~(a ^ b);
 

    assign shift_left_res = {a<<b};
 
    // Comparador de 4 bits (A vs B), reutilizando comparador_1bits.v
    comparador_4 comparaAB (
        .A(a),
        .B(b),
        .Ma(Ma_cmp),
        .I(I_cmp),
        .Mb(Mb_cmp)
    );
 
    always @(*) begin
        case (op)
            3'b000: begin // Suma
                salidaoperacion = {3'b000, Co_sumres, R_sumres};
                signo = 1'b0;
            end
            3'b001: begin // Resta
                salidaoperacion = {4'b0000, R_sumres};
                signo = ~Co_sumres;   // Co=0 -> hubo prestamo -> resultado negativo
            end
            3'b010: begin // OR
                salidaoperacion = {4'b0000, or_res};
                signo = 1'b0;
            end
            3'b011: begin // NOT (de A)
                salidaoperacion = {4'b0000, not_res};
                signo = 1'b0;
            end
            3'b100: begin // EXNOR
                salidaoperacion = {4'b0000, exnor_res};
                signo = 1'b0;
            end
            3'b101: begin // Corrimiento a la izquierda
                salidaoperacion = shift_left_res;
                signo = 1'b0;
            end
            3'b110: begin // Comparador: {Ma, I, Mb}
                salidaoperacion = {5'b00000, Ma_cmp, I_cmp, Mb_cmp};
                signo = 1'b0;
            end
            3'b111: begin // Reservado para multiplicacion (se resuelve en calculadora.v)
                salidaoperacion = 8'd0;
                signo = 1'b0;
            end
        endcase
    end
endmodule
 

module ALU (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] selop,
    input  wire       Cin,      // sin uso por ahora (reservado)
    input  wire       init,     // inicio de la multiplicacion
    input  wire       clk,
    input  wire       reset,
    output wire       done,     // fin de la multiplicacion
    output reg  [7:0] result,
    output wire       flag      // zero
);
    wire [3:0] suma;
    wire [7:0] multiplicacion;
    wire [3:0] comparacion;
    wire       cout_sumador;

    // Solo la operacion 001 resta (antes Cin tambien podia forzar resta)
    wire sel_suma = (selop == 3'b001);

    sumador_restador_4b uut1 (
        .a_4b(A), .b_4b(B), .sel(sel_suma),
        .s_4b(suma), .cout(cout_sumador)
    );

    multiplicador_fsm UUT (
        .clk(clk), .rst(reset), .init(init),
        .MD(A), .MR(B),
        .done(done), .product(multiplicacion)
    );

    parcial uut (.A(A), .B(B), .outcomp(comparacion));

    wire [3:0] corrimiento = A >> B;
    wire [3:0] and_result  = A & B;
    wire [3:0] or_result   = A | B;
    wire [3:0] xor_result  = A ^ B;

    always @(*) begin
        case (selop)
            3'b000: result = {4'b0000, suma};         // Suma
            3'b001: result = {4'b0000, suma};         // Resta
            3'b010: result = multiplicacion;          // Multiplicacion
            3'b011: result = {4'b0000, comparacion};  // Comparador (mayor)
            3'b100: result = {4'b0000, corrimiento};  // Corrimiento a la derecha
            3'b101: result = {4'b0000, and_result};
            3'b110: result = {4'b0000, or_result};
            3'b111: result = {4'b0000, xor_result};
            default: result = 8'b0;
        endcase
    end

    assign flag = (result == 8'b0);
endmodule

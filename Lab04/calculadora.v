
module calculadora(
    input  clk,
    input  [3:0] AA,
    input  [3:0] BB,
    input  [2:0] op,
    input        start,
    output reg [7:0] R,
    output segSignos
);
    wire [2:0] op_norm = op;

    wire [7:0] alu_result;
    wire signo;
    selector Operaci(
        .a(AA), .b(BB), .op(op_norm),
        .salidaoperacion(alu_result), .signo(signo)
    );

    // Detector de flanco de subida de 'start' (sincronizado con clk)
    // Sincroniza 'start' (2 FF) y genera un pulso REGISTRADO de 1 ciclo completo,
    // que el multiplicador (negedge) siempre alcanza a muestrear.
    reg start_s1, start_s2, start_d, init_mul;
    always @(posedge clk) begin
        start_s1 <= start;
        start_s2 <= start_s1;
        start_d  <= start_s2;
        init_mul <= start_s2 & ~start_d & (op_norm == 3'b111);
    end

    wire done_mul;
    wire [7:0] pp;
    multiplicador multip (
        .clk(clk),
        .init(init_mul),
        .MR(AA),
        .MD(BB),
        .done(done_mul),
        .pp(pp)
    );

    // Captura el resultado solo en el flanco de subida real de 'done'
    reg [7:0] R_reg;
    reg       done_mul_d;
    always @(posedge clk) done_mul_d <= done_mul;
    wire done_rise = done_mul & ~done_mul_d;
    always @(posedge clk) begin
        if (done_rise) R_reg <= pp;
    end

    always @(*) begin
        if (op_norm == 3'b111) R = R_reg;
        else                   R = alu_result;
    end

    assign segSignos = signo ? ~1'b1 : ~1'b0;
endmodule


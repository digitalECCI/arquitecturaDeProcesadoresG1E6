`timescale 1ns/1ps
// Prueba exhaustiva del divisor: los 256 casos de 4 bits / 4 bits
module tb_divisor;
    reg clk = 0, rst = 1, init = 0;
    reg  [3:0] DV = 0, DR = 0;
    wire done;
    wire [3:0] q, r;
    integer i, j, errors = 0;
    reg [3:0] eq, er;

    divisor_fsm uut (.clk(clk), .rst(rst), .init(init), .DV(DV), .DR(DR),
                     .done(done), .cociente(q), .residuo(r));

    always #10 clk = ~clk;

    initial begin
        #45 rst = 0;
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1) begin
                DV = i[3:0]; DR = j[3:0];
                @(negedge clk); init = 1;
                @(negedge clk); init = 0;
                wait (done == 1'b1);
                @(negedge clk);
                if (j == 0) begin eq = 4'd15;  er = DV;      end   // division por cero
                else        begin eq = DV / DR; er = DV % DR; end
                if (q !== eq || r !== er) begin
                    $display("[FALLO] %0d / %0d -> q=%0d r=%0d (esperado q=%0d r=%0d)", DV, DR, q, r, eq, er);
                    errors = errors + 1;
                end
            end
        $display("Divisor: 256 casos, errores = %0d", errors);
        $finish;
    end
endmodule

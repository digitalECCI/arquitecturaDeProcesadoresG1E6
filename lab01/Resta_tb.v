`timescale 1ns/1ps
`include "Resta_4bit.v"

module Resta_tb;

    reg  [3:0] A;
    reg  [3:0] B;
    wire [3:0] R_mag;
    wire signo;

    // Instancia del DUT
    Resta_4bit uut (
        .A(A),
        .B(B),
        .R_mag(R_mag),
        .signo(signo)
    );

    // Función para interpretar el resultado con signo
    function integer interpretar;
        input [3:0] mag;
        input s;
        begin
            if (s == 1)
                interpretar = -($signed({1'b0, mag}));
            else
                interpretar = $signed({1'b0, mag});
        end
    endfunction

    integer i, j; // contadores para los bucles

    initial begin
        $dumpfile("Resultado.vcd");
        $dumpvars(0, Resta_tb);

        $display(" A    B   |  R_mag   signo   Resultado");
        $display("--------------------------------------");

        // Dos bucles anidados para recorrer todas las combinaciones
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A = i; B = j;
                #5; // pequeño delay para que se propaguen las señales
                $display("%2d  %2d  |   %b     %b       %d", 
                          A, B, R_mag, signo, interpretar(R_mag, signo));
            end
        end

        $finish;
    end

endmodule

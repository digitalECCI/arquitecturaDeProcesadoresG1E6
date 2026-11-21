`include "Lab04_Multiplicador_Top.v"
`include "sumador_1bit.v"
`include "sumador_restador_4bits.v"
`timescale 1ns / 1ps


module tb_multiplicador_completo;

    // Señales hacia el DUT (Device Under Test)
    reg  [3:0] MD_tb, MR_tb;
    reg        INIT_tb, clk_tb, rst_n_tb;
    wire       DONE_tb;
    wire [6:0] HEX0_tb, HEX1_tb, HEX2_tb;

    integer casos_totales = 0;
    integer casos_ok      = 0;

    // Instancia del diseño bajo prueba
    Lab04_Multiplicador_Top uut (
        .MD(MD_tb), .MR(MR_tb), .INIT(INIT_tb),
        .clk(clk_tb), .rst_n(rst_n_tb),
        .DONE(DONE_tb),
        .HEX0(HEX0_tb), .HEX1(HEX1_tb), .HEX2(HEX2_tb)
    );

    // Reloj: periodo de 10 ns
    always #5 clk_tb = ~clk_tb;

    // Tarea para correr un caso y verificar el resultado
    task probar(input [3:0] a, input [3:0] b);
        reg [7:0] esperado;
        begin
            esperado = a * b;
            casos_totales = casos_totales + 1;

            MD_tb = a; MR_tb = b;
            #10 INIT_tb = 1;
            #10 INIT_tb = 0;

            wait (DONE_tb == 1'b1);

            if (uut.PP_reg === esperado) begin
                casos_ok = casos_ok + 1;
                $display("PASA  : %2d x %2d = %3d (esperado %3d)", a, b, uut.PP_reg, esperado);
            end else begin
                $display("FALLA : %2d x %2d = %3d (esperado %3d)  <-- ERROR", a, b, uut.PP_reg, esperado);
            end

            #20; // tiempo muerto antes del siguiente caso
        end
    endtask

    initial begin
        // Ondas para inspección visual en GTKWave/ModelSim
        $dumpfile("multiplicador_completo.vcd");
        $dumpvars(0, tb_multiplicador_completo);

        // Reset inicial
        clk_tb = 0; rst_n_tb = 0; INIT_tb = 0; MD_tb = 0; MR_tb = 0;
        #20 rst_n_tb = 1;
        #20;

        // --- Casos normales ---
        probar(4'd2,  4'd3);
        probar(4'd4,  4'd4);
        probar(4'd7,  4'd6);
        probar(4'd9,  4'd3);

        // --- Casos borde: multiplicar por 0 ---
        probar(4'd0,  4'd9);
        probar(4'd5,  4'd0);
        probar(4'd0,  4'd0);

        // --- Casos borde: multiplicar por 1 ---
        probar(4'd1,  4'd12);
        probar(4'd15, 4'd1);

        // --- Caso máximo: 15 x 15 = 225 ---
        probar(4'd15, 4'd15);

        // --- Reset a mitad de operación (robustez) ---
        MD_tb = 4'd6; MR_tb = 4'd6; INIT_tb = 1;
        #10 INIT_tb = 0;
        #7  rst_n_tb = 0;   // reset abrupto durante el cálculo
        #10 rst_n_tb = 1;
        #20;
        probar(4'd6, 4'd6); // debe seguir funcionando bien después del reset

        // --- Resumen ---
        $display("--------------------------------------------------");
        $display("RESUMEN: %0d / %0d casos correctos", casos_ok, casos_totales);
        if (casos_ok == casos_totales)
            $display("--- SIMULACION EXITOSA: TODOS LOS CASOS PASARON ---");
        else
            $display("--- SIMULACION CON ERRORES: revisa los casos marcados FALLA ---");

        $finish;
    end

endmodule
`timescale 1ns / 1ps

// ESTA LÍNEA ES LA CLAVE: Incluye tu código principal aquí
// Asegúrate de que el archivo se llame exactamente así en tu carpeta
`include "Lab04_Multiplicador_Top.v"

module Lab04_Multiplicador_tb;

    // SEÑALES
    reg [3:0] MD_tb, MR_tb;
    reg       INIT_tb, clk_tb, rst_n_tb;
    wire      DONE_tb;
    wire [6:0] HEX0_tb, HEX1_tb, HEX2_tb;

    // INSTANCIACIÓN (Aquí ya no fallará porque ya "leyó" el Top arriba)
    Lab04_Multiplicador_Top uut (
        .MD(MD_tb), .MR(MR_tb), .INIT(INIT_tb), 
        .clk(clk_tb), .rst_n(rst_n_tb), 
        .DONE(DONE_tb), 
        .HEX0(HEX0_tb), .HEX1(HEX1_tb), .HEX2(HEX2_tb)
    );

    // RELOJ: Ciclo de 10ns
    always #5 clk_tb = ~clk_tb;

    // Tarea para ejecutar los casos sin repetir código
    task probar(input [3:0] a, input [3:0] b);
        begin
            MD_tb = a; MR_tb = b;
            #10 INIT_tb = 1; #10 INIT_tb = 0;
            wait(DONE_tb == 1'b1);
            $display("RESULTADO: %d x %d = %d", a, b, uut.PP_reg);
            #20;
        end
    endtask

    initial begin
        // Generar archivo de ondas
        $dumpfile("multiplicador.vcd");
        $dumpvars(0, Lab04_Multiplicador_tb);

        // Reset
        clk_tb = 0; rst_n_tb = 0; INIT_tb = 0;
        #20 rst_n_tb = 1; #20;

        // --- LOS 10 CASOS ---
        probar(4'd2,  4'd3);   // 1
        probar(4'd5,  4'd0);   // 2
        probar(4'd0,  4'd8);   // 3
        probar(4'd7,  4'd1);   // 4
        probar(4'd1,  4'd12);  // 5
        probar(4'd4,  4'd4);   // 6
        probar(4'd9,  4'd3);   // 7
        probar(4'd10, 4'd10);  // 8
        probar(4'd15, 4'd2);   // 9
        probar(4'd15, 4'd15);  // 10

        $display("--- SIMULACIÓN EXITOSA ---");
        $finish;
    end
    endmodule
`timescale 1ns/1ps
// Testbench del procesador: ejecuta el programa de la ROM, recibe por UART la
// traza de cada instruccion (lo mismo que se ve en PuTTY) y revisa los registros.
module tb_completa;
    reg        clk = 0;
    reg        rst_n = 0;
    wire       tx;
    wire [9:0] LEDR;

    localparam SIM_BAUD = 1000000;   // 1 Mbaud solo en simulacion (hardware real: 9600)
    top #(.BAUD_RATE(SIM_BAUD)) dut (.clk(clk), .rst_n(rst_n), .tx(tx), .LEDR(LEDR));

    always #10 clk = ~clk;           // 50 MHz

    localparam BIT_T = (50000000/SIM_BAUD)*20;   // duracion de 1 bit UART en ns
    integer errors = 0;
    reg [7:0]     rx_byte;
    reg [8*48-1:0] linea;            // linea recibida, sin CR LF ni espacios finales

    task uart_rx;
        integer n;
        begin
            @(negedge tx);
            #(BIT_T/2);
            for (n = 0; n < 8; n = n + 1) begin
                #(BIT_T);
                rx_byte[n] = tx;
            end
            #(BIT_T);
            if (tx !== 1'b1) begin
                $display("[FALLO] bit de stop invalido");
                errors = errors + 1;
            end
        end
    endtask

    // Recibe caracteres hasta el LF y quita los espacios del final
    task recibir_linea;
        begin
            linea = 0;
            rx_byte = 0;
            while (rx_byte != 8'h0A) begin
                uart_rx;
                if (rx_byte != 8'h0D && rx_byte != 8'h0A)
                    linea = {linea[8*47-1:0], rx_byte};
            end
            while (linea[7:0] == 8'h20) linea = linea >> 8;
            $display("PuTTY | %0s", linea);
        end
    endtask

    task check_linea;
        input [8*48-1:0] esperada;
        begin
            recibir_linea;
            if (linea !== esperada) begin
                $display("[FALLO] esperada: %0s", esperada);
                errors = errors + 1;
            end
        end
    endtask

    task check_reg;
        input [2:0] r; input [7:0] v;
        begin
            if (dut.inst_banco.registros[r] !== v) begin
                $display("[FALLO] R%0d = %0d, esperado %0d", r, dut.inst_banco.registros[r], v);
                errors = errors + 1;
            end else
                $display("[OK]    R%0d = %0d", r, v);
        end
    endtask

    initial begin
        $dumpfile("tb_completa.vcd"); $dumpvars(0, tb_completa);
        repeat (5) @(posedge clk);
        @(negedge clk) rst_n = 1;

        // Programa de prueba completa: 15 instrucciones + HALT
        repeat (16) recibir_linea;

        wait (LEDR[9] == 1'b1);       // HALT
        repeat (5) @(posedge clk);
        $display("t=%0t  HALT", $time);

        check_reg(3'd0, 8'd0);
        check_reg(3'd1, 8'd12);
        check_reg(3'd2, 8'd10);
        check_reg(3'd3, 8'd8);
        check_reg(3'd4, 8'd14);
        check_reg(3'd5, 8'd6);
        check_reg(3'd6, 8'd12);
        check_reg(3'd7, 8'd6);

        $display("TOTAL ERRORES: %0d", errors);
        $finish;
    end

    initial begin                     // por si el programa nunca llega a HALT
        #20000000;
        $display("[FALLO] timeout");
        $finish;
    end
endmodule

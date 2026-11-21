// Banco de registros del procesador: 8 registros de 8 bits (R0..R7)
// Cambios respecto al Lab 4:
//   - dos puertos de lectura combinacionales (rs y rt) para leer ambos operandos a la vez
//   - un puerto de escritura sincrono (rd)
//   - R0 cableado a 0: siempre se lee 0 y las escrituras sobre R0 se ignoran
module banco_registro (
    input  wire       clk,
    input  wire       rst,
    input  wire       we,          // habilita escritura en rd
    input  wire [2:0] addr_rd,
    input  wire [7:0] data_in,
    input  wire [2:0] addr_rs,
    input  wire [2:0] addr_rt,
    output wire [7:0] data_rs,
    output wire [7:0] data_rt
);
    reg [7:0] registros [0:7];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) registros[i] <= 8'b0;
        end else if (we && (addr_rd != 3'd0)) begin
            registros[addr_rd] <= data_in;
        end
    end

    assign data_rs = (addr_rs == 3'd0) ? 8'b0 : registros[addr_rs];
    assign data_rt = (addr_rt == 3'd0) ? 8'b0 : registros[addr_rt];
endmodule

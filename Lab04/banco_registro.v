module BancoRegistro #(
        parameter BIT_ADDR = 4,
        parameter BIT_DATO = 8
    )(
    input  wire clk,
    input  wire rst,
    input  wire RegWrite,
    input  wire [BIT_ADDR-1:0] addrRa,
    input  wire [BIT_ADDR-1:0] addrRb,
    input  wire [BIT_ADDR-1:0] addrW,
    input  wire [BIT_DATO-1:0] datW,
    output reg  [BIT_DATO-1:0] datOutRa,
    output reg  [BIT_DATO-1:0] datOutRb
    );

    reg [BIT_DATO-1:0] r0, r1, r2, r3, r4, r5, r6, r7;
    reg [BIT_DATO-1:0] r8, r9, r10, r11, r12, r13, r14, r15;


    always @(posedge clk) begin
        if (rst == 0) begin
            r0  <= 8'b0; r1  <= 8'b0; r2  <= 8'b0; r3  <= 8'b0;
            r4  <= 8'b0; r5  <= 8'b0; r6  <= 8'b0; r7  <= 8'b0;
            r8  <= 8'b0; r9  <= 8'b0; r10 <= 8'b0; r11 <= 8'b0;
            r12 <= 8'b0; r13 <= 8'b0; r14 <= 8'b0; r15 <= 8'b0;
        end else if (RegWrite) begin
            case (addrW)
                4'd0 : r0 <= datW;
                4'd1 : r1 <= datW;
                4'd2 : r2 <= datW;
                4'd3 : r3 <= datW;
                4'd4 : r4 <= datW;
                4'd5 : r5 <= datW;
                4'd6 : r6 <= datW;
                4'd7 : r7 <= datW;
                4'd8 : r8 <= datW;
                4'd9 : r9 <= datW;
                4'd10: r10 <= datW;
                4'd11: r11 <= datW;
                4'd12: r12 <= datW;
                4'd13: r13 <= datW;
                4'd14: r14 <= datW;
                4'd15: r15 <= datW;
            endcase
        end
    end

    // Lectura (combinacional, en paralelo en ambos puertos Ra y Rb)
    always @(*) begin
        case (addrRa)
            4'd0 : datOutRa = r0;
            4'd1 : datOutRa = r1;
            4'd2 : datOutRa = r2;
            4'd3 : datOutRa = r3;
            4'd4 : datOutRa = r4;
            4'd5 : datOutRa = r5;
            4'd6 : datOutRa = r6;
            4'd7 : datOutRa = r7;
            4'd8 : datOutRa = r8;
            4'd9 : datOutRa = r9;
            4'd10: datOutRa = r10;
            4'd11: datOutRa = r11;
            4'd12: datOutRa = r12;
            4'd13: datOutRa = r13;
            4'd14: datOutRa = r14;
            4'd15: datOutRa = r15;
            default: datOutRa = 8'b0;
        endcase
        case (addrRb)
            4'd0 : datOutRb = r0;
            4'd1 : datOutRb = r1;
            4'd2 : datOutRb = r2;
            4'd3 : datOutRb = r3;
            4'd4 : datOutRb = r4;
            4'd5 : datOutRb = r5;
            4'd6 : datOutRb = r6;
            4'd7 : datOutRb = r7;
            4'd8 : datOutRb = r8;
            4'd9 : datOutRb = r9;
            4'd10: datOutRb = r10;
            4'd11: datOutRb = r11;
            4'd12: datOutRb = r12;
            4'd13: datOutRb = r13;
            4'd14: datOutRb = r14;
            4'd15: datOutRb = r15;
            default: datOutRb = 8'b0;
        endcase
    end

endmodule

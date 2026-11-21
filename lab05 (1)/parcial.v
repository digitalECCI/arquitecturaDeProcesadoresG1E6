//`include "comparador_1b.v"


module parcial(
    input wire [3:0] A,
    input wire [3:0] B,
    output wire [3:0] Ma,
    output wire [3:0] Mb,
    output wire [3:0] i,
    output wire  MA,MB,I,
    output reg [3:0] outcomp     
);
    comparador_1b uut0(
    .A(A[0]),
    .B(B[0]),
    .Ma(Ma[0]),
    .Mb(Mb[0]),
    .i(i[0])
);
    comparador_1b uut1(
    .A(A[1]),
    .B(B[1]),
    .Ma(Ma[1]),
    .Mb(Mb[1]),
    .i(i[1])
);
    comparador_1b uut2(
    .A(A[2]),
    .B(B[2]),
    .Ma(Ma[2]),
    .Mb(Mb[2]),
    .i(i[2])
);
    comparador_1b uut3(
    .A(A[3]),
    .B(B[3]),
    .Ma(Ma[3]),
    .Mb(Mb[3]),
    .i(i[3])
);

    assign I = i[3] & i[2] & i[1] & i[0];

    assign MA = Ma[3] | (i[3] & Ma[2]) | (i[3] & i[2] & Ma[1]) | (i[3] & i[2] & i[1] & Ma[0]); 

    assign MB = Mb[3] | (i[3] & Mb[2]) | (i[3] & i[2] & Mb[1]) | (i[3] & i[2] & i[1] & Mb[0]);

always @(*) begin
    if (MA == 1'b1) begin
        outcomp = A; // Si A > B, la salida es A
    end 
    else if (MB == 1'b1) begin
        outcomp = B; // Si A < B, la salida es B
    end 
    else if (I == 1'b1) begin
        outcomp = A; // Si A == B, da igual sacar A o B porque son idénticos
    end 
    else begin
        outcomp = 4'bx; // Caso de fallo (teóricamente imposible en este circuito)
    end
end
 
endmodule 

//always @(*) begin
//    if (MA == 1'b1 && MB == 1'b0 && I == 1'b0) begin
//        outcomp = A; // A > B
//    end else if (MA == 1'b0 && MB == 1'b1 && I == 1'b0) begin
//        outcomp = B; // A < B
//    end else if (MA == 1'b0 && MB == 1'b0 && I == 1'b0) begin
//        outcomp = A; // A = B
//    end else begin
//        outcomp = 3'bx; // Caso no definido
//    end

//assign MA = (Ma_0 | Ma_2 | Ma[1]);
//assign MB = (Mb_0 | Mb[1] | Mb_1);
//assign I = (i[2]&Ma_1);

//assign Ma_0 = (Ma[0]&i[1]);
//assign Ma_1 = (i[0]&i[1]);
//assign Ma_2 = (Ma_1&Ma[2]);
//assign Mb_0 = (Mb[0]&i[1]);
//assign Mb_1 = (Ma_1&Mb[2]);
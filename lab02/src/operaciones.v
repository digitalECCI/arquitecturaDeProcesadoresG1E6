module operaciones(
   input  [1:0] selec,   
   input  [3:0] A,       
   input  [3:0] B,       
   output [4:0] salida,  
	output wire negativo
);

    wire [3:0] sumare;
    wire carriers;
    wire [3:0] and_result;
    wire [3:0] or_result;

    assign and_result = A & B;
    assign or_result  = A | B;

    wire default_carry = 1'b0;

    reg [4:0] salida_reg;
    assign salida = salida_reg;
    wire [3:0] suma_result;
    wire suma_carry;
		
		restadors sumadorrestador (
        .EntradA(A),
        .EntradB(B),
        .selec(selec[0]),
        .SALIDA(suma_result),
        .COUT(suma_carry),
		  .C4(negativo)
		);
		
	assign seleccion = {carriers, sumare};

  
    always @(*) begin
        case(selec)
            2'b00, 2'b01: salida_reg = {suma_carry, suma_result}; 
            2'b10:        salida_reg = {default_carry, and_result}; 
            2'b11:        salida_reg = {default_carry, or_result};  
            default:      salida_reg = 5'b00000;
        endcase
    end

endmodule
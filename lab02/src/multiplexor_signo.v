module multiplexor_signo(
  input BCD,       
  output reg [6:0] SSeg    
);
		
  always@(*) begin
      case (BCD)
          1'b1: SSeg = ~7'b1000000;
          default: SSeg = ~7'b0000000; 
      endcase
      end
endmodule
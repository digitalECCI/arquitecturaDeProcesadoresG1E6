module Lab04_Multiplicador_Top (
    input  wire [3:0] MD,    
    input  wire [3:0] MR,    
    input  wire       INIT,  
    input  wire       clk,   
    input  wire       rst_n, 
    output wire       DONE,  
    output wire [6:0] HEX0,  
    output wire [6:0] HEX1,  
    output wire [6:0] HEX2  
);

    
    localparam ST_START = 3'd0;
    localparam ST_CHECK = 3'd1;
    localparam ST_ADD   = 3'd2;
    localparam ST_SHIFT = 3'd3;
    localparam ST_END   = 3'd4;

    reg [2:0] state, next_state;
    reg ctrl_reset, ctrl_add, ctrl_sh, ctrl_done;

    assign DONE = ctrl_done;

    reg [7:0] A_reg;  
    reg [3:0] B_reg;  
    reg [7:0] PP_reg; 

    wire LSB_B = B_reg[0];         
    wire Z     = (B_reg == 4'd0);  

   
    wire [7:0] Sum_Out;
    wire carry_mid, c5, c6, c7, c8;

    sumador_restador_4_bits add_low (
        .A(PP_reg[3:0]), .B(A_reg[3:0]), .Sel(1'b0), .So(Sum_Out[3:0]), .Co(carry_mid)
    );

    sumador_un_bit sum4 (.A(PP_reg[4]), .B(A_reg[4]), .Ci(carry_mid), .So(Sum_Out[4]), .Co(c5));
    sumador_un_bit sum5 (.A(PP_reg[5]), .B(A_reg[5]), .Ci(c5),        .So(Sum_Out[5]), .Co(c6));
    sumador_un_bit sum6 (.A(PP_reg[6]), .B(A_reg[6]), .Ci(c6),        .So(Sum_Out[6]), .Co(c7));
    sumador_un_bit sum7 (.A(PP_reg[7]), .B(A_reg[7]), .Ci(c7),        .So(Sum_Out[7]), .Co(c8));

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= ST_START;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        ctrl_reset = 1'b0; ctrl_add = 1'b0; ctrl_sh = 1'b0; ctrl_done = 1'b0;

        case (state)
            ST_START: begin
                if (INIT == 1'b1) begin
                    ctrl_reset = 1'b1;
                    next_state = ST_CHECK;
                end else begin
                    ctrl_reset = 1'b0; 
                    next_state = ST_START;
                end
            end
            ST_CHECK: begin
                if (LSB_B == 1'b1) next_state = ST_ADD;
                else               next_state = ST_SHIFT;
            end
            ST_ADD: begin
                ctrl_add = 1'b1;
                next_state = ST_SHIFT;
            end
            ST_SHIFT: begin
                ctrl_sh = 1'b1;
                if (Z == 1'b1) next_state = ST_END;
                else           next_state = ST_CHECK;
            end
            ST_END: begin
                ctrl_done = 1'b1;
                if (INIT == 1'b0) next_state = ST_START; 
                else              next_state = ST_END;
            end
            default: next_state = ST_START;
        endcase
    end

 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg  <= 8'd0; B_reg  <= 4'd0; PP_reg <= 8'd0;
        end else begin
            if (ctrl_reset) begin
                A_reg  <= {4'd0, MD}; 
                B_reg  <= MR;         
                PP_reg <= 8'd0;       
            end else begin
                if (ctrl_add) PP_reg <= Sum_Out; 
                if (ctrl_sh) begin
                    A_reg <= A_reg << 1; 
                    B_reg <= B_reg >> 1; 
                end
            end
        end
    end


    wire [3:0] bcd_c, bcd_d, bcd_u; 

 // retirar ---- por corrimientos y sumas de 3
 function [11:0] bin_a_bcd;
        input [7:0] bin;
        integer k;
        begin
            bin_a_bcd = 12'd0;                       // {centenas, decenas, unidades}
            for (k = 7; k >= 0; k = k - 1) begin
                // Antes de cada corrimiento: si una cifra BCD es >= 5, se le suma 3
                if (bin_a_bcd[3:0]  >= 4'd5) bin_a_bcd[3:0]  = bin_a_bcd[3:0]  + 4'd3;
                if (bin_a_bcd[7:4]  >= 4'd5) bin_a_bcd[7:4]  = bin_a_bcd[7:4]  + 4'd3;
                if (bin_a_bcd[11:8] >= 4'd5) bin_a_bcd[11:8] = bin_a_bcd[11:8] + 4'd3;
                // Corrimiento a la izquierda, entrando el siguiente bit del binario
                bin_a_bcd = {bin_a_bcd[10:0], bin[k]};
            end
        end
    endfunction

    wire [11:0] bcd_full = bin_a_bcd(PP_reg);
    assign bcd_c = bcd_full[11:8];
    assign bcd_d = bcd_full[7:4];
    assign bcd_u = bcd_full[3:0];

    // Lógica para apagar los ceros a la izquierda
    wire [3:0] show_c = (bcd_c == 4'd0) ? 4'hf : bcd_c;
    wire [3:0] show_d = (bcd_c == 4'd0 && bcd_d == 4'd0) ? 4'hf : bcd_d;
    wire [3:0] show_u = bcd_u;  

    
    function [6:0] decodificador_7seg;
        input [3:0] bcd_in;
        begin
            case (bcd_in)
                4'd0: decodificador_7seg = ~7'b0111111;
                4'd1: decodificador_7seg = ~7'b0000110;
                4'd2: decodificador_7seg = ~7'b1011011;
                4'd3: decodificador_7seg = ~7'b1001111;
                4'd4: decodificador_7seg = ~7'b1100110;
                4'd5: decodificador_7seg = ~7'b1101101;
                4'd6: decodificador_7seg = ~7'b1111101;
                4'd7: decodificador_7seg = ~7'b0000111;
                4'd8: decodificador_7seg = ~7'b1111111;
                4'd9: decodificador_7seg = ~7'b1101111;
                default: decodificador_7seg = ~7'b0000000; // 4'hf u otros apagan el display
            endcase
        end
    endfunction


    assign HEX0 = decodificador_7seg(show_u);
    assign HEX1 = decodificador_7seg(show_d);
    assign HEX2 = decodificador_7seg(show_c);

endmodule
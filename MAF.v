`timescale 1ns / 1ps

module MAF( 
    input clk,  
    input  [31:0] A, B,C,
    input  [1:0]  func,
    output [63:0] Result
    );
   
    wire [63:0] mult_out_reg;
   
    Pipeline1 P1(clk,A, B, func, mult_out_reg);
    Pipeline2 P2(clk,C, mult_out_reg, func, Result);

endmodule


module Pipeline1(
    input clk,
    input  [31:0] A,
    input  [31:0] B,
    input  [1:0] func,
    output [63:0] mult_out
    );
   
    reg [31:0] mux_w;

    always @(*) begin
        case(func)
            2'b00: mux_w <= B;
            2'b01: mux_w <= 32'h1;
            2'b10: mux_w <= B;
            2'b11: mux_w <= 32'h1;
        endcase
    end    

   assign mult_out = A * mux_w; 

     
endmodule


module Pipeline2(
    input clk,
    input  [31:0] c_reg,
    input  [63:0] mult_out_reg,
    input  [1:0] func_reg,
    output reg [63:0] Result
    );
   
    reg [31:0] mux_w;
   
    always @(*) begin
        case(func_reg)
            2'b00: mux_w <= 0;
            2'b01: mux_w <= c_reg;
            2'b10: mux_w <= c_reg;
            2'b11: mux_w <= 0;
        endcase
    end
   
   always @(posedge clk) begin
   Result <= mult_out_reg + mux_w;
   end
endmodule
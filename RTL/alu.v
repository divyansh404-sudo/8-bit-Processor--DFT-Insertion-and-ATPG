`timescale 1ns / 1ps

module alu(
    input  wire [7:0] a,
    input  wire [7:0] b,      // Not used for INC, DEC, NOT
    input  wire [2:0] op,
    output reg  [7:0] result,
    output reg        carry_out,
    output reg        zero_out
);
    
    reg [8:0] temp_result; // 9-bit to capture carry
    
    always @(*) begin
        // Default assignments to prevent inferred latches during synthesis
        carry_out   = 1'b0;
        zero_out    = 1'b0;
        temp_result = 9'b0;
        result      = 8'b0;
        
        case (op)
            3'b000: begin // ADD
                temp_result = {1'b0, a} + {1'b0, b};
                result      = temp_result[7:0];
                carry_out   = temp_result[8];
            end
            
            3'b001: begin // SUB
                temp_result = {1'b0, a} - {1'b0, b};
                result      = temp_result[7:0];
                carry_out   = temp_result[8]; // Borrow flag
            end
            
            3'b010: begin // AND
                result      = a & b;
            end
            
            3'b011: begin // OR
                result      = a | b;
            end
            
            3'b100: begin // INC (a + 1, ignores b)
                temp_result = {1'b0, a} + 9'b1;
                result      = temp_result[7:0];
                carry_out   = temp_result[8];
            end
            
            3'b101: begin // DEC (a - 1, ignores b)
                temp_result = {1'b0, a} - 9'b1;
                result      = temp_result[7:0];
                carry_out   = temp_result[8]; // Borrow flag
            end
            
            3'b110: begin // NOT (~a, ignores b)
                result      = ~a;
            end
            
            default: begin
                result      = 8'b0;
                carry_out   = 1'b0;
            end
        endcase
        
        zero_out = (result == 8'b0);
    end
endmodule


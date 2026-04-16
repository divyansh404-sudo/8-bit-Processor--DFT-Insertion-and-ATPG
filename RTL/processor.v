`timescale 1ns / 1ps

module processor(
    input  wire       clk,
    input  wire       reset,
    
    // --- Added DFT Ports for ASIC Flow ---
    input  wire       scan_en,
    input  wire       scan_in,
    input  wire       test_mode, 
    output wire       scan_out,
    // -------------------------------------

    output wire [7:0] A_out,
    output wire [4:0] PC_out,
    output wire       halted_out
);

    // Internal registers
    reg [7:0] memory [0:31];
    reg [7:0] A, IR, alu_b;
    reg [4:0] PC, next_pc;
    reg [2:0] alu_op;
    reg       carry, zero, halted;
    reg [1:0] state;

    // ALU interface wires
    wire [7:0] alu_result;
    wire       alu_carry, alu_zero;

    // FSM states
    localparam FETCH = 2'b00,
               EXEC  = 2'b01,
               WB    = 2'b10;

    // Instantiate ALU
    alu alu_inst (
        .a         (A),
        .b         (alu_b),
        .op        (alu_op),
        .result    (alu_result),
        .carry_out (alu_carry),
        .zero_out  (alu_zero)
    );

    integer i;

    // --- Sequential logic ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize processor registers
            A       <= 8'd0;
            IR      <= 8'd0;
            PC      <= 5'd0;
            next_pc <= 5'd0;
            alu_op  <= 3'b000;
            carry   <= 1'b0;
            zero    <= 1'b0;
            halted  <= 1'b0;
            alu_b   <= 8'd0;
            state   <= FETCH;

            // Initialize memory array & default demo program
            for (i = 0; i < 32; i = i + 1) begin
                memory[i] <= 8'd0;
            end
            
            memory[0]  <= 8'b000_10000;            // LOAD M[16]
            memory[1]  <= {3'b010, 3'b000, 2'b00}; // ALU ADD
            memory[2]  <= 8'd17;                   // operand address
            memory[3]  <= 8'b001_10010;            // STORE M[18]
            memory[4]  <= 8'b111_00000;            // HALT
            memory[16] <= 8'd10;                   // data A
            memory[17] <= 8'd5;                    // data B
            memory[18] <= 8'd0;                    // result

        end else if (!halted) begin
            case (state)
                FETCH: begin
                    IR    <= memory[PC];
                    state <= EXEC;
                end

                EXEC: begin
                    case (IR[7:5])
                        3'b000: begin // LOAD
                            if (IR[4:0] < 32)
                                A <= memory[IR[4:0]];
                            else
                                A <= 8'd0;
                            PC    <= PC + 1;
                            state <= FETCH;
                        end

                        3'b001: begin // STORE
                            if (IR[4:0] < 32)
                                memory[IR[4:0]] <= A;
                            PC    <= PC + 1;
                            state <= FETCH;
                        end

                        3'b010: begin // ALU operation
                            alu_op <= IR[4:2];
                            if (IR[4:2] <= 3'b011) begin
                                // Two-operand instruction (fetch 'b')
                                alu_b   <= memory[memory[PC + 1][4:0]];
                                next_pc <= PC + 2;
                            end else begin
                                // Single-operand instruction
                                alu_b   <= 8'd0;
                                next_pc <= PC + 1;
                            end
                            state <= WB;
                        end

                        3'b111: begin // HALT
                            halted <= 1'b1;
                            state  <= FETCH;
                        end

                        default: begin // NOP / Unknown
                            PC    <= PC + 1;
                            state <= FETCH;
                        end
                    endcase
                end

                WB: begin
                    A     <= alu_result;
                    carry <= alu_carry;
                    zero  <= alu_zero;
                    PC    <= next_pc;
                    state <= FETCH;
                end
            endcase
        end
    end

    // --- Outputs ---
    assign A_out      = A;
    assign PC_out     = PC;
    assign halted_out = halted;
    
    // Tie off scan_out for RTL simulation; Genus will override this during DFT insertion
    assign scan_out   = 1'b0;

endmodule



module stage_ex_alu (
    input clk,
    input reset,
    
    input req_ex,
    input [2:0] funct3_ex,
    input [1:0] op_mux,
    input [2:0] src1_mux,
    input [2:0] src2_mux,
    input [31:0] datars1_ex_alu,
    input [31:0] datars2_ex_alu,
    input [31:0] pc_ex,
    input [19:0] imm,
    input [31:0] alubypass,
    input [31:0] jmpbypass,

    output reg [31:0] result_ex

);

integer i;
    
reg [31:0] src1;
reg [31:0] src2;

always @(*) begin
    if (req_ex) begin
        // src1
        if (src1_mux == 3'b0) begin
            src1 <= datars1_ex_alu;
        end else if (src1_mux == 3'b01) begin
            src1 <= pc_ex;
        end else if (src1_mux == 3'b10) begin
            src1 <= 32'b0;
        end else if (src1_mux == 3'b100) begin
            src1 <= alubypass;
        end else if (src1_mux == 3'b110) begin
            src1 <= jmpbypass;
        end
        //src2
        if (src2_mux == 3'b0) begin
            src2 <= datars2_ex_alu;
        end else if (src2_mux == 3'b01) begin
            src2 <= {{21{imm[19]}},imm[18:8]};
        end else if (src2_mux == 3'b10) begin
            src2 <= {27'b0,imm[12:8]};
        end else if (src2_mux == 3'b11) begin
            src2 <= {imm,12'b0};
        end else if (src2_mux == 3'b100) begin
            src2 <= alubypass;
        end else if (src2_mux == 3'b110) begin
            src2 <= jmpbypass;
        end

        // calculation
        if (funct3_ex == 3'b000) begin
            if (op_mux == 2'b0) begin
                result_ex <= src1 + src2;
            end else if (op_mux == 2'b01) begin
                result_ex <= ($signed(src1)) * ($signed(src2));
            end else if (op_mux == 2'b10) begin
                result_ex <= src1 - src2;
            end
        end else if (funct3_ex == 3'b111) begin
            result_ex <= src1 & src2;
        end else if (funct3_ex == 3'b110) begin
            result_ex <= src1 | src2;
        end else if (funct3_ex == 3'b100) begin
            result_ex <= src1 ^ src2;
        end else if (funct3_ex == 3'b010) begin
            if (src1[31] && !src2[31]) begin  // 1n 2p
                result_ex <= 32'b1;
            end else if (!src1[31] && src2[31]) begin  // 1p 2n
                result_ex <= 32'b0;
            end else begin  // 1n 2n or 1p 2p
                result_ex <= (src1 < src2)? 32'b1: 32'b0;
            end
        end else if (funct3_ex == 3'b011) begin
            result_ex <= (src1 < src2)? 32'b1: 32'b0;
        end else if (funct3_ex == 3'b101) begin
            if (op_mux == 2'b00) begin
                result_ex <= src1 >> src2[4:0];
            end else begin
                result_ex <= ($signed(src1)) >>> src2[4:0];
            end
        end else if (funct3_ex == 3'b001) begin
            result_ex <= src1 << src2[4:0];
        end
    end
end



endmodule
module stage_ex_jmp (
    input clk,
    input reset,
    
    input req_ex,
    input [2:0] funct3_ex,
    input [1:0] op_mux,
    input [1:0] src1_mux,
    input [1:0] src2_mux,
    input [31:0] datars1_ex_alu,
    input [31:0] datars2_ex_alu,
    input [31:0] pc_ex,
    input [19:0] imm,
    input [31:0] alubypass,
    input [31:0] jmpbypass,

    output reg rd_valid_ex,
    output reg [31:0] result_ex,
    output reg pc_recover,  // miss predict
    output reg [31:0] new_pc

);

integer i;
    
reg [31:0] src1;
reg [31:0] src2;

wire pc_miss_branch;
wire [31:0] pc_branch;
assign pc_miss_branch = (imm[11:0]==12'd4)?1'b0:1'b1;
assign pc_branch = pc_ex + {{21{imm[11]}},imm[10:0]};

wire [31:0] pc_jalr;
assign pc_jalr = src1+{{21{imm[11]}},imm[10:0]};

always @(*) begin
    if (req_ex) begin
        // src1
        if (src1_mux == 2'b0) begin
            src1 <= datars1_ex_alu;
        end else if (src1_mux == 2'b01) begin
            src1 <= alubypass;
        end else if (src1_mux == 2'b11) begin
            src1 <= jmpbypass;
        end
        //src2
        if (src2_mux == 2'b0) begin
            src2 <= datars2_ex_alu;
        end else if (src2_mux == 2'b01) begin
            src2 <= alubypass;
        end else if (src2_mux == 2'b11) begin
            src2 <= jmpbypass;
        end

        // calculation
        if (op_mux == 2'b0) begin
            rd_valid_ex <= 1'b1;
            result_ex <= pc_ex + 32'd4;
            if (imm == 20'd4) begin
                pc_recover <= 1'b0;
            end else begin
                pc_recover <= 1'b1;
                new_pc <= pc_ex + {{13{imm[19]}},imm[18:0]};
            end
        end else if (op_mux == 2'b01) begin
            rd_valid_ex <= 1'b0;
            if (src1 == pc_ex+32'd4) begin
                pc_recover <= 1'b0;
            end else begin
                pc_recover <= 1'b1;
                new_pc <= src1; 
            end
        end else if (op_mux == 2'b10) begin
            rd_valid_ex <= 1'b1;
            result_ex <= pc_ex + 32'd4;
            if ({pc_jalr[31:1],1'b0} == result_ex) begin
                pc_recover <= 1'b0;
            end else begin
                pc_recover <= 1'b1;
                new_pc <= {pc_jalr[31:1],1'b0}; 
            end
        end else if (op_mux == 2'b11) begin
            rd_valid_ex <= 1'b0;
            new_pc <= pc_branch;
            if (funct3_ex == 3'b000) begin
                pc_recover <= (src1==src2 && pc_miss_branch)?1'b1:1'b0;
            end else if (funct3_ex == 3'b001) begin
                pc_recover <= (src1!=src2 && pc_miss_branch)?1'b1:1'b0;
            end else if (funct3_ex == 3'b100) begin
                pc_recover <= (($signed(src1))<($signed(src2)) && pc_miss_branch)?1'b1:1'b0;
            end else if (funct3_ex == 3'b101) begin
                pc_recover <= (($signed(src1))>=($signed(src2)) && pc_miss_branch)?1'b1:1'b0;
            end else if (funct3_ex == 3'b110) begin
                pc_recover <= (($unsigned(src1))<($unsigned(src2)) && pc_miss_branch)?1'b1:1'b0;
            end else if (funct3_ex == 3'b111) begin
                pc_recover <= (($unsigned(src1))>=($unsigned(src2)) && pc_miss_branch)?1'b1:1'b0;
            end
        end
    end else begin
        pc_recover <= 1'b0;
    end
end



endmodule
module stage_rfread_alu (
    input clk,
    input reset,
    input flush_iq,
    
    input req_issue,
    input [5:0] pos_issue,
    input [5:0] prd_issue,
    input [5:0] prs1_issue,
    input prs1_valid_issue,
    input [5:0] prs2_issue,
    input prs2_valid_issue,
    input [2:0] funct3_issue,
    input [6:0] funct7_issue,
    input isauipc_issue,
    input [4:0] rs1_issue,
    input [4:0] rs2_issue,
    input [31:0] pc_issue,
    input alubypass1_issue,
    input alubypass2_issue,
    input jmpbypass1_issue,
    input jmpbypass2_issue,

    output reg req_ex,
    output reg [5:0] pos_ex,
    output reg [5:0] prd_ex,
    output reg [2:0] funct3_ex,
    output reg [2:0] src1_mux,  // 00:rs1, 01:pc, 10:zero, 100:alubypass, 110:jmpbypass
    output reg [2:0] src2_mux,  // 00:rs2, 01:31-20, 10:24-20, 11:31-12, 100:alubypass, 110:jmpbypass
    output reg [19:0] imm,
    output reg [31:0] pc_ex,
    output reg [1:0] op_mux,

    // rf
    output reg [5:0] prs1_rfread,
    output reg [5:0] prs2_rfread
);

reg req_rfread;
reg [5:0] pos_rfread;
reg [5:0] prd_rfread;
//reg [5:0] prs1_rfread;
reg prs1_valid_rfread;
//reg [5:0] prs2_rfread;
reg prs2_valid_rfread;
reg [2:0] funct3_rfread;
reg [6:0] funct7_rfread;
reg isauipc_rfread;
reg [4:0] rs1_rfread;
reg [4:0] rs2_rfread;
reg [31:0] pc_rfread;
reg alubypass1_rfread;
reg alubypass2_rfread;
reg jmpbypass1_rfread;
reg jmpbypass2_rfread;

always @(posedge clk) begin
    if (reset | flush_iq) begin
        req_rfread <= 1'b0;
    end else begin
        req_rfread <= req_issue;
        pos_rfread <= pos_issue;
        prd_rfread <= prd_issue;
        prs1_rfread <= prs1_issue;
        prs1_valid_rfread <= prs1_valid_issue;
        prs2_rfread <= prs2_issue;
        prs2_valid_rfread <= prs2_valid_issue;
        funct3_rfread <= funct3_issue;
        funct7_rfread <= funct7_issue;
        isauipc_rfread <= isauipc_issue;
        rs1_rfread <= rs1_issue;
        rs2_rfread <= rs2_issue;
        pc_rfread <= pc_issue;
        alubypass1_rfread <= alubypass1_issue;
        alubypass2_rfread <= alubypass2_issue;
        jmpbypass1_rfread <= jmpbypass1_issue;
        jmpbypass2_rfread <= jmpbypass2_issue;
    end    
end

always @(*) begin
    req_ex <= req_rfread;
    pos_ex <= pos_rfread;
    prd_ex <= prd_rfread;
    imm <= {funct7_rfread,rs2_rfread,rs1_rfread,funct3_rfread};
    pc_ex <= pc_rfread;
    if (prs1_valid_rfread && prs2_valid_rfread) begin
        src1_mux <= (alubypass1_rfread)?3'b100:(jmpbypass1_rfread)?3'b110:3'b0;
        src2_mux <= (alubypass2_rfread)?3'b100:(jmpbypass2_rfread)?3'b110:3'b0;
        funct3_ex <= funct3_rfread;
        op_mux <= {funct7_rfread[5],funct7_rfread[0]};
    end else if (!prs1_valid_rfread && !prs2_valid_rfread) begin
        src1_mux <= (isauipc_rfread)?3'b01:3'b10;
        src2_mux <= 3'b11;
        funct3_ex <= 3'b0;
        op_mux <= 2'b0;
    end else begin
        if (funct3_rfread==3'b101 | funct3_rfread==3'b001) begin
            src1_mux <= (alubypass1_rfread)?3'b100:(jmpbypass1_rfread)?3'b110:3'b0;
            src2_mux <= 3'b10;
            funct3_ex <= funct3_rfread;
            op_mux <= {funct7_rfread[5],funct7_rfread[0]};
        end else begin
            src1_mux <= (alubypass1_rfread)?3'b100:(jmpbypass1_rfread)?3'b110:3'b0;
            src2_mux <= 3'b01;
            funct3_ex <= funct3_rfread;
            op_mux <= {funct7_rfread[5],funct7_rfread[0]};
        end
    end
end
            
    
endmodule
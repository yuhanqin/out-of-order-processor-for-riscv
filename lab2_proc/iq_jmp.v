module iq_jmp (
    input clk,
    input reset,
    input flush_iq,

    // Dispatch
    output wire no_free_iq_jmp,
    output wire one_free_iq_jmp,

    input ins_valid1_jmp,
    input rd_valid1_jmp,
    input [5:0] pos1_jmp,
    input [5:0] prd1_jmp,
    input [5:0] prs11_jmp,
    input prs1_valid1_jmp,
    input [5:0] prs21_jmp,
    input prs2_valid1_jmp,
    input [2:0] funct31_jmp,
    input [6:0] funct71_jmp,
    input [4:0] rs11_jmp,
    input [4:0] rs21_jmp,
    input [4:0] rd1_jmp,
    input [31:0] pc1_jmp,
    input ins_valid2_jmp,
    input rd_valid2_jmp,
    input [5:0] pos2_jmp,
    input [5:0] prd2_jmp,
    input [5:0] prs12_jmp,
    input prs1_valid2_jmp,
    input [5:0] prs22_jmp,
    input prs2_valid2_jmp,
    input [2:0] funct32_jmp,
    input [6:0] funct72_jmp,
    input [4:0] rs12_jmp,
    input [4:0] rs22_jmp,
    input [4:0] rd2_jmp,
    input [31:0] pc2_jmp,

    //input jmp_issue_grant,  // TODO
    input pc_grant,

    // for RdyTable
    //output wire rd_valid1_jmp,
    //output wire rd_valid2_jmp,
    input [5:0] prd1_alu,
    input ins_valid1_alu,
    input [5:0] prd2_alu,
    input ins_valid2_alu,
    input [5:0] prd1_lsq,
    input ins_valid1_lsq,
    input [5:0] prd2_lsq,
    input ins_valid2_lsq,
    input req_issue_alu,
    input [5:0] prd_issue_alu,

    // Issue
    output reg req_issue,
    output reg [5:0] pos_issue,
    output reg [5:0] prd_issue,
    output reg [5:0] prs1_issue,
    output reg prs1_valid_issue,
    output reg [5:0] prs2_issue,
    output reg prs2_valid_issue,
    output reg [2:0] funct3_issue,
    output reg [6:0] funct7_issue,
    output reg [4:0] rs1_issue,
    output reg [4:0] rs2_issue,
    output reg [4:0] rd_issue,
    output reg [31:0] pc_issue,
    output reg alubypass1_issue,
    output reg alubypass2_issue,
    output reg jmpbypass1_issue,
    output reg jmpbypass2_issue



);

reg issue_grant;

// Capcacity of 8 instr.
reg [5:0] Pos [0:7];
reg [5:0] Src1 [0:7];
reg Val1 [0:7];
reg Rdy1 [0:7];
reg [5:0] Src2 [0:7];
reg Val2 [0:7];
reg Rdy2 [0:7];
reg [5:0] Dest [0:7];
reg [2:0] Funct3 [0:7];
reg [6:0] Funct7 [0:7];
reg [4:0] RS1 [0:7];
reg [4:0] RS2 [0:7];
reg [4:0] RD [0:7];
reg [31:0] PC [0:7];
integer k;

reg [3:0] headp;  // one more posbit
reg [3:0] tailp;  // oldest one
wire [3:0] headp_next;
reg empty_free_iq_jmp;

assign headp_next = headp+4'd1;

// RdyTable: need to be (global, or) consistent among three iq
reg [63:0] RdyTable;
reg [63:0] RdyAluBypass;
reg [63:0] RdyJmpBypass;
integer j, n;

assign no_free_iq_jmp = (headp[3]!=tailp[3] && headp[2:0]==tailp[2:0])?1'b1:1'b0;
assign one_free_iq_jmp = (headp_next[2:0] == tailp[2:0])?1'b1:1'b0;
assign empty_free_iq_jmp = (headp == tailp)?1'b1:1'b0;

// RdyTable
always @(*) begin
    for (k = 0;k < 8; k++) begin
        Rdy1[k] <= RdyTable[Src1[k]];
        Rdy2[k] <= RdyTable[Src2[k]];
    end
end
//assign rd_valid1_jmp = (!prs1_valid1_jmp && !prs2_valid1_jmp) | (prs1_valid1_jmp && !prs2_valid1_jmp && rd1_jmp!=5'b0);
//assign rd_valid2_jmp = (!prs1_valid2_jmp && !prs2_valid2_jmp) | (prs1_valid2_jmp && !prs2_valid2_jmp && rd2_jmp!=5'b0);

// Issue
always @(*) begin
    req_issue <= (!Val1[tailp]|Rdy1[tailp]) && (!Val2[tailp]|Rdy2[tailp]) && !empty_free_iq_jmp && issue_grant;
    pos_issue <= Pos[tailp];
    prd_issue <= Dest[tailp];
    prs1_issue <= Src1[tailp];
    prs1_valid_issue <= Val1[tailp];
    prs2_issue <= Src2[tailp];
    prs2_valid_issue <= Val2[tailp];
    funct3_issue <= Funct3[tailp];
    funct7_issue <= Funct7[tailp];
    rs1_issue <= RS1[tailp];
    rs2_issue <= RS2[tailp];
    rd_issue <= RD[tailp];
    pc_issue <= PC[tailp];

    alubypass1_issue <= RdyAluBypass[Src1[tailp]];
    alubypass2_issue <= RdyAluBypass[Src2[tailp]];
    jmpbypass1_issue <= RdyJmpBypass[Src1[tailp]];
    jmpbypass2_issue <= RdyJmpBypass[Src2[tailp]];
end

always @(posedge clk ) begin
    if (reset | flush_iq) begin
        headp <= 4'b0;
        tailp <= 4'b0;
        for (j = 0;j < 64; j++) begin
            RdyTable[j] <= 1'b1;
            RdyAluBypass[j] <= 1'b0;
            RdyJmpBypass[j] <= 1'b0;
        end
        issue_grant <= 1'b1;
    end
    else begin
        // rdytable update
        if (ins_valid1_alu) begin
            RdyTable[prd1_alu] <= 1'b0;
        end
        if (ins_valid2_alu) begin
            RdyTable[prd2_alu] <= 1'b0;
        end
        if (req_issue_alu) begin
            RdyTable[prd_issue_alu] <= 1'b1;
            RdyAluBypass[prd_issue_alu] <= 1'b1;
        end
        // lsq
        
        // Dispatch
        if(ins_valid1_jmp==1'b1 && ins_valid2_jmp==1'b0) begin
            Pos[headp[2:0]] <= pos1_jmp;
            Src1[headp[2:0]] <= prs11_jmp;
            Val1[headp[2:0]] <= prs1_valid1_jmp;
            Src2[headp[2:0]] <= prs21_jmp;
            Val2[headp[2:0]] <= prs2_valid1_jmp;
            Dest[headp[2:0]] <= prd1_jmp;
            Funct3[headp[2:0]] <= funct31_jmp;
            Funct7[headp[2:0]] <= funct71_jmp;
            RS1[headp[2:0]] <= rs11_jmp;
            RS2[headp[2:0]] <= rs21_jmp;
            RD[headp[2:0]] <= rd1_jmp;
            PC[headp[2:0]] <= pc1_jmp;
            if (rd_valid1_jmp) begin
                RdyTable[prd1_jmp] <= 1'b0;  // TODO: get prd_lsq/jmp with valid as well
            end
            headp <= headp + 4'd1;
        end else if(ins_valid1_jmp==1'b0 && ins_valid2_jmp==1'b1) begin
            Pos[headp[2:0]] <= pos2_jmp;
            Src1[headp[2:0]] <= prs12_jmp;
            Val1[headp[2:0]] <= prs1_valid2_jmp;
            Src2[headp[2:0]] <= prs22_jmp;
            Val2[headp[2:0]] <= prs2_valid2_jmp;
            Dest[headp[2:0]] <= prd2_jmp;
            Funct3[headp[2:0]] <= funct32_jmp;
            Funct7[headp[2:0]] <= funct72_jmp;
            RS1[headp[2:0]] <= rs12_jmp;
            RS2[headp[2:0]] <= rs22_jmp;
            RD[headp[2:0]] <= rd2_jmp;
            PC[headp[2:0]] <= pc2_jmp;
            if (rd_valid2_jmp) begin
                RdyTable[prd2_jmp] <= 1'b0;
            end
            headp <= headp + 4'd1;
        end else if (ins_valid1_jmp==1'b1 && ins_valid2_jmp==1'b1) begin
            Pos[headp[2:0]] <= pos1_jmp;
            Src1[headp[2:0]] <= prs11_jmp;
            Val1[headp[2:0]] <= prs1_valid1_jmp;
            Src2[headp[2:0]] <= prs21_jmp;
            Val2[headp[2:0]] <= prs2_valid1_jmp;
            Dest[headp[2:0]] <= prd1_jmp;
            Funct3[headp[2:0]] <= funct31_jmp;
            Funct7[headp[2:0]] <= funct71_jmp;
            RS1[headp[2:0]] <= rs11_jmp;
            RS2[headp[2:0]] <= rs21_jmp;
            RD[headp[2:0]] <= rd1_jmp;
            PC[headp[2:0]] <= pc1_jmp;
            if (rd_valid1_jmp) begin
                RdyTable[prd1_jmp] <= 1'b0;
            end
            Pos[headp_next[2:0]] <= pos2_jmp;
            Src1[headp_next[2:0]] <= prs12_jmp;
            Val1[headp_next[2:0]] <= prs1_valid2_jmp;
            Src2[headp_next[2:0]] <= prs22_jmp;
            Val2[headp_next[2:0]] <= prs2_valid2_jmp;
            Dest[headp_next[2:0]] <= prd2_jmp;
            Funct3[headp_next[2:0]] <= funct32_jmp;
            Funct7[headp_next[2:0]] <= funct72_jmp;
            RS1[headp_next[2:0]] <= rs12_jmp;
            RS2[headp_next[2:0]] <= rs22_jmp;
            RD[headp_next[2:0]] <= rd2_jmp;
            PC[headp_next[2:0]] <= pc2_jmp;
            if (rd_valid2_jmp) begin
                RdyTable[prd2_jmp] <= 1'b0;
            end
            headp <= headp + 4'd2;
        end
    end

    // Wakeup
    if (req_issue) begin
        RdyTable[Dest[tailp]] <= 1'b1;
        RdyJmpBypass[Dest[tailp]] <= 1'b1;
    end
    for (n = 0; n < 64; n++) begin
        if (RdyAluBypass[n] == 1'b1) begin
            RdyAluBypass[n] <= 1'b0;
        end
        if (RdyJmpBypass[n] == 1'b1) begin
            RdyJmpBypass[n] <= 1'b0;
        end
    end

    // Issue
    if (req_issue && issue_grant) begin
        tailp <= tailp + 4'd1;
        issue_grant <= 1'b0;
    end

    // recover
    if (pc_grant) begin
        issue_grant <= 1'b1;
    end


end


    
endmodule
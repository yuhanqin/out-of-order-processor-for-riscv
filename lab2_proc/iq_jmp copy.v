module iq_jmp (
    input clk,
    input reset,

    // Dispatch
    output wire no_free_iq_jmp,
    output wire one_free_iq_jmp,

    input ins_valid1_jmp,
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
    // for RdyTable
    output wire rd_valid1_jmp,
    output wire rd_valid2_jmp,
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

// Capcacity of 8 instr.
reg [5:0] Pos [0:7];
reg [5:0] Src1 [0:7];
reg Val1 [0:7];
reg Rdy1 [0:7];
reg [5:0] Src2 [0:7];
reg Val2 [0:7];
reg Rdy2 [0:7];
reg [5:0] Dest [0:7];
reg Issued [0:7];
reg [2:0] Funct3 [0:7];
reg [6:0] Funct7 [0:7];
reg [4:0] RS1 [0:7];
reg [4:0] RS2 [0:7];
reg [4:0] RD [0:7];
reg [31:0] PC [0:7];
integer k;

// FL
reg [2:0] FL [0:7];
reg [3:0] headp;  // one more posbit
reg [3:0] tailp;
wire [3:0] headp_next;
integer i;

// RdyTable: need to be (global, or) consistent among three iq
reg [63:0] RdyTable;
reg [63:0] RdyAluBypass;
reg [63:0] RdyJmpBypass;
integer j, n;

// Select
reg Req [0:7];
integer m, s1, s2;
reg req_stage1 [0:3];
reg req_stage2 [0:1];
//reg req_issue;
reg [5:0] age_stage1 [0:3];
reg [5:0] age_stage2 [0:1];
reg [2:0] p_stage1 [0:3];
reg [2:0] p_stage2 [0:1];
reg [2:0] p_issue;

// for debug
wire [2:0] p_stage11,p_stage12,p_stage13,p_stage14;
assign p_stage11 = p_stage1[0];
assign p_stage12 = p_stage1[1];
assign p_stage13 = p_stage1[2];
assign p_stage14 = p_stage1[3];
wire [2:0] p_stage21,p_stage22;
assign p_stage21 = p_stage2[0];
assign p_stage22 = p_stage2[1];
wire [5:0] age_stage11,age_stage12,age_stage13,age_stage14;
assign age_stage11 = age_stage1[0];
assign age_stage12 = age_stage1[1];
assign age_stage13 = age_stage1[2];
assign age_stage14 = age_stage1[3];
wire [5:0] age_stage21,age_stage22;
assign age_stage21 = age_stage2[0];
assign age_stage22 = age_stage2[1];
wire req_stage11,req_stage12,req_stage13,req_stage14;
assign req_stage11 = req_stage1[0];
assign req_stage12 = req_stage1[1];
assign req_stage13 = req_stage1[2];
assign req_stage14 = req_stage1[3];
wire req_stage21,req_stage22;
assign req_stage21 = req_stage2[0];
assign req_stage22 = req_stage2[1];
reg [7:0] debug_val1, debug_val2;
integer debug_i;
always @(*) begin
    for (debug_i = 0;debug_i < 8;debug_i++ ) begin
        debug_val1[debug_i] <= Val1[debug_i];
        debug_val2[debug_i] <= Val2[debug_i];
    end
end


// FL
assign no_free_iq_jmp = (headp == tailp)?1'b1:1'b0;
assign one_free_iq_jmp = (headp+4'd1 == tailp)?1'b1:1'b0;

// RdyTable
always @(*) begin
    for (k = 0;k < 8; k++) begin
        Rdy1[k] <= RdyTable[Src1[k]];
        Rdy2[k] <= RdyTable[Src2[k]];
    end
end
assign rd_valid1_jmp = (!prs1_valid1_jmp && !prs2_valid1_jmp) | (prs1_valid1_jmp && !prs2_valid1_jmp && rd1_jmp!=5'b0);
assign rd_valid2_jmp = (!prs1_valid2_jmp && !prs2_valid2_jmp) | (prs1_valid2_jmp && !prs2_valid2_jmp && rd2_jmp!=5'b0);

// Select
always @(*) begin
    for (m = 0; m < 8; m++) begin
        Req[m] <= !Issued[m] & (!Val1[m]|Rdy1[m]) & (!Val2[m]|Rdy2[m]);
    end
    // stage1
    for (s1 = 0; s1 < 4; s1++) begin
        if(Req[s1*2] && !Req[s1*2+1]) begin
            req_stage1[s1] <= Req[s1*2];
            age_stage1[s1] <= Pos[s1*2];
            p_stage1[s1] <= s1*2;
        end
        else if(!Req[s1*2] && Req[s1*2+1]) begin
            req_stage1[s1] <= Req[s1*2+1];
            age_stage1[s1] <= Pos[s1*2+1];
            p_stage1[s1] <= s1*2+1;
        end else begin
            if (Pos[s1*2][5] == Pos[s1*2+1][5]) begin
                req_stage1[s1] <= (Pos[s1*2][4:0] < Pos[s1*2+1][4:0])?Req[s1*2]:Req[s1*2+1];
                age_stage1[s1] <= (Pos[s1*2][4:0] < Pos[s1*2+1][4:0])?Pos[s1*2]:Pos[s1*2+1];
                p_stage1[s1] <= (Pos[s1*2][4:0] < Pos[s1*2+1][4:0])?s1*2:s1*2+1;
            end else begin
                req_stage1[s1] <= (Pos[s1*2][4:0] < Pos[s1*2+1][4:0])?Req[s1*2+1]:Req[s1*2];
                age_stage1[s1] <= (Pos[s1*2][4:0] < Pos[s1*2+1][4:0])?Pos[s1*2+1]:Pos[s1*2];
                p_stage1[s1] <= (Pos[s1*2][4:0] < Pos[s1*2+1][4:0])?s1*2+1:s1*2;
            end
        end
    end
    // stage2
    for (s2 = 0; s2 < 2; s2++) begin
        if(req_stage1[s2*2] && !req_stage1[s2*2+1]) begin
            req_stage2[s2] <= req_stage1[s2*2];
            age_stage2[s2] <= age_stage1[s2*2];
            p_stage2[s2] <= p_stage1[s2*2];
        end else if(!req_stage1[s2*2] && req_stage1[s2*2+1]) begin
            req_stage2[s2] <= req_stage1[s2*2+1];
            age_stage2[s2] <= age_stage1[s2*2+1];
            p_stage2[s2] <= p_stage1[s2*2+1];
        end else begin
            if (age_stage1[s2*2][5] == age_stage1[s2*2+1][5]) begin
                req_stage2[s2] <= (age_stage1[s2*2][4:0] < age_stage1[s2*2+1][4:0])?req_stage1[s2*2]:req_stage1[s2*2+1];
                age_stage2[s2] <= (age_stage1[s2*2][4:0] < age_stage1[s2*2+1][4:0])?age_stage1[s2*2]:age_stage1[s2*2+1];
                p_stage2[s2] <= (age_stage1[s2*2][4:0] < age_stage1[s2*2+1][4:0])?p_stage1[s2*2]:p_stage1[s2*2+1];
            end else begin
                req_stage2[s2] <= (age_stage1[s2*2][4:0] < age_stage1[s2*2+1][4:0])?req_stage1[s2*2+1]:req_stage1[s2*2];
                age_stage2[s2] <= (age_stage1[s2*2][4:0] < age_stage1[s2*2+1][4:0])?age_stage1[s2*2+1]:age_stage1[s2*2];
                p_stage2[s2] <= (age_stage1[s2*2][4:0] < age_stage1[s2*2+1][4:0])?p_stage1[s2*2+1]:p_stage1[s2*2];
            end
        end
    end
    // stage3
    if(req_stage2[0] && !req_stage2[1]) begin
        req_issue <= req_stage2[0];
        p_issue <= p_stage2[0];
    end else if(!req_stage2[0] && req_stage2[1]) begin
        req_issue <= req_stage2[1];
        p_issue <= p_stage2[1];
    end else begin
        if (age_stage2[0][5] == age_stage2[1][5]) begin
            req_issue <= (age_stage2[0][4:0] < age_stage2[1][4:0])?req_stage2[0]:req_stage2[1];
            p_issue <= (age_stage2[0][4:0] < age_stage2[1][4:0])?p_stage2[0]:p_stage2[1];
        end else begin
            req_issue <= (age_stage2[0][4:0] < age_stage2[1][4:0])?req_stage2[1]:req_stage2[0];
            p_issue <= (age_stage2[0][4:0] < age_stage2[1][4:0])?p_stage2[1]:p_stage2[0];
        end
    end
end

// Issue
always @(*) begin
    pos_issue <= Pos[p_issue];
    prd_issue <= Dest[p_issue];
    prs1_issue <= Src1[p_issue];
    prs1_valid_issue <= Val1[p_issue];
    prs2_issue <= Src2[p_issue];
    prs2_valid_issue <= Val2[p_issue];
    funct3_issue <= Funct3[p_issue];
    funct7_issue <= Funct7[p_issue];
    rs1_issue <= RS1[p_issue];
    rs2_issue <= RS2[p_issue];
    rd_issue <= RD[p_issue];
    pc_issue <= PC[p_issue];
    alubypass1_issue <= RdyAluBypass[Src1[p_issue]];
    alubypass2_issue <= RdyAluBypass[Src2[p_issue]];
    jmpbypass1_issue <= RdyJmpBypass[Src1[p_issue]];
    jmpbypass2_issue <= RdyJmpBypass[Src2[p_issue]];
end


assign headp_next = headp+4'd1;

always @(posedge clk ) begin
    if (reset) begin
        for (i = 0; i < 8; i++) begin
            FL[i] <= i;
            Issued[i] <= 1'b1;
            //Val1[i] <= 1'b1;
            //Val2[i] <= 1'b1;
        end
        headp <= 4'b0;
        tailp <= 4'b1000;
        for (j = 0;j < 64; j++) begin
            RdyTable[j] <= 1'b1;
            RdyAluBypass[j] <= 1'b0;
            RdyJmpBypass[j] <= 1'b0;
        end
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
            Pos[FL[headp[2:0]]] <= pos1_jmp;
            Src1[FL[headp[2:0]]] <= prs11_jmp;
            Val1[FL[headp[2:0]]] <= prs1_valid1_jmp;
            Src2[FL[headp[2:0]]] <= prs21_jmp;
            Val2[FL[headp[2:0]]] <= prs2_valid1_jmp;
            Dest[FL[headp[2:0]]] <= prd1_jmp;
            Issued[FL[headp[2:0]]] <= 1'b0;
            Funct3[FL[headp[2:0]]] <= funct31_jmp;
            Funct7[FL[headp[2:0]]] <= funct71_jmp;
            RS1[FL[headp[2:0]]] <= rs11_jmp;
            RS2[FL[headp[2:0]]] <= rs21_jmp;
            RD[FL[headp[2:0]]] <= rd1_jmp;
            PC[FL[headp[2:0]]] <= pc1_jmp;
            if (rd_valid1_jmp) begin
                RdyTable[prd1_jmp] <= 1'b0;  // TODO: get prd_lsq/jmp with valid as well
            end
            headp <= headp + 4'd1;
        end else if(ins_valid1_jmp==1'b0 && ins_valid2_jmp==1'b1) begin
            Pos[FL[headp[2:0]]] <= pos2_jmp;
            Src1[FL[headp[2:0]]] <= prs12_jmp;
            Val1[FL[headp[2:0]]] <= prs1_valid2_jmp;
            Src2[FL[headp[2:0]]] <= prs22_jmp;
            Val2[FL[headp[2:0]]] <= prs2_valid2_jmp;
            Dest[FL[headp[2:0]]] <= prd2_jmp;
            Issued[FL[headp[2:0]]] <= 1'b0;
            Funct3[FL[headp[2:0]]] <= funct32_jmp;
            Funct7[FL[headp[2:0]]] <= funct72_jmp;
            RS1[FL[headp[2:0]]] <= rs12_jmp;
            RS2[FL[headp[2:0]]] <= rs22_jmp;
            RD[FL[headp[2:0]]] <= rd2_jmp;
            PC[FL[headp[2:0]]] <= pc2_jmp;
            if (rd_valid2_jmp) begin
                RdyTable[prd2_jmp] <= 1'b0;
            end
            headp <= headp + 4'd1;
        end else if (ins_valid1_jmp==1'b1 && ins_valid2_jmp==1'b1) begin
            Pos[FL[headp[2:0]]] <= pos1_jmp;
            Src1[FL[headp[2:0]]] <= prs11_jmp;
            Val1[FL[headp[2:0]]] <= prs1_valid1_jmp;
            Src2[FL[headp[2:0]]] <= prs21_jmp;
            Val2[FL[headp[2:0]]] <= prs2_valid1_jmp;
            Dest[FL[headp[2:0]]] <= prd1_jmp;
            Issued[FL[headp[2:0]]] <= 1'b0;
            Funct3[FL[headp[2:0]]] <= funct31_jmp;
            Funct7[FL[headp[2:0]]] <= funct71_jmp;
            RS1[FL[headp[2:0]]] <= rs11_jmp;
            RS2[FL[headp[2:0]]] <= rs21_jmp;
            RD[FL[headp[2:0]]] <= rd1_jmp;
            PC[FL[headp[2:0]]] <= pc1_jmp;
            if (rd_valid1_jmp) begin
                RdyTable[prd1_jmp] <= 1'b0;
            end
            Pos[FL[headp_next[2:0]]] <= pos2_jmp;
            Src1[FL[headp_next[2:0]]] <= prs12_jmp;
            Val1[FL[headp_next[2:0]]] <= prs1_valid2_jmp;
            Src2[FL[headp_next[2:0]]] <= prs22_jmp;
            Val2[FL[headp_next[2:0]]] <= prs2_valid2_jmp;
            Dest[FL[headp_next[2:0]]] <= prd2_jmp;
            Issued[FL[headp_next[2:0]]] <= 1'b0;
            Funct3[FL[headp_next[2:0]]] <= funct32_jmp;
            Funct7[FL[headp_next[2:0]]] <= funct72_jmp;
            RS1[FL[headp_next[2:0]]] <= rs12_jmp;
            RS2[FL[headp_next[2:0]]] <= rs22_jmp;
            RD[FL[headp_next[2:0]]] <= rd2_jmp;
            PC[FL[headp_next[2:0]]] <= pc2_jmp;
            if (rd_valid2_jmp) begin
                RdyTable[prd2_jmp] <= 1'b0;
            end
            headp <= headp + 4'd2;
        end
    end

    // Wakeup
    if (req_issue) begin
        RdyTable[Dest[p_issue]] <= 1'b1;
        RdyJmpBypass[Dest[p_issue]] <= 1'b1;
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
    if (req_issue) begin
        Issued[p_issue] <= 1'b1;
        /*
        pos_issue <= Pos[p_issue];
        prd_issue <= Dest[p_issue];
        prs1_issue <= Src1[p_issue];
        prs1_valid_issue <= Val1[p_issue];
        prs2_issue <= Src2[p_issue];
        prs2_valid_issue <= Val2[p_issue];
        funct3_issue <= Funct3[p_issue];
        funct7_issue <= Funct7[p_issue];
        isauipc_issue <= Isauipc[p_issue];
        rs1_issue <= RS1[p_issue];
        rs2_issue <= RS2[p_issue];
        pc_issue <= PC[p_issue];
        */
        FL[tailp[2:0]] <= p_issue;
        tailp <= tailp + 4'd1;
        //Val1[p_issue] <= 1'b1;
        //Val2[p_issue] <= 1'b1;
    end


end


    
endmodule
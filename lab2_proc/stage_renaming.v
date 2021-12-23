module stage_renaming (
    input clk,
    input reset,
    
    input ins_valid1,
    input [6:0] opcode1,
    input [4:0] rd1,
    input [4:0] rs11,
    input [4:0] rs21,
    //input [2:0] funct31,
    //input [6:0] funct71,
    //input [11:0] csr1,

    input ins_valid2,
    input [6:0] opcode2,
    input [4:0] rd2,
    input [4:0] rs12,
    input [4:0] rs22,
    //input [2:0] funct32,
    //input [6:0] funct72,
    //input [11:0] csr2,

    
    output reg ins_renamed_valid1,
    output wire rd_valid1,
    output reg [5:0] prd1,  // physical reg
    output reg [5:0] oprd1,
    output reg [5:0] prs11,
    output reg [5:0] prs21,
    
    output reg ins_renamed_valid2,
    output wire rd_valid2,
    output reg [5:0] prd2,
    output reg [5:0] oprd2,
    output reg [5:0] prs12,
    output reg [5:0] prs22,


    // interface with RAT
    output reg [4:0] raddrRATsr11,
    input [5:0] rdataRATsr11,
    output reg [4:0] raddrRATsr21,
    input [5:0] rdataRATsr21,
    output reg [4:0] raddrRATdest1,
    input [5:0] rdataRATdest1,
    output reg wenRATdest1,  // modify under any condition
    output reg [4:0] waddrRATdest1,
    output reg [5:0] wdataRATdest1,

    output reg [4:0] raddrRATsr12,
    input [5:0] rdataRATsr12,
    output reg [4:0] raddrRATsr22,
    input [5:0] rdataRATsr22,
    output reg [4:0] raddrRATdest2,
    input [5:0] rdataRATdest2,
    output reg wenRATdest2,  // modify under any condition
    output reg [4:0] waddrRATdest2,
    output reg [5:0] wdataRATdest2,

    // interface with freelist
    input no_free_pr,
    input one_free_pr,
    output reg [1:0] pop_fl_RAT,  // modify under any condition
    input [5:0] pop_data_fl_RAT1,
    input [5:0] pop_data_fl_RAT2,

    output reg stall_renaming  // 1: no enough room in fl

);

//wire rd_valid1, rd_valid2;
assign rd_valid1 = !(opcode1==7'b1100011 | opcode1==7'b0100011 | (opcode1==7'b1100111&&rd1==5'b0));
assign rd_valid2 = !(opcode2==7'b1100011 | opcode2==7'b0100011 | (opcode2==7'b1100111&&rd2==5'b0));

always @(*) begin
    if (!ins_valid1) begin  // if ins1 is invalid, ins2 is invalid neither
        wenRATdest1 <= 1'b0;  // key1
        wenRATdest2 <= 1'b0;  // key2
        pop_fl_RAT <= 2'b0;  //key3
        ins_renamed_valid1 <= 1'b0;  // key4
        ins_renamed_valid2 <= 1'b0;  // key5
        stall_renaming <= 1'b0;  // key6
    end else if (!ins_valid2) begin  // ins is valid & ins2 is not
        // ins1 is restricted by freelist
        wenRATdest2 <= 1'b0;  // key2
        ins_renamed_valid2 <= 1'b0;  // key5
        if (!rd_valid1) begin
            wenRATdest1 <= 1'b0;  // key1
            pop_fl_RAT <= 2'b0;  // key3
            ins_renamed_valid1 <= 1'b1;  // key 4
            stall_renaming <= 1'b0;  // key6
            raddrRATsr11 <= rs11;
            raddrRATsr21 <= rs21;
            prs11 <= rdataRATsr11;
            prs21 <= rdataRATsr21;
        end
        // deal with freelist
        else if (no_free_pr) begin  // no enough room for fl
            wenRATdest1 <= 1'b0;  // key1
            pop_fl_RAT <= 2'b0;  // key3
            ins_renamed_valid1 <= 1'b0;  // key 4
            stall_renaming <= 1'b1;  // key6
        end else begin
            pop_fl_RAT <= 2'b01;  // key3
            raddrRATsr11 <= rs11;
            raddrRATsr21 <= rs21;
            raddrRATdest1 <= rd1;
            wenRATdest1 <= 1'b1;  // key1
            waddrRATdest1 <= rd1;
            wdataRATdest1 <= pop_data_fl_RAT1;
            ins_renamed_valid1 <= 1'b1;  // key4
            prd1 <= pop_data_fl_RAT1;
            oprd1 <= rdataRATdest1;
            prs11 <= rdataRATsr11;
            prs21 <= rdataRATsr21;
            stall_renaming <= 1'b0;  // key6
        end
    end else begin  // both ins are valid
        if (!rd_valid1 && !rd_valid2) begin  // 1n2n
            wenRATdest2 <= 1'b0;  // key2
            pop_fl_RAT <= 2'b0;  // key3
            ins_renamed_valid1 <= 1'b1;  // key4
            ins_renamed_valid2 <= 1'b1;  // key5
            raddrRATsr11 <= rs11;
            raddrRATsr21 <= rs21;
            raddrRATsr12 <= rs12;
            raddrRATsr22 <= rs22;
            prs11 <= rdataRATsr11;
            prs21 <= rdataRATsr21;
            prs12 <= rdataRATsr12;
            prs22 <= rdataRATsr22;
            wenRATdest1 <= 1'b0;  // key1
            stall_renaming <= 1'b0;  // key6
        end else if (rd_valid1 && !rd_valid2) begin  // 1p2n
            if (no_free_pr) begin
                wenRATdest1 <= 1'b0;  // key1
                wenRATdest2 <= 1'b0;  // key2
                pop_fl_RAT <= 2'b0;  // key3
                ins_renamed_valid1 <= 1'b0;  // key4
                ins_renamed_valid2 <= 1'b0;  // key5
                stall_renaming <= 1'b1;  // key6
            end else begin
                wenRATdest2 <= 1'b0;  // key2
                pop_fl_RAT <= 2'b01;  // key3
                ins_renamed_valid1 <= 1'b1;  // key4
                ins_renamed_valid2 <= 1'b1;  // key5
                raddrRATsr11 <= rs11;
                raddrRATsr21 <= rs21;
                raddrRATdest1 <= rd1;
                raddrRATsr12 <= rs12;
                raddrRATsr22 <= rs22;
                prs11 <= rdataRATsr11;
                prs21 <= rdataRATsr21;
                prd1 <= pop_data_fl_RAT1;
                oprd1 <= rdataRATdest1;
                // raw
                if (rs12 == rd1) begin
                    prs12 <= pop_data_fl_RAT1;
                end else begin
                    prs12 <= rdataRATsr12;
                end
                if (rs22 == rd1) begin
                    prs22 <= pop_data_fl_RAT1;
                end else begin
                    prs22 <= rdataRATsr22;
                end
                wenRATdest1 <= 1'b1;  // key1
                waddrRATdest1 <= rd1;
                wdataRATdest1 <= pop_data_fl_RAT1;
                stall_renaming <= 1'b0;  // key6
            end    
        end else if (!rd_valid1 && rd_valid2) begin  // 1n2p
            if (no_free_pr) begin
                wenRATdest1 <= 1'b0;  // key1
                wenRATdest2 <= 1'b0;  // key2
                pop_fl_RAT <= 2'b0;  // key3
                ins_renamed_valid1 <= 1'b0;  // key4
                ins_renamed_valid2 <= 1'b0;  // key5
                stall_renaming <= 1'b1;  // key6
            end else begin
                wenRATdest2 <= 1'b1;  // key2
                waddrRATdest2 <= rd2;
                pop_fl_RAT <= 2'b01;  // key3
                wdataRATdest2 <= pop_data_fl_RAT1;
                ins_renamed_valid1 <= 1'b1;  // key4
                ins_renamed_valid2 <= 1'b1;  // key5
                raddrRATsr11 <= rs11;
                raddrRATsr21 <= rs21;
                raddrRATsr12 <= rs12;
                raddrRATsr22 <= rs22;
                raddrRATdest2 <= rd2;
                prs11 <= rdataRATsr11;
                prs21 <= rdataRATsr21;
                prd2 <= pop_data_fl_RAT1;
                prs12 <= rdataRATsr12;
                prs22 <= rdataRATsr22;
                wenRATdest1 <= 1'b0;  // key1
                oprd2 <= rdataRATdest2;
                stall_renaming <= 1'b0;  // key6
            end
        end else begin // 1p2p
            if (no_free_pr | one_free_pr) begin
                wenRATdest1 <= 1'b0;  // key1
                wenRATdest2 <= 1'b0;  // key2
                pop_fl_RAT <= 2'b0;  // key3
                ins_renamed_valid1 <= 1'b0;  // key4
                ins_renamed_valid2 <= 1'b0;  // key5
                stall_renaming <= 1'b1;  // key6
            end else begin
                wenRATdest2 <= 1'b1;  // key2
                waddrRATdest2 <= rd2;
                pop_fl_RAT <= 2'b10;  // key3
                wdataRATdest2 <= pop_data_fl_RAT2;
                ins_renamed_valid1 <= 1'b1;  // key4
                ins_renamed_valid2 <= 1'b1;  // key5
                raddrRATsr11 <= rs11;
                raddrRATsr21 <= rs21;
                raddrRATdest1 <= rd1;
                raddrRATsr12 <= rs12;
                raddrRATsr22 <= rs22;
                raddrRATdest2 <= rd2;
                prs11 <= rdataRATsr11;
                prs21 <= rdataRATsr21;
                prd1 <= pop_data_fl_RAT1;
                prd2 <= pop_data_fl_RAT2;
                oprd1 <= rdataRATdest1;
                // raw
                if (rs12 == rd1) begin
                    prs12 <= pop_data_fl_RAT1;
                end else begin
                    prs12 <= rdataRATsr12;
                end
                if (rs22 == rd1) begin
                    prs22 <= pop_data_fl_RAT1;
                end else begin
                    prs22 <= rdataRATsr22;
                end
                // waw
                if (rd1 == rd2) begin
                    wenRATdest1 <= 1'b0;  // key1
                    //oprd2 <= rdataRATdest1;
                    oprd2 = pop_data_fl_RAT1;
                end else begin
                    wenRATdest1 <= 1'b1;  // key1
                    waddrRATdest1 <= rd1;
                    wdataRATdest1 <= pop_data_fl_RAT1;
                    oprd2 <= rdataRATdest2;
                end
                stall_renaming <= 1'b0;  // key6
            end
        end
    end
end



    
endmodule
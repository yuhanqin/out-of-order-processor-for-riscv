module stage_dispatch (
    input clk,
    input reset,
    
    input [6:0] opcode1,
    //input [5:0] prd1,
    //input [5:0] oprd1,
    //input [5:0] prs11,
    //input [5:0] prs21,
    input [2:0] funct31,
    //input [6:0] funct71,
    //input [11:0] csr1,
    input ins_valid1,
    input [6:0] opcode2,
    //input [5:0] prd2,
    //input [5:0] oprd2,
    //input [5:0] prs12,
    //input [5:0] prs22,
    input [2:0] funct32,
    //input [6:0] funct72,
    //input [11:0] csr2,
    input ins_valid2,

    // to alu iq
    input no_free_iq_alu,
    input one_free_iq_alu,
    output reg ins_valid1_alu,
    //output reg [5:0] prd_alu,
    //output reg [5:0] prs1_alu,
    output reg prs1_valid1_alu,
    //output reg [5:0] prs2_alu,
    output reg prs2_valid1_alu,
    output reg isauipc1_alu,  // patch
    //output reg [2:0] funct3_alu,
    //output reg [6:0] funct7_alu,
    output reg ins_valid2_alu,
    output reg prs1_valid2_alu,
    output reg prs2_valid2_alu,
    output reg isauipc2_alu,

    // to lsq iq
    input no_free_iq_lsq,
    input one_free_iq_lsq,
    output reg ins_valid1_lsq,
    output reg prd_valid1_lsq,
    output reg prs2_valid1_lsq,
    output reg ins_valid2_lsq,
    output reg prd_valid2_lsq,
    output reg prs2_valid2_lsq,

    // to jmp iq
    input no_free_iq_jmp,
    input one_free_iq_jmp,
    output reg ins_valid1_jmp,
    output reg prs1_valid1_jmp,//
    output reg prs2_valid1_jmp,//
    output reg ins_valid2_jmp,
    output reg prs1_valid2_jmp,//
    output reg prs2_valid2_jmp,//

    // ROB
    input no_free_rob,
    input one_free_rob,
    output reg [1:0] ins_valid_rob,
    output reg [1:0] ins1_type_rob,  // 00: alu, 01: lsq, 10: jmp
    output reg [1:0] ins2_type_rob,

    // stall
    output reg stall_dispatch

);

//reg [1:0] ins1_type_rob;
//reg [1:0] ins2_type_rob;

always @(*) begin
    if (!ins_valid1) begin
        ins_valid1_alu <= 1'b0;
        ins_valid2_alu <= 1'b0;
        ins_valid1_lsq <= 1'b0;
        ins_valid2_lsq <= 1'b0;
        ins_valid1_jmp <= 1'b0;
        ins_valid2_jmp <= 1'b0;
        stall_dispatch <= 1'b0;
        ins_valid_rob <= 2'b00;
    end else if (!ins_valid2) begin  // only ins1 valid
        //ins_valid_rob <= (no_free_rob)?2'b00:2'b01;
        ins_valid_rob <= (stall_dispatch)?2'b00:2'b01;
        ins_valid2_alu <= 1'b0;
        ins_valid2_lsq <= 1'b0;
        ins_valid2_jmp <= 1'b0;
        if (ins1_type_rob == 2'b00) begin  // alu
            ins_valid1_alu <= (no_free_iq_alu | no_free_rob)?1'b0:1'b1;
            ins_valid1_lsq <= 1'b0;
            ins_valid1_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_alu | no_free_rob)?1'b1:1'b0; 
        end else if (ins1_type_rob == 2'b01) begin  // lsq
            ins_valid1_alu <= 1'b0;
            ins_valid1_lsq <= (no_free_iq_lsq | no_free_rob)?1'b0:1'b1;
            ins_valid1_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_lsq | no_free_rob)?1'b1:1'b0; 
        end else if (ins1_type_rob == 2'b10) begin  // jmp
            ins_valid1_alu <= 1'b0;
            ins_valid1_lsq <= 1'b0;
            ins_valid1_jmp <= (no_free_iq_jmp | no_free_rob)?1'b0:1'b1;
            stall_dispatch <= (no_free_iq_jmp | no_free_rob)?1'b1:1'b0; 
        end
    end else begin  // both ins valid
        //ins_valid_rob <= (no_free_rob | one_free_rob)?2'b00:2'b10;
        ins_valid_rob <= (stall_dispatch)?2'b00:2'b10;
        // 9 different situations
        if (ins1_type_rob == 2'b00 && ins2_type_rob == 2'b00) begin  // 1alu 2alu
            ins_valid1_alu <= (no_free_iq_alu | one_free_iq_alu | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_alu <= (no_free_iq_alu | one_free_iq_alu | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid1_lsq <= 1'b0;
            ins_valid2_lsq <= 1'b0;
            ins_valid1_jmp <= 1'b0;
            ins_valid2_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_alu | one_free_iq_alu | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b00 && ins2_type_rob == 2'b01) begin  // 1alu 2lsq
            ins_valid1_alu <= (no_free_iq_alu | no_free_iq_lsq | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_alu <= 1'b0;
            ins_valid1_lsq <= 1'b0;
            ins_valid2_lsq <= (no_free_iq_alu | no_free_iq_lsq | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid1_jmp <= 1'b0;
            ins_valid2_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_alu | no_free_iq_lsq | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b00 && ins2_type_rob == 2'b10) begin  // 1alu 2jmp
            ins_valid1_alu <= (no_free_iq_alu | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_alu <= 1'b0;
            ins_valid1_lsq <= 1'b0;
            ins_valid2_lsq <= 1'b0;
            ins_valid1_jmp <= 1'b0;
            ins_valid2_jmp <= (no_free_iq_alu | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            stall_dispatch <= (no_free_iq_alu | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b01 && ins2_type_rob == 2'b00) begin  // 1lsq 2alu
            ins_valid1_alu <= 1'b0;
            ins_valid2_alu <= (no_free_iq_alu | no_free_iq_lsq | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid1_lsq <= (no_free_iq_alu | no_free_iq_lsq | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_lsq <= 1'b0;
            ins_valid1_jmp <= 1'b0;
            ins_valid2_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_alu | no_free_iq_lsq | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b01 && ins2_type_rob == 2'b01) begin  // 1lsq 2lsq
            ins_valid1_alu <= 1'b0;
            ins_valid2_alu <= 1'b0;
            ins_valid1_lsq <= (no_free_iq_lsq | one_free_iq_lsq | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_lsq <= (no_free_iq_lsq | one_free_iq_lsq | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid1_jmp <= 1'b0;
            ins_valid2_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_lsq | one_free_iq_lsq | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b01 && ins2_type_rob == 2'b10) begin  // 1lsq 2jmp
            ins_valid1_alu <= 1'b0;
            ins_valid2_alu <= 1'b0;
            ins_valid1_lsq <= (no_free_iq_lsq | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_lsq <= 1'b0;
            ins_valid1_jmp <= 1'b0;
            ins_valid2_jmp <= (no_free_iq_lsq | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            stall_dispatch <= (no_free_iq_lsq | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b10 && ins2_type_rob == 2'b00) begin  // 1jmp 2alu
            ins_valid1_alu <= 1'b0;
            ins_valid2_alu <= (no_free_iq_alu | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid1_lsq <= 1'b0;
            ins_valid2_lsq <= 1'b0;
            ins_valid1_jmp <= (no_free_iq_alu | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_alu | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b10 && ins2_type_rob == 2'b01) begin  // 1jmp 2lsq
            ins_valid1_alu <= 1'b0;
            ins_valid2_alu <= 1'b0;
            ins_valid1_lsq <= 1'b0;
            ins_valid2_lsq <= (no_free_iq_lsq | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid1_jmp <= (no_free_iq_lsq | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_jmp <= 1'b0;
            stall_dispatch <= (no_free_iq_lsq | no_free_iq_jmp | no_free_rob | one_free_rob)?1'b1:1'b0;
        end else if (ins1_type_rob == 2'b10 && ins2_type_rob == 2'b10) begin  // 1jmp 2jmp
            ins_valid1_alu <= 1'b0;
            ins_valid2_alu <= 1'b0;
            ins_valid1_lsq <= 1'b0;
            ins_valid2_lsq <= 1'b0;
            ins_valid1_jmp <= (no_free_iq_jmp | one_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            ins_valid2_jmp <= (no_free_iq_jmp | one_free_iq_jmp | no_free_rob | one_free_rob)?1'b0:1'b1;
            stall_dispatch <= (no_free_iq_jmp | one_free_iq_jmp | no_free_rob | one_free_rob)?1'b1:1'b0;
        end
    end
end

always @(*) begin
    // ins1
    if (opcode1 == 7'b0110011) begin
        ins1_type_rob <= 2'b00;
        prs1_valid1_alu <= 1'b1;
        prs2_valid1_alu <= 1'b1;
        isauipc1_alu <= 1'b0;
    end else if (opcode1 == 7'b0010011) begin
        ins1_type_rob <= 2'b00;
        prs1_valid1_alu <= 1'b1;
        prs2_valid1_alu <= 1'b0;
        isauipc1_alu <= 1'b0;
    end else if (opcode1 == 7'b0110111) begin
        ins1_type_rob <= 2'b00;
        prs1_valid1_alu <= 1'b0;
        prs2_valid1_alu <= 1'b0;
        isauipc1_alu <= 1'b0;
    end else if (opcode1 == 7'b0010111) begin
        ins1_type_rob <= 2'b00;
        prs1_valid1_alu <= 1'b0;
        prs2_valid1_alu <= 1'b0;
        isauipc1_alu <= 1'b1;
    end else if (opcode1 == 7'b1101111) begin  // jmp
        ins1_type_rob <= 2'b10;
        prs1_valid1_jmp <= 1'b0;
        prs2_valid1_jmp <= 1'b0;
    end else if (opcode1 == 7'b1100111) begin
        ins1_type_rob <= 2'b10;
        prs1_valid1_jmp <= 1'b1;
        prs2_valid1_jmp <= 1'b0;
    end else if (opcode1 == 7'b1100011) begin
        ins1_type_rob <= 2'b10;
        prs1_valid1_jmp <= 1'b1;
        prs2_valid1_jmp <= 1'b1;
    end
    

    // ins2
    if (opcode2 == 7'b0110011) begin
        ins2_type_rob <= 2'b00;
        prs1_valid2_alu <= 1'b1;
        prs2_valid2_alu <= 1'b1;
        isauipc2_alu <= 1'b0;
    end else if (opcode2 == 7'b0010011) begin
        ins2_type_rob <= 2'b00;
        prs1_valid2_alu <= 1'b1;
        prs2_valid2_alu <= 1'b0;
        isauipc2_alu <= 1'b0;
    end else if (opcode2 == 7'b0110111) begin
        ins2_type_rob <= 2'b00;
        prs1_valid2_alu <= 1'b0;
        prs2_valid2_alu <= 1'b0;
        isauipc2_alu <= 1'b0;
    end else if (opcode2 == 7'b0010111) begin
        ins2_type_rob <= 2'b00;
        prs1_valid2_alu <= 1'b0;
        prs2_valid2_alu <= 1'b0;
        isauipc2_alu <= 1'b1;
    end else if (opcode2 == 7'b1101111) begin  // jmp
        ins2_type_rob <= 2'b10;
        prs1_valid2_jmp <= 1'b0;
        prs2_valid2_jmp <= 1'b0;
    end else if (opcode2 == 7'b1100111) begin
        ins2_type_rob <= 2'b10;
        prs1_valid2_jmp <= 1'b1;
        prs2_valid2_jmp <= 1'b0;
    end else if (opcode2 == 7'b1100011) begin
        ins2_type_rob <= 2'b10;
        prs1_valid2_jmp <= 1'b1;
        prs2_valid2_jmp <= 1'b1;
    end
end

    
endmodule
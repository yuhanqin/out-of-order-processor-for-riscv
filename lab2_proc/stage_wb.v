module stage_wb (
    input clk,
    input reset,
    input flush_iq,

    //alu
    input req_ex_alu,
    input [31:0] result_ex_alu,
    input [5:0] pos_ex_alu,
    input [5:0] prd_ex_alu,
    output reg req_alu_wb,
    output reg [31:0] result_alu_wb,
    output reg [5:0] pos_alu_wb,
    output reg [5:0] prd_alu_wb,

    //jmp
    input req_ex_jmp,
    input rd_valid_ex_jmp,
    input [31:0] result_ex_jmp,
    input pc_recover_jmp,
    //input [31:0] new_pc_jmp,
    input [5:0] pos_ex_jmp,
    input [5:0] prd_ex_jmp,
    output reg req_jmp_wb,
    output reg rd_valid_jmp_wb,
    output reg [31:0] result_jmp_wb,
    output reg pc_recover_jmp_wb,
    //output reg [31:0] new_pc_jmp_wb,
    output reg [5:0] pos_jmp_wb,
    output reg [5:0] prd_jmp_wb


);

always @(posedge clk) begin
    if (reset | flush_iq) begin
        req_alu_wb <= 1'b0;
    end else begin
        //alu
        req_alu_wb <= req_ex_alu;
        result_alu_wb <= result_ex_alu;
        pos_alu_wb <= pos_ex_alu;
        prd_alu_wb <= prd_ex_alu;
        //jmp
        req_jmp_wb <= req_ex_jmp;
        rd_valid_jmp_wb <= rd_valid_ex_jmp;
        result_jmp_wb <= result_ex_jmp;
        pc_recover_jmp_wb <= pc_recover_jmp;
        //new_pc_jmp_wb <= new_pc_jmp;
        pos_jmp_wb <= pos_ex_jmp;
        prd_jmp_wb <= prd_ex_jmp;
    end
end
    
endmodule
module PRF (
    input clk,
    input reset,
    input stall,
    
    input [5:0] prs1_rfread_alu,
    input [5:0] prs2_rfread_alu,
    output wire [31:0] datars1_ex_alu,
    output wire [31:0] datars2_ex_alu,
    input [5:0] prs1_rfread_jmp,
    input [5:0] prs2_rfread_jmp,
    output wire [31:0] datars1_ex_jmp,
    output wire [31:0] datars2_ex_jmp,

    input req_alu_wb,
    input [31:0] result_alu_wb,
    input [5:0] prd_alu_wb,
    input req_jmp_wb,
    input rd_valid_jmp_wb,
    input [31:0] result_jmp_wb,
    input [5:0] prd_jmp_wb,

    input pc_recover_jmp,
    input [31:0] new_pc_jmp,

    output wire [31:0] cur_pc

);

reg [31:0] RF [0:63];
reg [31:0] PC;
//reg [1:0] state [0:63];

integer i;

assign cur_pc = PC;

assign datars1_ex_alu = RF[prs1_rfread_alu];
assign datars2_ex_alu = RF[prs2_rfread_alu];
assign datars1_ex_jmp = RF[prs1_rfread_jmp];
assign datars2_ex_jmp = RF[prs2_rfread_jmp];

always @(posedge clk ) begin
    if (reset) begin
        for (i = 0; i < 64; i++ ) begin
            RF[i] <= 32'b0;
        end
        PC <= 32'h200;
    end else begin
        // pc
        if (pc_recover_jmp) begin
            PC <= new_pc_jmp;
        end else if (!stall) begin
            PC <= PC + 32'b1000;  //TODO
        end
        
        // wb
        if (req_alu_wb) begin
            RF[prd_alu_wb] <= result_alu_wb;
        end
        if (req_jmp_wb && rd_valid_jmp_wb) begin
            RF[prd_jmp_wb] <= result_jmp_wb;
        end
    end
end
    
endmodule
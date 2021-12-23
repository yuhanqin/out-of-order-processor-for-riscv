module latch_if_id (
    input clk,
    input reset,
    input stall_if_id,
    input flush_if_id,

    input [31:0] instr1_if,
    input [31:0] pc1_if,
    input ins_valid1_if,
    input [31:0] instr2_if,
    input [31:0] pc2_if,
    input ins_valid2_if,
    
    output reg [31:0] instr1_id,
    output reg [31:0] pc1_id,
    output reg ins_valid1_id,
    output reg [31:0] instr2_id,
    output reg [31:0] pc2_id,
    output reg ins_valid2_id
);

always @(posedge clk) begin
    if (reset | flush_if_id) begin
        instr1_id <= 32'b0;
        pc1_id <= 32'b0;
        ins_valid1_id <= 1'b0;
        instr2_id <= 32'b0;
        pc2_id <= 32'b0;
        ins_valid2_id <= 1'b0;
    end else if (stall_if_id) begin
        instr1_id <= instr1_id;
        pc1_id <= pc1_id;
        ins_valid1_id <= ins_valid1_id;
        instr2_id <= instr2_id;
        pc2_id <= pc2_id;
        ins_valid2_id <= ins_valid2_id;
    end else begin
        instr1_id <= instr1_if;
        pc1_id <= pc1_if;
        ins_valid1_id <= ins_valid1_if;
        instr2_id <= instr2_if;
        pc2_id <= pc2_if;
        ins_valid2_id <= ins_valid2_if;
    end
end
    
endmodule
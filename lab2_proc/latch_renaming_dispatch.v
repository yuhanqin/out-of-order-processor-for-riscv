module latch_renaming_dispatch (
    input clk,
    input reset,
    input stall_renaming_dispatch,
    input flush_renaming_dispatch,

    input [31:0] pc1_renaming,
    input [6:0] opcode1_renaming,
    input [4:0] rd1_renaming,
    input [4:0] rs11_renaming,
    input [4:0] rs21_renaming,
    input [5:0] prd1_renaming,
    input [5:0] oprd1_renaming,
    input [5:0] prs11_renaming,
    input [5:0] prs21_renaming,
    input [2:0] funct31_renaming,
    input [6:0] funct71_renaming,
    input [11:0] csr1_renaming,
    input ins_renamed_valid1_renaming,
    input rd_valid1_renaming,
    input [31:0] pc2_renaming,
    input [6:0] opcode2_renaming,
    input [4:0] rd2_renaming,
    input [4:0] rs12_renaming,
    input [4:0] rs22_renaming,
    input [5:0] prd2_renaming,
    input [5:0] oprd2_renaming,
    input [5:0] prs12_renaming,
    input [5:0] prs22_renaming,
    input [2:0] funct32_renaming,
    input [6:0] funct72_renaming,
    input [11:0] csr2_renaming,
    input ins_renamed_valid2_renaming,
    input rd_valid2_renaming,

    output reg [31:0] pc1_dispatch,
    output reg [6:0] opcode1_dispatch,
    output reg [4:0] rd1_dispatch,
    output reg [4:0] rs11_dispatch,
    output reg [4:0] rs21_dispatch,
    output reg [5:0] prd1_dispatch,
    output reg [5:0] oprd1_dispatch,
    output reg [5:0] prs11_dispatch,
    output reg [5:0] prs21_dispatch,
    output reg [2:0] funct31_dispatch,
    output reg [6:0] funct71_dispatch,
    output reg [11:0] csr1_dispatch,
    output reg ins_valid1_dispatch,
    output reg rd_valid1_dispatch,
    output reg [31:0] pc2_dispatch,
    output reg [6:0] opcode2_dispatch,
    output reg [4:0] rd2_dispatch,
    output reg [4:0] rs12_dispatch,
    output reg [4:0] rs22_dispatch,
    output reg [5:0] prd2_dispatch,
    output reg [5:0] oprd2_dispatch,
    output reg [5:0] prs12_dispatch,
    output reg [5:0] prs22_dispatch,
    output reg [2:0] funct32_dispatch,
    output reg [6:0] funct72_dispatch,
    output reg [11:0] csr2_dispatch,
    output reg ins_valid2_dispatch,
    output reg rd_valid2_dispatch
);




always @(posedge clk) begin
    if (reset | flush_renaming_dispatch) begin
        pc1_dispatch <= 32'b0;
        opcode1_dispatch <= 7'b0;
        rd1_dispatch <= 5'b0;
        rs11_dispatch <= 5'b0;
        rs21_dispatch <= 5'b0;
        prd1_dispatch <= 6'b0;
        oprd1_dispatch <= 6'b0;
        prs11_dispatch <= 6'b0;
        prs21_dispatch <= 6'b0;
        funct31_dispatch <= 3'b0;
        funct71_dispatch <= 7'b0;
        csr1_dispatch <= 12'b0;
        ins_valid1_dispatch <= 1'b0;
        rd_valid1_dispatch <= 1'b0;
        pc2_dispatch <= 32'b0;
        opcode2_dispatch <= 7'b0;
        rd2_dispatch <= 5'b0;
        rs12_dispatch <= 5'b0;
        rs22_dispatch <= 5'b0;
        prd2_dispatch <= 6'b0;
        oprd2_dispatch <= 6'b0;
        prs12_dispatch <= 6'b0;
        prs22_dispatch <= 6'b0;
        funct32_dispatch <= 3'b0;
        funct72_dispatch <= 7'b0;
        csr2_dispatch <= 12'b0;
        ins_valid2_dispatch <= 1'b0;
        rd_valid2_dispatch <= 1'b0;
    end else if (stall_renaming_dispatch) begin
        pc1_dispatch <= pc1_dispatch;
        opcode1_dispatch <= opcode1_dispatch;
        rd1_dispatch <= rd1_dispatch;
        rs11_dispatch <= rs11_dispatch;
        rs21_dispatch <= rs21_dispatch;
        prd1_dispatch <= prd1_dispatch;
        oprd1_dispatch <= oprd1_dispatch;
        prs11_dispatch <= prs11_dispatch;
        prs21_dispatch <= prs21_dispatch;
        funct31_dispatch <= funct31_dispatch;
        funct71_dispatch <= funct71_dispatch;
        csr1_dispatch <= csr1_dispatch;
        ins_valid1_dispatch <= ins_valid1_dispatch;
        rd_valid1_dispatch <= rd_valid1_dispatch;
        pc2_dispatch <= pc2_dispatch;
        opcode2_dispatch <= opcode2_dispatch;
        rd2_dispatch <= rd2_dispatch;
        rs12_dispatch <= rs12_dispatch;
        rs22_dispatch <= rs22_dispatch;
        prd2_dispatch <= prd2_dispatch;
        oprd2_dispatch <= oprd2_dispatch;
        prs12_dispatch <= prs12_dispatch;
        prs22_dispatch <= prs22_dispatch;
        funct32_dispatch <= funct32_dispatch;
        funct72_dispatch <= funct72_dispatch;
        csr2_dispatch <= csr2_dispatch;
        ins_valid2_dispatch <= ins_valid2_dispatch;
        rd_valid2_dispatch <= rd_valid2_dispatch;
    end else begin
        pc1_dispatch <= pc1_renaming;
        opcode1_dispatch <= opcode1_renaming;
        rd1_dispatch <= rd1_renaming;
        rs11_dispatch <= rs11_renaming;
        rs21_dispatch <= rs21_renaming;
        prd1_dispatch <= prd1_renaming;
        oprd1_dispatch <= oprd1_renaming;
        prs11_dispatch <= prs11_renaming;
        prs21_dispatch <= prs21_renaming;
        funct31_dispatch <= funct31_renaming;
        funct71_dispatch <= funct71_renaming;
        csr1_dispatch <= csr1_renaming;
        ins_valid1_dispatch <= ins_renamed_valid1_renaming;
        rd_valid1_dispatch <= rd_valid1_renaming;
        pc2_dispatch <= pc2_renaming;
        opcode2_dispatch <= opcode2_renaming;
        rd2_dispatch <= rd2_renaming;
        rs12_dispatch <= rs12_renaming;
        rs22_dispatch <= rs22_renaming;
        prd2_dispatch <= prd2_renaming;
        oprd2_dispatch <= oprd2_renaming;
        prs12_dispatch <= prs12_renaming;
        prs22_dispatch <= prs22_renaming;
        funct32_dispatch <= funct32_renaming;
        funct72_dispatch <= funct72_renaming;
        csr2_dispatch <= csr2_renaming;
        ins_valid2_dispatch <= ins_renamed_valid2_renaming;
        rd_valid2_dispatch <= rd_valid2_renaming;
    end
end
    
endmodule
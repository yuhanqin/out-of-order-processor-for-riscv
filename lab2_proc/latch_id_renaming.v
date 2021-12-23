module latch_id_renaming (
    input clk,
    input reset,
    input stall_id_renaming,
    input flush_id_renaming,

    //input pc_recover,
    input flush_iq,
    input ins_valid1_if,
    output wire pc_recover_stall,

    input [31:0] pc1_id,
    input [6:0] opcode1_id,
    input [4:0] rd1_id,
    input [4:0] rs11_id,
    input [4:0] rs21_id,
    input [2:0] funct31_id,
    input [6:0] funct71_id,
    input [11:0] csr1_id,
    input ins_valid1_id,
    input [31:0] pc2_id,
    input [6:0] opcode2_id,
    input [4:0] rd2_id,
    input [4:0] rs12_id,
    input [4:0] rs22_id,
    input [2:0] funct32_id,
    input [6:0] funct72_id,
    input [11:0] csr2_id,
    input ins_valid2_id,

    output reg [31:0] pc1_renaming,
    output reg [6:0] opcode1_renaming,
    output reg [4:0] rd1_renaming,
    output reg [4:0] rs11_renaming,
    output reg [4:0] rs21_renaming,
    output reg [2:0] funct31_renaming,
    output reg [6:0] funct71_renaming,
    output reg [11:0] csr1_renaming,
    output reg ins_valid1_renaming,
    output reg [31:0] pc2_renaming,
    output reg [6:0] opcode2_renaming,
    output reg [4:0] rd2_renaming,
    output reg [4:0] rs12_renaming,
    output reg [4:0] rs22_renaming,
    output reg [2:0] funct32_renaming,
    output reg [6:0] funct72_renaming,
    output reg [11:0] csr2_renaming,
    output reg ins_valid2_renaming

);

reg [1:0] pc_recover_stall_state;

assign pc_recover_stall = (pc_recover_stall_state==2'b10)?1'b1:1'b0;

always @(posedge clk ) begin
    if (reset | flush_id_renaming) begin
        pc1_renaming <= 32'b0;
        opcode1_renaming <= 7'b0;
        rd1_renaming <= 5'b0;
        rs11_renaming <= 5'b0;
        rs21_renaming <= 5'b0;
        funct31_renaming <= 3'b0;
        funct71_renaming <= 7'b0;
        csr1_renaming <= 12'b0;
        ins_valid1_renaming <= 1'b0;
        pc2_renaming <= 32'b0;
        opcode2_renaming <= 7'b0;
        rd2_renaming <= 5'b0;
        rs12_renaming <= 5'b0;
        rs22_renaming <= 5'b0;
        funct32_renaming <= 3'b0;
        funct72_renaming <= 7'b0;
        csr2_renaming <= 12'b0;
        ins_valid2_renaming <= 1'b0;
        pc_recover_stall_state <= (reset)?2'b00:2'b01;
    end else begin
        // pc recover stall fsm
        //if (pc_recover) begin
        //    pc_recover_stall_state <= 2'b01;
        //end
        if (pc_recover_stall_state==2'b01 && ins_valid1_if) begin
            pc_recover_stall_state <= 2'b10;
        end
        if (flush_iq) begin
            pc_recover_stall_state <= 2'b00;
        end

        if (stall_id_renaming) begin
            pc1_renaming <= pc1_renaming;
            opcode1_renaming <= opcode1_renaming;
            rd1_renaming <= rd1_renaming;
            rs11_renaming <= rs11_renaming;
            rs21_renaming <= rs21_renaming;
            funct31_renaming <= funct31_renaming;
            funct71_renaming <= funct71_renaming;
            csr1_renaming <= csr1_renaming;
            ins_valid1_renaming <= ins_valid1_renaming;
            pc2_renaming <= pc2_renaming;
            opcode2_renaming <= opcode2_renaming;
            rd2_renaming <= rd2_renaming;
            rs12_renaming <= rs12_renaming;
            rs22_renaming <= rs22_renaming;
            funct32_renaming <= funct32_renaming;
            funct72_renaming <= funct72_renaming;
            csr2_renaming <= csr2_renaming;
            ins_valid2_renaming <= ins_valid2_renaming;
        end else begin
            pc1_renaming <= pc1_id;
            opcode1_renaming <= opcode1_id;
            rd1_renaming <= rd1_id;
            rs11_renaming <= rs11_id;
            rs21_renaming <= rs21_id;
            funct31_renaming <= funct31_id;
            funct71_renaming <= funct71_id;
            csr1_renaming <= csr1_id;
            ins_valid1_renaming <= ins_valid1_id;
            pc2_renaming <= pc2_id;
            opcode2_renaming <= opcode2_id;
            rd2_renaming <= rd2_id;
            rs12_renaming <= rs12_id;
            rs22_renaming <= rs22_id;
            funct32_renaming <= funct32_id;
            funct72_renaming <= funct72_id;
            csr2_renaming <= csr2_id;
            ins_valid2_renaming <= ins_valid2_id;
        end
    end 
end
    
endmodule
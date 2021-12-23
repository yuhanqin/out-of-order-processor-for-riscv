module stage_if (
    input clk,
    input reset,
    input stall_if,
    input flush_if,

    input [31:0] fakeinstr1,
    input [31:0] fakeinstr2,
    input [31:0] fakepc1,
    input [31:0] fakepc2,
    
    output wire [31:0] instr1,
    output wire [31:0] pc1,
    output wire ins_valid1,
    output wire [31:0] instr2,
    output wire [31:0] pc2,
    output wire ins_valid2
);

reg [31:0] instr_buf [0:7];
reg [3:0] headp;
reg [3:0] tailp;


assign instr1 = fakeinstr1;
assign instr2 = fakeinstr2;
assign pc1 = fakepc1;
assign pc2 = fakepc2;
assign ins_valid1 = (reset|(pc1>32'h250))?1'b0:1'b1;
assign ins_valid2 = (reset|(pc2>32'h250))?1'b0:1'b1;
    
endmodule
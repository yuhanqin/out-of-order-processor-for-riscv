module recover_fsm (
    input clk,
    input reset,

    input req_ex_jmp,
    input pc_recover_jmp,
    input req_issue_jmp,  // reset grant

    output reg jmp_issue_grant,
    output wire stall_recover
);

reg [1:0] recover_state;

assign stall_recover = (recover_state==2'b)

always @(posedge clk) begin
    if (reset) begin
        jmp_issue_grant <= 1'b1;
        recover_state <= 2'b00;
    end else begin
        if (req_issue_jmp) begin
            jmp_issue_grant <= 1'b0;
        end
        if ((req_ex_jmp&&!pc_recover_jmp) | ) begin
            jmp_issue_grant <= 1'b1;
        end


        if (pc_recover_jmp) begin
            recover_state <= 2'b10;
        end
    end
end
    
endmodule
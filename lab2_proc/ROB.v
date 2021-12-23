module ROB (
    input clk,
    input reset,

    output wire no_free_rob,
    output wire one_free_rob,  // strictly adjust inputs based on these

    input [1:0] ins_valid_rob,
    input rd_valid1_rob,
    input [1:0] type1_rob,
    input [4:0] rd1_rob,
    input [5:0] prd1_rob,
    input [5:0] oprd1_rob,
    input [31:0] pc1_rob,
    input rd_valid2_rob,
    input [1:0] type2_rob,
    input [4:0] rd2_rob,
    input [5:0] prd2_rob,
    input [5:0] oprd2_rob,
    input [31:0] pc2_rob,

    // iq
    output wire [5:0] pos1_rob,
    output wire [5:0] pos2_rob,

    // reorder
    input req_alu_wb,
    input [5:0] pos_alu_wb,
    input req_jmp_wb,
    input pc_recover_jmp_wb,
    input [5:0] pos_jmp_wb,

    // jmp recover
    output reg flush_iq,

    // freelist_rat
    output reg [1:0] push_fl_RAT,
    output reg [5:0] push_data_fl_RAT1,
    output reg [5:0] push_data_fl_RAT2,

    // aRAT
    output reg [4:0] update_pos_aRAT1,
    output reg [4:0] update_pos_aRAT2,
    output reg [5:0] update_data_aRAT1,
    output reg [5:0] update_data_aRAT2

);

// Capacit of 32 instr.
reg Posbit [0:31];
reg [1:0] Type [0:31];
reg [4:0] Areg [0:31];
reg [5:0] Preg [0:31];
reg [5:0] OPreg [0:31];
reg RegVal [0:31];
reg [31:0] PC [0:31];
reg Exception [0:31];
reg Complete [0:31];

//  1 position bit + 4 actual bits
reg [5:0] headp;
reg [5:0] tailp;
wire [5:0] headp_next;
wire [5:0] tailp_next;
wire [5:0] headp_next_next;
wire [5:0] tailp_next_next;

assign no_free_rob = (headp[4:0]==tailp[4:0] && headp[5]!=tailp[5])?1'b1:1'b0;
assign one_free_rob = (headp[4:0]==tailp_next[4:0])?1'b1:1'b0;

assign pos1_rob = tailp;
assign pos2_rob = tailp+6'd1;

assign headp_next = headp+6'd1;
assign tailp_next = tailp+6'd1;
assign headp_next_next = headp+6'd2;
assign tailp_next_next = tailp+6'd2;

always @(posedge clk ) begin
    if (reset) begin
        headp <= 6'b0;
        tailp <= 6'b0;
        push_fl_RAT <= 2'b0;
        Complete[0] <= 1'b0;
        flush_iq <= 1'b0;
    end else begin
        // allocate
        if (ins_valid_rob==2'b01) begin
            Posbit[tailp[4:0]] <= tailp[5];
            Type[tailp[4:0]] <= type1_rob;
            Areg[tailp[4:0]] <= rd1_rob;
            Preg[tailp[4:0]] <= prd1_rob;
            OPreg[tailp[4:0]] <= oprd1_rob;
            RegVal[tailp[4:0]] <= rd_valid1_rob;
            PC[tailp[4:0]] <= pc1_rob;
            Exception[tailp[4:0]] <= 1'b0;
            Complete[tailp[4:0]] <= 1'b0;
            tailp <= tailp + 6'd1;
            Complete[tailp_next[4:0]] <= 1'b0;
        end else if (ins_valid_rob==2'b10) begin
            Posbit[tailp[4:0]] <= tailp[5];
            Type[tailp[4:0]] <= type1_rob;
            Areg[tailp[4:0]] <= rd1_rob;
            Preg[tailp[4:0]] <= prd1_rob;
            OPreg[tailp[4:0]] <= oprd1_rob;
            RegVal[tailp[4:0]] <= rd_valid1_rob;
            PC[tailp[4:0]] <= pc1_rob;
            Exception[tailp[4:0]] <= 1'b0;
            Complete[tailp[4:0]] <= 1'b0;
            Posbit[tailp_next[4:0]] <= tailp_next[5];
            Type[tailp_next[4:0]] <= type2_rob;
            Areg[tailp_next[4:0]] <= rd2_rob;
            Preg[tailp_next[4:0]] <= prd2_rob;
            OPreg[tailp_next[4:0]] <= oprd2_rob;
            RegVal[tailp_next[4:0]] <= rd_valid2_rob;
            PC[tailp_next[4:0]] <= pc2_rob;
            Exception[tailp_next[4:0]] <= 1'b0;
            Complete[tailp_next[4:0]] <= 1'b0;
            tailp <= tailp + 6'd2;
            Complete[tailp_next_next[4:0]] <= 1'b0;
        end

        // complete
        if (req_alu_wb) begin
            Complete[pos_alu_wb[4:0]] <= 1'b1;
        end
        if (req_jmp_wb) begin
            Complete[pos_jmp_wb[4:0]] <= 1'b1;
            if (pc_recover_jmp_wb) begin
                Exception[pos_jmp_wb[4:0]] <= 1'b1;
            end
        end

        // free
        if (Complete[headp[4:0]] == 1'b1) begin
            if (Exception[headp[4:0]] == 1'b1) begin
                flush_iq <= 1'b1;
                headp <= headp_next;
                tailp <= headp_next;
                if (RegVal[headp[4:0]] == 1'b1) begin
                    push_fl_RAT <= 2'b01;
                    push_data_fl_RAT1 <= OPreg[headp[4:0]];
                    update_pos_aRAT1 <= Areg[headp[4:0]];
                    update_data_aRAT1 <= Preg[headp[4:0]];
                end else begin
                    push_fl_RAT <= 2'b00;  // illegal rd
                end        
                Complete[headp_next[4:0]] <= 1'b0;
            end
            else if (Complete[headp_next[4:0]] == 1'b1) begin
                headp <= headp_next_next;
                if (RegVal[headp[4:0]] && RegVal[headp_next[4:0]]) begin
                    push_fl_RAT <= 2'b10;
                    push_data_fl_RAT1 <= OPreg[headp[4:0]];
                    push_data_fl_RAT2 <= OPreg[headp_next[4:0]];
                    update_pos_aRAT1 <= Areg[headp[4:0]];
                    update_pos_aRAT2 <= Areg[headp_next[4:0]];
                    update_data_aRAT1 <= Preg[headp[4:0]];
                    update_data_aRAT2 <= Preg[headp_next[4:0]];
                end else if (RegVal[headp[4:0]] && !RegVal[headp_next[4:0]]) begin
                    push_fl_RAT <= 2'b01;
                    push_data_fl_RAT1 <= OPreg[headp[4:0]];
                    update_pos_aRAT1 <= Areg[headp[4:0]];
                    update_data_aRAT1 <= Preg[headp[4:0]];
                end else if (!RegVal[headp[4:0]] && RegVal[headp_next[4:0]]) begin
                    push_fl_RAT <= 2'b01;
                    push_data_fl_RAT1 <= OPreg[headp_next[4:0]];
                    update_pos_aRAT1 <= Areg[headp_next[4:0]];
                    update_data_aRAT1 <= Preg[headp_next[4:0]];
                end else begin
                    push_fl_RAT <= 2'b00;
                end
                if (Exception[headp_next[4:0]] == 1'b1) begin
                    flush_iq <= 1'b1;
                    tailp <= headp_next_next;
                    Complete[headp_next_next[4:0]] <= 1'b0;  // TODO
                end else begin
                    flush_iq <= 1'b0;
                end
            end else begin
                headp <= headp + 6'd1;
                flush_iq <= 1'b0;
                if (RegVal[headp[4:0]]) begin
                    push_fl_RAT <= 2'b01;
                    push_data_fl_RAT1 <= OPreg[headp[4:0]];
                    update_pos_aRAT1 <= Areg[headp[4:0]];
                    update_data_aRAT1 <= Preg[headp[4:0]];
                end else begin
                    push_fl_RAT <= 2'b00;
                end
            end
        end else begin
            push_fl_RAT <= 2'b0;
            flush_iq <= 1'b0;
        end
    end
    
end



    
endmodule
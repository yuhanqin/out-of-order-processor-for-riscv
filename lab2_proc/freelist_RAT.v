module freelist_RAT (
    input clk,
    input reset,
    input stall_freelist_RAT,
    input flush_iq,

    output wire no_free_pr,
    output wire one_free_pr,  // strictly adjust inputs based on these

    input [1:0] pop_fl_RAT,
    output wire [5:0] pop_data_fl_RAT1,
    output wire [5:0] pop_data_fl_RAT2,

    input [1:0] push_fl_RAT,  // remember to set to 0 after using
    input [5:0] push_data_fl_RAT1,
    input [5:0] push_data_fl_RAT2
);

reg [5:0] aheadp;
integer j;

reg [5:0] freelist [0:63]; // there are at most 32 free reg; may be a bug
reg [5:0] headp;  // points at one free reg
reg [5:0] tailp;  // points at one empty entry in freelist
wire [5:0] headp_next;
wire [5:0] tailp_next;
assign headp_next = headp+6'd1;
assign tailp_next = tailp+6'd1;
integer i;

assign no_free_pr = (headp == tailp)?1'b1:1'b0;
assign one_free_pr = (headp_next == tailp)?1'b1:1'b0;
assign pop_data_fl_RAT1 = freelist[headp];
assign pop_data_fl_RAT2 = freelist[headp_next];

always @(posedge clk ) begin
    if (reset) begin
        for (i = 0;i < 32 ;i++ ) begin
            freelist[i] <= 32+i;
        end
        headp <= 6'b0;
        tailp <= 6'b100000;
        aheadp <= 6'b0;
    end else begin

        if (flush_iq) begin
            if (push_fl_RAT == 2'b01) begin
                headp <= aheadp + 6'd1;
            end else if (push_fl_RAT == 2'b10) begin
                headp <= aheadp + 6'd2;
            end else begin
                headp <= aheadp;
            end
            
        end

        if (!stall_freelist_RAT) begin
            if (pop_fl_RAT == 2'b01) begin
                headp <= headp + 6'd1;
            end else if (pop_fl_RAT == 2'b10) begin
                headp <= headp + 6'd2;
            end
        end
        if (push_fl_RAT == 2'b01) begin
            freelist[tailp] <= push_data_fl_RAT1;
            tailp <= tailp + 6'd1;
            aheadp <= aheadp + 6'd1;
        end else if (push_fl_RAT == 2'b10) begin
            freelist[tailp] <= push_data_fl_RAT1;
            freelist[tailp_next] <= push_data_fl_RAT2;
            tailp <= tailp + 6'd2;
            aheadp <= aheadp + 6'd2;
        end

    end
end


    
endmodule
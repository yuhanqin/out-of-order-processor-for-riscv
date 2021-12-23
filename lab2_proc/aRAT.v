module aRAT (
    input clk,
    input reset,

    input [1:0] update_aRAT,
    input [4:0] update_pos_aRAT1,
    input [4:0] update_pos_aRAT2,
    input [5:0] update_data_aRAT1,
    input [5:0] update_data_aRAT2
    
);

reg [5:0] ARAT [0:31];
integer i;


always @(posedge clk ) begin
    if (reset) begin
        for (i = 0; i<32 ;i++ ) begin  // this may be a bug
            ARAT[i] <= i;
        end
    end else begin
        if (update_aRAT == 2'b01) begin
            ARAT[update_pos_aRAT1] <= update_data_aRAT1;
        end else if (update_aRAT == 2'b10) begin
            ARAT[update_pos_aRAT1] <= update_data_aRAT1;
            ARAT[update_pos_aRAT2] <= update_data_aRAT2;
        end
    end

end

    
endmodule
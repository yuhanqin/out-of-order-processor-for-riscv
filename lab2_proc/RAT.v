module RAT (
    input clk,
    input reset,
    input stall_RAT,
    input flush_iq,

    //aRAT
    input [1:0] update_aRAT,
    input [4:0] update_pos_aRAT1,
    input [4:0] update_pos_aRAT2,
    input [5:0] update_data_aRAT1,
    input [5:0] update_data_aRAT2,

    // renaming for sr1
    //input renRATsr1,
    input [4:0] raddrRATsr11,
    output wire [5:0] rdataRATsr11,
    // renaming for sr2
    //input renRATsr2,
    input [4:0] raddrRATsr21,
    output wire [5:0] rdataRATsr21,
    // renaming for old dest
    //input renRATdest,
    input [4:0] raddrRATdest1,
    output wire [5:0] rdataRATdest1,
    // renaming for new dest
    input wenRATdest1,
    input [4:0] waddrRATdest1,
    input [5:0] wdataRATdest1,

    // renaming for sr1
    //input renRATsr1,
    input [4:0] raddrRATsr12,
    output wire [5:0] rdataRATsr12,
    // renaming for sr2
    //input renRATsr2,
    input [4:0] raddrRATsr22,
    output wire [5:0] rdataRATsr22,
    // renaming for old dest
    //input renRATdest,
    input [4:0] raddrRATdest2,
    output wire [5:0] rdataRATdest2,
    // renaming for new dest
    input wenRATdest2,
    input [4:0] waddrRATdest2,
    input [5:0] wdataRATdest2
);


reg [5:0] ARAT [0:31];
reg [5:0] SRAT [0:31];
integer i;

assign rdataRATsr11 = SRAT[raddrRATsr11];
assign rdataRATsr21 = SRAT[raddrRATsr21];
assign rdataRATdest1 = SRAT[raddrRATdest1];

assign rdataRATsr12 = SRAT[raddrRATsr12];
assign rdataRATsr22 = SRAT[raddrRATsr22];
assign rdataRATdest2 = SRAT[raddrRATdest2];

always @(posedge clk ) begin
    if (reset) begin
        for (i = 0; i<32 ;i++ ) begin  // this may be a bug
            SRAT[i] <= i;
            ARAT[i] <= i;
        end
    end else begin
        // aRAT
        if (update_aRAT == 2'b01) begin
            ARAT[update_pos_aRAT1] <= update_data_aRAT1;
        end else if (update_aRAT == 2'b10) begin
            ARAT[update_pos_aRAT1] <= update_data_aRAT1;
            ARAT[update_pos_aRAT2] <= update_data_aRAT2;
        end
        //sRAT
        if (!stall_RAT) begin
            if (wenRATdest1) begin
                SRAT[waddrRATdest1] <= wdataRATdest1;
            end
            if (wenRATdest2) begin
                SRAT[waddrRATdest2] <= wdataRATdest2;
            end
        end
        // flush iq
        if (flush_iq) begin
            for (i = 0; i < 32; i++) begin
                if (i == update_pos_aRAT1) begin
                    SRAT[update_pos_aRAT1] <= (update_aRAT==2'b01 | update_aRAT==2'b10)?update_data_aRAT1:ARAT[i];
                end else if (i == update_pos_aRAT2) begin
                    SRAT[update_pos_aRAT1] <= (update_aRAT==2'b10)?update_data_aRAT2:ARAT[i];
                end else begin
                    SRAT[i] <= ARAT[i];
                end
            end
        end
    end

end

    
endmodule
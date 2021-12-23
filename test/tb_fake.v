`timescale 1 ns/1 ps
module tb_fake();

reg clk;
reg reset;
wire [31:0] fakepc1, fakepc2;
wire [31:0] fakeinstr1, fakeinstr2;

reg [31:0] fakeinstr_buf[0:63];

/*always @(*) begin
    fakeinstr_buf[0][31:0] <= 32'b0000000_00002_00000_000_00001_0010011;  // r1=r0+2
    fakeinstr_buf[1][31:0] <= 32'b0000000_00003_00000_000_00002_0010011;  // r2=r0+3
    fakeinstr_buf[2][31:0] <= 32'b0000000_00002_00001_000_00003_0110011;  // r3=r1+r2
end*/

wire [31:0] fakepcaddr1, fakepcaddr2;
assign fakepcaddr1 = (fakepc1-32'h200)>>2;
assign fakepcaddr2 = (fakepc2-32'h200)>>2;
assign fakeinstr1 = fakeinstr_buf[fakepcaddr1];
assign fakeinstr2 = fakeinstr_buf[fakepcaddr2];

always #5 clk=~clk;

initial begin
	$dumpfile("../test/wave_fake.vcd");  // 指定VCD文件的名字为wave.vcd，仿真信息将记录到此文件
	$dumpvars(0, tb_fake );  // 指定层次数为0，则tb_code 模块及其下面各层次的所有信号将被记录
	#10000 $finish;
end
   

initial begin
    clk=1;
    reset=1;

    fakeinstr_buf[0] = 32'b0000000_00010_00000_000_00001_0010011;  // r1=r0+2=2
    fakeinstr_buf[1] = 32'b0000000_00011_00000_000_00010_0010011;  // r2=r0+3=3
    fakeinstr_buf[2] = 32'b0000000_00010_00001_000_00011_0110011;  // r3=r1+r2=5, raw
    fakeinstr_buf[3] = 32'b0100000_00010_00001_000_00100_0110011;  // r4=r1-r2=-1
    fakeinstr_buf[4] = 32'b0000000_00011_00001_111_00101_0110011;  // r5=r1&r3=0
    fakeinstr_buf[5] = 32'b0000000_00011_00001_110_00101_0110011;  // r5=r1|r3=7, waw
    fakeinstr_buf[6] = 32'b0000000_00001_00101_100_00101_0110011;  // r5=r5^r1=5
    fakeinstr_buf[7] = 32'b0000000_00100_00010_010_00101_0110011;  // r5=r2<r4=0
    fakeinstr_buf[8] = 32'b0000000_00011_00101_010_00101_0110011;  // r5=r5<r3=1
    fakeinstr_buf[9] = 32'b0000000_00100_00010_011_00101_0110011;  // r5=r2<r4(u)=1
    fakeinstr_buf[10] = 32'b0100000_00001_00100_101_00101_0110011;  // r5=r4>>>r1=-1
    fakeinstr_buf[11] = 32'b0100000_00001_00011_101_00101_0110011;  // r5=r3>>>r1=1
    fakeinstr_buf[12] = 32'b0000000_00011_00100_101_00101_0110011;  // r5=r4>>r3=0000011...
    fakeinstr_buf[13] = 32'b0000000_00100_00100_101_00101_0110011;  // r5=r4>>r4=1
    fakeinstr_buf[14] = 32'b0000000_00001_00010_001_00101_0110011;  // r5=r2<<r1=12
    fakeinstr_buf[15] = 32'b0000001_00101_00100_000_11111_0110011;  // r31=r4*r5=-12
    // jal
    //fakeinstr_buf[16] = 32'b1111111_11111_11000_000_11110_1101111;  // jmp to 1st instr ---240
    // jr
    //fakeinstr_buf[16] = 32'b1101111_10100_11111_100_11101_0010011;  // r29=r31^fdf4=200
    //fakeinstr_buf[17] = 32'b0000000_00000_11101_000_00000_1100111;  // jr r29=200
    // jalr
    //fakeinstr_buf[16] = 32'b1101111_10100_11111_100_11101_0010011;  // r29=r31^fdf4=200
    //fakeinstr_buf[17] = 32'b0000000_10001_11101_000_11110_1100111;  // jalr r29+0x11=210, r30=248
    // branch
    fakeinstr_buf[16] = 32'b0000000_00111_00011_001_11101_0010011;  // r29=r3<<7=5 * 2**7=280
    fakeinstr_buf[17] = 32'b0000000_00001_11101_101_11101_0010011;  // r29=r29>>1
    fakeinstr_buf[18] = 32'b0000000_00101_00001_110_00101_0010011;  // r5=r1|5=7
    // ---bne
    //fakeinstr_buf[19] = 32'b1111111_00011_11101_001_11000_1100011;  // pc-=8 (r3!=r29)
    // ---bge
    //fakeinstr_buf[19] = 32'b1111111_00011_11101_101_11000_1100011;  // pc-=8 (r29>=r3)
    // ---bgeu
    fakeinstr_buf[19] = 32'b1111111_11111_11101_111_11000_1100011;  // pc-=8 (r29>=r31)

    fakeinstr_buf[20] = 32'b0000000_00011_11111_010_00110_0010011;  // r6=r31<3=1


//fakeinstr_buf[2] = 32'b0000000_00002_00001_000_00003_0110011;  // r3=r1+r2


    #38 reset = 0;

end

ProcAltVRTL#(
    .p_num_cores         ( 1 )
) uut(
    .clk                   ( clk                   ),
    .reset                 ( reset                 ),
    .mngr2proc_msg         ( mngr2proc_msg         ),
    .mngr2proc_val         ( mngr2proc_val         ),
    .mngr2proc_rdy         ( mngr2proc_rdy         ),
    .proc2mngr_msg         ( proc2mngr_msg         ),
    .proc2mngr_val         ( proc2mngr_val         ),
    .proc2mngr_rdy         ( proc2mngr_rdy         ),
    .imemreq_msg           ( imemreq_msg           ),
    .imemreq_val           ( imemreq_val           ),
    .imemreq_rdy           ( imemreq_rdy           ),
    .imemresp_msg          ( imemresp_msg          ),
    .imemresp_val          ( imemresp_val          ),
    .imemresp_rdy          ( imemresp_rdy          ),
    .dmemreq_msg           ( dmemreq_msg           ),
    .dmemreq_val           ( dmemreq_val           ),
    .dmemreq_rdy           ( dmemreq_rdy           ),
    .dmemresp_msg          ( dmemresp_msg          ),
    .dmemresp_val          ( dmemresp_val          ),
    .dmemresp_rdy          ( dmemresp_rdy          ),
    .commit_inst           ( commit_inst           ),
    .fakepc1                ( fakepc1                ),
    .fakepc2                ( fakepc2                ),
    .fakeinstr1             ( fakeinstr1             ),
    .fakeinstr2             ( fakeinstr2             )
);

endmodule
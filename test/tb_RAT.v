`timescale 1 ns/1 ps
module tb_RAT();

reg clk;
reg reset;

reg [4:0] raddrRATsr1;
wire [5:0] rdataRATsr1;
reg [4:0] raddrRATsr2;
wire [5:0] rdataRATsr2;
reg [4:0] raddrRATdest;
wire [5:0] rdataRATdest;
reg wenRATdest;
reg [4:0] waddrRATdest;
reg [5:0] wdataRATdest;

reg [5:0] rdata_test;

always #5 clk=~clk;

always @(posedge clk ) begin
    rdata_test <= rdataRATdest;
end

initial begin
	$dumpfile("../test/wave_RAT.vcd");  // 指定VCD文件的名字为wave.vcd，仿真信息将记录到此文件
	$dumpvars(0, tb_RAT );  // 指定层次数为0，则tb_code 模块及其下面各层次的所有信号将被记录
	#100 $finish;
end

initial begin
clk = 0;
reset = 0;

#20 reset = 1;
#20 reset = 0;
#5;

// check the initial value
raddrRATsr1 = 5'b0;
raddrRATsr2 = 5'b10000;
raddrRATdest = 5'b11111;
#10;
// test simutaneously r&w
#1;
raddrRATdest = 5'b10000;
wenRATdest = 1;
waddrRATdest = 5'b10000;
wdataRATdest = 5'b10101;
#9;
// check the result
#10;
// check again

end


RAT RAT (
    .clk(clk),
    .reset(reset),

    // renaming for sr1
    //input renRATsr1,
    .raddrRATsr1(raddrRATsr1),
    .rdataRATsr1(rdataRATsr1),
    // renaming for sr2
    //input renRATsr2,
    .raddrRATsr2(raddrRATsr2),
    .rdataRATsr2(rdataRATsr2),
    // renaming for old dest
    //input renRATdest,
    .raddrRATdest(raddrRATdest),
    .rdataRATdest(rdataRATdest),
    // renaming for new dest
    .wenRATdest(wenRATdest),
    .waddrRATdest(waddrRATdest),
    .wdataRATdest(wdataRATdest)
);


endmodule
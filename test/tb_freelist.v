`timescale 1 ns/1 ps
module tb_freelist();

reg clk;
reg reset;

wire no_free_pr;
wire one_free_pr;
reg [1:0] pop_fl_RAT;
wire [5:0] pop_data_fl_RAT1;
wire [5:0] pop_data_fl_RAT2;
reg [1:0] push_fl_RAT;
reg [5:0] push_data_fl_RAT1;
reg [5:0] push_data_fl_RAT2;

integer i;
reg [5:0] pop_reg1;
reg [5:0] pop_reg2;

always #5 clk=~clk;

always @(posedge clk ) begin
    pop_reg1 <= pop_data_fl_RAT1;
    pop_reg2 <= pop_data_fl_RAT2;
end

initial begin
	$dumpfile("../test/wave_freelist.vcd");  // 指定VCD文件的名字为wave.vcd，仿真信息将记录到此文件
	$dumpvars(0, tb_freelist );  // 指定层次数为0，则tb_code 模块及其下面各层次的所有信号将被记录
	#400 $finish;
end

initial begin
clk = 0;
reset = 0;
pop_fl_RAT = 2'b0;
push_fl_RAT = 2'b0;

#20 reset = 1;
#20 reset = 0;
#5;

for (i = 0;i < 15;i++ ) begin
    #1
    pop_fl_RAT = 2'b10;
    #9;
end

#1
pop_fl_RAT = 2'b01;  // one_free_pr
#9;

#1
pop_fl_RAT = 2'b0;
push_fl_RAT = 2'b01;
push_data_fl_RAT1 = 6'd1;
push_data_fl_RAT2 = 6'd3;  // no warning
#9;

#1;
push_fl_RAT = 2'b0;
pop_fl_RAT = 2'b10;  // no_free_pr
#9;

#1
pop_fl_RAT = 2'b00;
push_fl_RAT = 2'b01;
push_data_fl_RAT1 = 6'd5;
push_data_fl_RAT2 = 6'd7;  // one_free_pr
#9;

#1
pop_fl_RAT = 2'b01;
push_fl_RAT = 2'b01;
push_data_fl_RAT1 = 6'd9;
push_data_fl_RAT2 = 6'd11;  // one_free_pr
#9;

pop_fl_RAT = 2'b0;
push_fl_RAT = 2'b0;
end


freelist_RAT fl_RAT (
    .clk(clk),
    .reset(reset),

    .no_free_pr(no_free_pr),
    .one_free_pr(one_free_pr),

    .pop_fl_RAT(pop_fl_RAT),
    .pop_data_fl_RAT1(pop_data_fl_RAT1),
    .pop_data_fl_RAT2(pop_data_fl_RAT2),

    .push_fl_RAT(push_fl_RAT),
    .push_data_fl_RAT1(push_data_fl_RAT1),
    .push_data_fl_RAT2(push_data_fl_RAT2)
);


endmodule
//=========================================================================
// 5-Stage Simple Pipelined Processor
//=========================================================================

`ifndef LAB2_PROC_PIPELINED_PROC_BASE_V
`define LAB2_PROC_PIPELINED_PROC_BASE_V

`include "../vc/mem-msgs.v"

//module lab2_proc_ProcAltVRTL
module ProcAltVRTL
#(
  parameter p_num_cores = 1
)
(
  input  logic         clk,
  input  logic         reset,

  // From mngr streaming port

  input  logic [31:0]  mngr2proc_msg,
  input  logic         mngr2proc_val,
  output logic         mngr2proc_rdy,

  // To mngr streaming port

  output logic [31:0]  proc2mngr_msg,
  output logic         proc2mngr_val,
  input  logic         proc2mngr_rdy,

  // Instruction Memory Request Port

  output mem_req_4B_t  imemreq_msg,
  output logic         imemreq_val,
  input  logic         imemreq_rdy,

  // Instruction Memory Response Port

  input  mem_resp_4B_t imemresp_msg,
  input  logic         imemresp_val,
  output logic         imemresp_rdy,

  // Data Memory Request Port

  output mem_req_4B_t  dmemreq_msg,
  output logic         dmemreq_val,
  input  logic         dmemreq_rdy,

  // Data Memory Response Port

  input  mem_resp_4B_t dmemresp_msg,
  input  logic         dmemresp_val,
  output logic         dmemresp_rdy,

  // stats output

  output logic         commit_inst,

  // fake test only
  output wire [31:0] fakepc1,
  output wire [31:0] fakepc2,
  input wire [31:0] fakeinstr1,
  input wire [31:0] fakeinstr2

);



// for if stage
wire [31:0] cur_pc;
wire [31:0] instr1_if, instr2_if;
wire [31:0] pc1_if, pc2_if;
wire ins_valid1_if, ins_valid2_if;
// fake test only
assign fakepc1 = cur_pc;
assign fakepc2 = cur_pc+32'd4;


// for id stage
wire [31:0] instr1_id, instr2_id;
wire [31:0] pc1_id, pc2_id;
wire ins_valid1_id, ins_valid2_id;
wire [6:0] opcode1_id, opcode2_id;
wire [4:0]     rd1_id, rd2_id;
wire [4:0]    rs11_id, rs12_id;
wire [4:0]    rs21_id, rs22_id;
wire [2:0] funct31_id, funct32_id;
wire [6:0] funct71_id, funct72_id;
wire [11:0]    csr1_id, csr2_id;

// for reg renaming stage
wire pc_recover_stall_renaming;
wire ins_valid1_renaming, ins_valid2_renaming;
wire [31:0] pc1_renaming, pc2_renaming;
wire [6:0] opcode1_renaming, opcode2_renaming;
wire [4:0]     rd1_renaming, rd2_renaming;
wire [4:0]    rs11_renaming, rs12_renaming;
wire [4:0]    rs21_renaming, rs22_renaming;
wire [2:0] funct31_renaming, funct32_renaming;
wire [6:0] funct71_renaming, funct72_renaming;
wire [11:0]    csr1_renaming, csr2_renaming;
wire ins_renamed_valid1_renaming, ins_renamed_valid2_renaming;
wire rd_valid1_renaming, rd_valid2_renaming;
wire [5:0] prd1_renaming, prd2_renaming;
wire [5:0] oprd1_renaming, oprd2_renaming;
wire [5:0] prs11_renaming, prs12_renaming;
wire [5:0] prs21_renaming, prs22_renaming;
// RAT
wire [4:0] raddrRATsr11_renaming, raddrRATsr12_renaming;
wire [5:0] rdataRATsr11_renaming, rdataRATsr12_renaming;
wire [4:0] raddrRATsr21_renaming, raddrRATsr22_renaming;
wire [5:0] rdataRATsr21_renaming, rdataRATsr22_renaming;
wire [4:0] raddrRATdest1_renaming, raddrRATdest2_renaming;
wire [5:0] rdataRATdest1_renaming, rdataRATdest2_renaming;
wire wenRATdest1_renaming, wenRATdest2_renaming;
wire [4:0] waddrRATdest1_renaming, waddrRATdest2_renaming;
wire [5:0] wdataRATdest1_renaming, wdataRATdest2_renaming;
// freelist
wire no_free_pr_renaming, one_free_pr_renaming;
wire [1:0] pop_fl_RAT_renaming;
wire [5:0] pop_data_fl_RAT1_renaming;
wire [5:0] pop_data_fl_RAT2_renaming;
// stall
wire stall_renaming;

// for dispatch stage
wire ins_valid1_dispatch, ins_valid2_dispatch;
wire rd_valid1_dispatch, rd_valid2_dispatch;
wire [1:0] ins1_type_dispatch, ins2_type_dispatch;
wire [31:0] pc1_dispatch, pc2_dispatch;
wire [6:0] opcode1_dispatch, opcode2_dispatch;
wire [4:0] rd1_dispatch, rd2_dispatch;
wire [4:0] rs11_dispatch, rs12_dispatch;
wire [4:0] rs21_dispatch, rs22_dispatch;
wire [5:0]     prd1_dispatch, prd2_dispatch;
wire [5:0]     oprd1_dispatch, oprd2_dispatch;
wire [5:0]    prs11_dispatch, prs12_dispatch;
wire [5:0]    prs21_dispatch, prs22_dispatch;
wire [2:0] funct31_dispatch, funct32_dispatch;
wire [6:0] funct71_dispatch, funct72_dispatch;
wire [11:0]    csr1_dispatch, csr2_dispatch;
// alu iq
wire no_free_iq_alu_dispatch, one_free_iq_alu_dispatch;
wire ins_valid1_alu_dispatch, ins_valid2_alu_dispatch;
wire prs1_valid1_alu_dispatch, prs1_valid2_alu_dispatch;
wire prs2_valid1_alu_dispatch, prs2_valid2_alu_dispatch;
wire isauipc1_alu_dispatch, isauipc2_alu_dispatch;
// lsq iq
wire no_free_iq_lsq_dispatch, one_free_iq_lsq_dispatch;
wire ins_valid1_lsq_dispatch, ins_valid2_lsq_dispatch;
wire prd_valid1_lsq_dispatch, prd_valid2_lsq_dispatch;
wire prs2_valid1_lsq_dispatch, prs2_valid2_lsq_dispatch;
// jmp iq
wire no_free_iq_jmp_dispatch, one_free_iq_jmp_dispatch;
wire ins_valid1_jmp_dispatch, ins_valid2_jmp_dispatch;
wire prs1_valid1_jmp_dispatch, prs1_valid2_jmp_dispatch;
wire prs2_valid1_jmp_dispatch, prs2_valid2_jmp_dispatch;
//wire rd_valid1_jmp_dispatch, rd_valid2_jmp_dispatch;
// ROB
wire no_free_rob_dispatch, one_free_rob_dispatch;
wire [1:0] ins_valid_rob_dispatch;
wire [1:0] ins1_type_rob_dispatch, ins2_type_rob_dispatch;
wire [5:0] pos1_rob_dispatch, pos2_rob_dispatch;
//stall
wire stall_dispatch;


// for issue stage
//alu
wire req_issue_alu;
wire [5:0] pos_issue_alu;
wire [5:0] prd_issue_alu;
wire [5:0] prs1_issue_alu, prs2_issue_alu;
wire prs1_valid_issue_alu, prs2_valid_issue_alu;
wire [2:0] funct3_issue_alu;
wire [6:0] funct7_issue_alu;
wire isauipc_issue_alu;
wire [4:0] rs1_issue_alu, rs2_issue_alu;
wire [31:0] pc_issue_alu;
wire alubypass1_issue_alu, alubypass2_issue_alu;
wire jmpbypass1_issue_alu, jmpbypass2_issue_alu;

//jmp
wire req_issue_jmp;
wire [5:0] pos_issue_jmp;
wire [5:0] prd_issue_jmp;
wire [5:0] prs1_issue_jmp, prs2_issue_jmp;
wire prs1_valid_issue_jmp, prs2_valid_issue_jmp;
wire [2:0] funct3_issue_jmp;
wire [6:0] funct7_issue_jmp;
wire [4:0] rs1_issue_jmp, rs2_issue_jmp, rd_issue_jmp;
wire [31:0] pc_issue_jmp;
wire alubypass1_issue_jmp, alubypass2_issue_jmp;
wire jmpbypass1_issue_jmp, jmpbypass2_issue_jmp;


// for rfread stage
//alu
wire [5:0] prs1_rfread_alu, prs2_rfread_alu;
//jmp
wire [5:0] prs1_rfread_jmp, prs2_rfread_jmp;


// for ex stage
//alu
wire req_ex_alu;
wire [5:0] pos_ex_alu;
wire [5:0] prd_ex_alu;
wire [2:0] funct3_ex_alu;
wire [2:0] src1_mux_ex_alu, src2_mux_ex_alu;
wire [19:0] imm_ex_alu;
wire [31:0] pc_ex_alu;
wire [1:0] op_mux_ex_alu;
wire [31:0] datars1_ex_alu, datars2_ex_alu;
wire [31:0] result_ex_alu;
//jmp
wire req_ex_jmp;
wire [5:0] pos_ex_jmp;
wire [5:0] prd_ex_jmp;
wire [2:0] funct3_ex_jmp;
wire [1:0] src1_mux_ex_jmp, src2_mux_ex_jmp;
wire [19:0] imm_ex_jmp;
wire [31:0] pc_ex_jmp;
wire [1:0] op_mux_ex_jmp;
wire [31:0] datars1_ex_jmp, datars2_ex_jmp;
wire rd_valid_ex_jmp, pc_recover_jmp;
wire [31:0] result_ex_jmp, new_pc_jmp;

// for mem stage


// for wb stage
wire req_alu_wb, req_jmp_wb;
wire [5:0] pos_alu_wb, pos_jmp_wb;
wire [31:0] result_alu_wb, result_jmp_wb;
wire [5:0] prd_alu_wb, prd_jmp_wb;
wire rd_valid_jmp_wb, pc_recover_jmp_wb;
//wire [31:0] new_pc_jmp_wb;


// for commit stage
wire [1:0] push_fl_RAT_commit;
wire [5:0] push_data_fl_RAT1_commit, push_data_fl_RAT2_commit;
wire [4:0] update_pos_aRAT1_commit, update_pos_aRAT2_commit;
wire [5:0] update_data_aRAT1_commit, update_data_aRAT2_commit;
wire flush_iq_commit;

// key components
PRF PRF(
  .clk(clk),
  .reset(reset),
  .stall(stall_renaming | stall_dispatch | pc_recover_stall_renaming),

  .prs1_rfread_alu(prs1_rfread_alu),
  .prs2_rfread_alu(prs2_rfread_alu),
  .datars1_ex_alu(datars1_ex_alu),
  .datars2_ex_alu(datars2_ex_alu),
  .prs1_rfread_jmp(prs1_rfread_jmp),
  .prs2_rfread_jmp(prs2_rfread_jmp),
  .datars1_ex_jmp(datars1_ex_jmp),
  .datars2_ex_jmp(datars2_ex_jmp),

  .req_alu_wb(req_alu_wb),
  .result_alu_wb(result_alu_wb),
  .prd_alu_wb(prd_alu_wb),
  .req_jmp_wb(req_jmp_wb),
  .rd_valid_jmp_wb(rd_valid_jmp_wb),
  .result_jmp_wb(result_jmp_wb),
  .prd_jmp_wb(prd_jmp_wb),

  .pc_recover_jmp(pc_recover_jmp),
  .new_pc_jmp(new_pc_jmp),

  .cur_pc(cur_pc)

);

/*
aRAT aRAT (
  .clk(clk),
  .reset(reset),

  .update_aRAT(push_fl_RAT_commit),
  .update_pos_aRAT1(update_pos_aRAT1_commit),
  .update_pos_aRAT2(update_pos_aRAT2_commit),
  .update_data_aRAT1(update_data_aRAT1_commit),
  .update_data_aRAT2(update_data_aRAT2_commit)
    
);*/

RAT RAT(
  .clk(clk),
  .reset(reset),
  .stall_RAT(stall_dispatch),  // TODO 
  .flush_iq(flush_iq_commit),
  // aRAT
  .update_aRAT(push_fl_RAT_commit),
  .update_pos_aRAT1(update_pos_aRAT1_commit),
  .update_pos_aRAT2(update_pos_aRAT2_commit),
  .update_data_aRAT1(update_data_aRAT1_commit),
  .update_data_aRAT2(update_data_aRAT2_commit),
  // sRAT
  .raddrRATsr11(raddrRATsr11_renaming),
  .rdataRATsr11(rdataRATsr11_renaming),
  .raddrRATsr21(raddrRATsr21_renaming),
  .rdataRATsr21(rdataRATsr21_renaming),
  .raddrRATdest1(raddrRATdest1_renaming),
  .rdataRATdest1(rdataRATdest1_renaming),
  .wenRATdest1(wenRATdest1_renaming),
  .waddrRATdest1(waddrRATdest1_renaming),
  .wdataRATdest1(wdataRATdest1_renaming),
  .raddrRATsr12(raddrRATsr12_renaming),
  .rdataRATsr12(rdataRATsr12_renaming),
  .raddrRATsr22(raddrRATsr22_renaming),
  .rdataRATsr22(rdataRATsr22_renaming),
  .raddrRATdest2(raddrRATdest2_renaming),
  .rdataRATdest2(rdataRATdest2_renaming),
  .wenRATdest2(wenRATdest2_renaming),
  .waddrRATdest2(waddrRATdest2_renaming),
  .wdataRATdest2(wdataRATdest2_renaming)
);

freelist_RAT freelist_RAT(
  .clk(clk),
  .reset(reset),
  .stall_freelist_RAT(stall_dispatch),  // TODO
  .flush_iq(flush_iq_commit),
  .no_free_pr(no_free_pr_renaming),
  .one_free_pr(one_free_pr_renaming),
  .pop_fl_RAT(pop_fl_RAT_renaming),
  .pop_data_fl_RAT1(pop_data_fl_RAT1_renaming),
  .pop_data_fl_RAT2(pop_data_fl_RAT2_renaming),
  .push_fl_RAT(push_fl_RAT_commit),  // remember to set to 0 after using
  .push_data_fl_RAT1(push_data_fl_RAT1_commit),
  .push_data_fl_RAT2(push_data_fl_RAT2_commit)
);

ROB ROB (
  .clk(clk),
  .reset(reset),
  .no_free_rob(no_free_rob_dispatch),
  .one_free_rob(one_free_rob_dispatch),
  .ins_valid_rob(ins_valid_rob_dispatch),
  .rd_valid1_rob(rd_valid1_dispatch),
  .type1_rob(ins1_type_dispatch),
  .rd1_rob(rd1_dispatch),
  .prd1_rob(prd1_dispatch),
  .oprd1_rob(oprd1_dispatch),
  .pc1_rob(pc1_dispatch),
  .rd_valid2_rob(rd_valid2_dispatch),
  .type2_rob(ins2_type_dispatch),
  .rd2_rob(rd2_dispatch),
  .prd2_rob(prd2_dispatch),
  .oprd2_rob(oprd2_dispatch),
  .pc2_rob(pc2_dispatch),
  .pos1_rob(pos1_rob_dispatch),
  .pos2_rob(pos2_rob_dispatch),
  .req_alu_wb(req_alu_wb),
  .pos_alu_wb(pos_alu_wb),
  .req_jmp_wb(req_jmp_wb),
  .pc_recover_jmp_wb(pc_recover_jmp_wb),
  .pos_jmp_wb(pos_jmp_wb),
  .flush_iq(flush_iq_commit),
  .push_fl_RAT(push_fl_RAT_commit),
  .push_data_fl_RAT1(push_data_fl_RAT1_commit),
  .push_data_fl_RAT2(push_data_fl_RAT2_commit),
  .update_pos_aRAT1(update_pos_aRAT1_commit),
  .update_pos_aRAT2(update_pos_aRAT2_commit),
  .update_data_aRAT1(update_data_aRAT1_commit),
  .update_data_aRAT2(update_data_aRAT2_commit)

);


// pipeline
stage_if stage_if(
  .clk(clk),
  .reset(reset),
  .stall_if(pc_recover_stall_renaming),
  .flush_if(pc_recover_jmp),

  .fakeinstr1(fakeinstr1),
  .fakeinstr2(fakeinstr2),
  .fakepc1(fakepc1),
  .fakepc2(fakepc2),

  .instr1(instr1_if),
  .pc1(pc1_if),
  .ins_valid1(ins_valid1_if),
  .instr2(instr2_if),
  .pc2(pc2_if),
  .ins_valid2(ins_valid2_if)
);

latch_if_id latch_if_id(
  .clk(clk),
  .reset(reset),
  .stall_if_id(stall_renaming | stall_dispatch | pc_recover_stall_renaming),
  .flush_if_id(pc_recover_jmp),

  .instr1_if(instr1_if),
  .pc1_if(pc1_if),
  .ins_valid1_if(ins_valid1_if),
  .instr2_if(instr2_if),
  .pc2_if(pc2_if),
  .ins_valid2_if(ins_valid2_if),

  .instr1_id(instr1_id),
  .pc1_id(pc1_id),
  .ins_valid1_id(ins_valid1_id),
  .instr2_id(instr2_id),
  .pc2_id(pc2_id),
  .ins_valid2_id(ins_valid2_id)
);

rv2isa_InstUnpack stage_id1(
  .inst(instr1_id),
  .opcode(opcode1_id),
  .rd(rd1_id),
  .rs1(rs11_id),
  .rs2(rs21_id),
  .funct3(funct31_id),
  .funct7(funct71_id),
  .csr(csr1_id)
);
rv2isa_InstUnpack stage_id2(
  .inst(instr2_id),
  .opcode(opcode2_id),
  .rd(rd2_id),
  .rs1(rs12_id),
  .rs2(rs22_id),
  .funct3(funct32_id),
  .funct7(funct72_id),
  .csr(csr2_id)
);

latch_id_renaming latch_id_renaming(
  .clk(clk),
  .reset(reset),
  .stall_id_renaming(stall_renaming | stall_dispatch | pc_recover_stall_renaming),
  .flush_id_renaming(pc_recover_jmp),

  //.pc_recover(pc_recover_jmp),
  .flush_iq(flush_iq_commit),
  .ins_valid1_if(ins_valid1_if),
  .pc_recover_stall(pc_recover_stall_renaming),

  .pc1_id(pc1_id),
  .opcode1_id(opcode1_id),
  .rd1_id(rd1_id),
  .rs11_id(rs11_id),
  .rs21_id(rs21_id),
  .funct31_id(funct31_id),
  .funct71_id(funct71_id),
  .csr1_id(csr1_id),
  .ins_valid1_id(ins_valid1_id),
  .pc2_id(pc2_id),
  .opcode2_id(opcode2_id),
  .rd2_id(rd2_id),
  .rs12_id(rs12_id),
  .rs22_id(rs22_id),
  .funct32_id(funct32_id),
  .funct72_id(funct72_id),
  .csr2_id(csr2_id),
  .ins_valid2_id(ins_valid2_id),

  .pc1_renaming(pc1_renaming),
  .opcode1_renaming(opcode1_renaming),
  .rd1_renaming(rd1_renaming),
  .rs11_renaming(rs11_renaming),
  .rs21_renaming(rs21_renaming),
  .funct31_renaming(funct31_renaming),
  .funct71_renaming(funct71_renaming),
  .csr1_renaming(csr1_renaming),
  .ins_valid1_renaming(ins_valid1_renaming),
  .pc2_renaming(pc2_renaming),
  .opcode2_renaming(opcode2_renaming),
  .rd2_renaming(rd2_renaming),
  .rs12_renaming(rs12_renaming),
  .rs22_renaming(rs22_renaming),
  .funct32_renaming(funct32_renaming),
  .funct72_renaming(funct72_renaming),
  .csr2_renaming(csr2_renaming),
  .ins_valid2_renaming(ins_valid2_renaming)
);

stage_renaming stage_renaming(
  .clk(clk),
  .reset(reset),
  .ins_valid1(ins_valid1_renaming),
  .opcode1(opcode1_renaming),
  .rd1(rd1_renaming),
  .rs11(rs11_renaming),
  .rs21(rs21_renaming),
  .ins_valid2(ins_valid2_renaming),
  .opcode2(opcode2_renaming),
  .rd2(rd2_renaming),
  .rs12(rs12_renaming),
  .rs22(rs22_renaming),
  .ins_renamed_valid1(ins_renamed_valid1_renaming),
  .rd_valid1(rd_valid1_renaming),
  .prd1(prd1_renaming),
  .oprd1(oprd1_renaming),
  .prs11(prs11_renaming),
  .prs21(prs21_renaming),
  .ins_renamed_valid2(ins_renamed_valid2_renaming),
  .rd_valid2(rd_valid2_renaming),
  .prd2(prd2_renaming),
  .oprd2(oprd2_renaming),
  .prs12(prs12_renaming),
  .prs22(prs22_renaming),
  .raddrRATsr11(raddrRATsr11_renaming),
  .rdataRATsr11(rdataRATsr11_renaming),
  .raddrRATsr21(raddrRATsr21_renaming),
  .rdataRATsr21(rdataRATsr21_renaming),
  .raddrRATdest1(raddrRATdest1_renaming),
  .rdataRATdest1(rdataRATdest1_renaming),
  .wenRATdest1(wenRATdest1_renaming),
  .waddrRATdest1(waddrRATdest1_renaming),
  .wdataRATdest1(wdataRATdest1_renaming),
  .raddrRATsr12(raddrRATsr12_renaming),
  .rdataRATsr12(rdataRATsr12_renaming),
  .raddrRATsr22(raddrRATsr22_renaming),
  .rdataRATsr22(rdataRATsr22_renaming),
  .raddrRATdest2(raddrRATdest2_renaming),
  .rdataRATdest2(rdataRATdest2_renaming),
  .wenRATdest2(wenRATdest2_renaming),
  .waddrRATdest2(waddrRATdest2_renaming),
  .wdataRATdest2(wdataRATdest2_renaming),
  .no_free_pr(no_free_pr_renaming),
  .one_free_pr(one_free_pr_renaming),
  .pop_fl_RAT(pop_fl_RAT_renaming),
  .pop_data_fl_RAT1(pop_data_fl_RAT1_renaming),
  .pop_data_fl_RAT2(pop_data_fl_RAT2_renaming),
  .stall_renaming(stall_renaming)
);

latch_renaming_dispatch latch_renaming_dispatch(
  .clk(clk),
  .reset(reset),
  .stall_renaming_dispatch(stall_dispatch),  // TODO
  .flush_renaming_dispatch(pc_recover_jmp),

  .pc1_renaming(pc1_renaming),
  .opcode1_renaming(opcode1_renaming),
  .rd1_renaming(rd1_renaming),
  .rs11_renaming(rs11_renaming),
  .rs21_renaming(rs21_renaming),
  .prd1_renaming(prd1_renaming),
  .oprd1_renaming(oprd1_renaming),
  .prs11_renaming(prs11_renaming),
  .prs21_renaming(prs21_renaming),
  .funct31_renaming(funct31_renaming),
  .funct71_renaming(funct71_renaming),
  .csr1_renaming(csr1_renaming),
  .ins_renamed_valid1_renaming(ins_renamed_valid1_renaming),
  .rd_valid1_renaming(rd_valid1_renaming),
  .pc2_renaming(pc2_renaming),
  .opcode2_renaming(opcode2_renaming),
  .rd2_renaming(rd2_renaming),
  .rs12_renaming(rs12_renaming),
  .rs22_renaming(rs22_renaming),
  .prd2_renaming(prd2_renaming),
  .oprd2_renaming(oprd2_renaming),
  .prs12_renaming(prs12_renaming),
  .prs22_renaming(prs22_renaming),
  .funct32_renaming(funct32_renaming),
  .funct72_renaming(funct72_renaming),
  .csr2_renaming(csr2_renaming),
  .ins_renamed_valid2_renaming(ins_renamed_valid2_renaming),
  .rd_valid2_renaming(rd_valid2_renaming),

  .pc1_dispatch(pc1_dispatch),
  .opcode1_dispatch(opcode1_dispatch),
  .rd1_dispatch(rd1_dispatch),
  .rs11_dispatch(rs11_dispatch),
  .rs21_dispatch(rs21_dispatch),
  .prd1_dispatch(prd1_dispatch),
  .oprd1_dispatch(oprd1_dispatch),
  .prs11_dispatch(prs11_dispatch),
  .prs21_dispatch(prs21_dispatch),
  .funct31_dispatch(funct31_dispatch),
  .funct71_dispatch(funct71_dispatch),
  .csr1_dispatch(csr1_dispatch),
  .ins_valid1_dispatch(ins_valid1_dispatch),
  .rd_valid1_dispatch(rd_valid1_dispatch),
  .pc2_dispatch(pc2_dispatch),
  .opcode2_dispatch(opcode2_dispatch),
  .rd2_dispatch(rd2_dispatch),
  .rs12_dispatch(rs12_dispatch),
  .rs22_dispatch(rs22_dispatch),
  .prd2_dispatch(prd2_dispatch),
  .oprd2_dispatch(oprd2_dispatch),
  .prs12_dispatch(prs12_dispatch),
  .prs22_dispatch(prs22_dispatch),
  .funct32_dispatch(funct32_dispatch),
  .funct72_dispatch(funct72_dispatch),
  .csr2_dispatch(csr2_dispatch),
  .ins_valid2_dispatch(ins_valid2_dispatch),
  .rd_valid2_dispatch(rd_valid2_dispatch)
);

stage_dispatch stage_dispatch (
  .clk(clk),
  .reset(reset),
  .opcode1(opcode1_dispatch),
  .funct31(funct31_dispatch),
  .ins_valid1(ins_valid1_dispatch),
  .opcode2(opcode2_dispatch),
  .funct32(funct32_dispatch),
  .ins_valid2(ins_valid2_dispatch),
  .no_free_iq_alu(no_free_iq_alu_dispatch),
  .one_free_iq_alu(one_free_iq_alu_dispatch),
  .ins_valid1_alu(ins_valid1_alu_dispatch),
  .prs1_valid1_alu(prs1_valid1_alu_dispatch),
  .prs2_valid1_alu(prs2_valid1_alu_dispatch),
  .isauipc1_alu(isauipc1_alu_dispatch),
  .ins_valid2_alu(ins_valid2_alu_dispatch),
  .prs1_valid2_alu(prs1_valid2_alu_dispatch),
  .prs2_valid2_alu(prs2_valid2_alu_dispatch),
  .isauipc2_alu(isauipc2_alu_dispatch),
  .no_free_iq_lsq(no_free_iq_lsq_dispatch),
  .one_free_iq_lsq(one_free_iq_lsq_dispatch),
  .ins_valid1_lsq(ins_valid1_lsq_dispatch),
  .prd_valid1_lsq(prd_valid1_lsq_dispatch),
  .prs2_valid1_lsq(prs2_valid1_lsq_dispatch),
  .ins_valid2_lsq(ins_valid2_lsq_dispatch),
  .prd_valid2_lsq(prd_valid2_lsq_dispatch),
  .prs2_valid2_lsq(prs2_valid2_lsq_dispatch),
  .no_free_iq_jmp(no_free_iq_jmp_dispatch),
  .one_free_iq_jmp(one_free_iq_jmp_dispatch),
  .ins_valid1_jmp(ins_valid1_jmp_dispatch),
  .prs1_valid1_jmp(prs1_valid1_jmp_dispatch),//
  .prs2_valid1_jmp(prs2_valid1_jmp_dispatch),//
  .ins_valid2_jmp(ins_valid2_jmp_dispatch),
  .prs1_valid2_jmp(prs1_valid2_jmp_dispatch),//
  .prs2_valid2_jmp(prs2_valid2_jmp_dispatch),//
  .no_free_rob(no_free_rob_dispatch),
  .one_free_rob(one_free_rob_dispatch),
  .ins_valid_rob(ins_valid_rob_dispatch),
  .ins1_type_rob(ins1_type_rob_dispatch),
  .ins2_type_rob(ins2_type_rob_dispatch),
  .stall_dispatch(stall_dispatch)
);

iq_alu iq_alu(
  .clk(clk),
  .reset(reset),
  .flush_iq(flush_iq_commit),
  .no_free_iq_alu(no_free_iq_alu_dispatch),
  .one_free_iq_alu(one_free_iq_alu_dispatch),
  .ins_valid1_alu(ins_valid1_alu_dispatch),
  .pos1_alu(pos1_rob_dispatch),
  .prd1_alu(prd1_dispatch),
  .prs11_alu(prs11_dispatch),
  .prs1_valid1_alu(prs1_valid1_alu_dispatch),
  .prs21_alu(prs21_dispatch),
  .prs2_valid1_alu(prs2_valid1_alu_dispatch),
  .funct31_alu(funct31_dispatch),
  .funct71_alu(funct71_dispatch),
  .isauipc1_alu(isauipc1_alu_dispatch),
  .rs11_alu(rs11_dispatch),
  .rs21_alu(rs21_dispatch),
  .pc1_alu(pc1_dispatch),
  .ins_valid2_alu(ins_valid2_alu_dispatch),
  .pos2_alu(pos2_rob_dispatch),
  .prd2_alu(prd2_dispatch),
  .prs12_alu(prs12_dispatch),
  .prs1_valid2_alu(prs1_valid2_alu_dispatch),
  .prs22_alu(prs22_dispatch),
  .prs2_valid2_alu(prs2_valid2_alu_dispatch),
  .funct32_alu(funct32_dispatch),
  .funct72_alu(funct72_dispatch),
  .isauipc2_alu(isauipc2_alu_dispatch),
  .rs12_alu(rs12_dispatch),
  .rs22_alu(rs22_dispatch),
  .pc2_alu(pc2_dispatch),
  // for RdyTable
  .prd1_lsq(),
  .ins_valid1_lsq(),
  .prd2_lsq(),
  .ins_valid2_lsq(),
  .prd1_jmp(prd1_dispatch),
  .rd_valid1_jmp(rd_valid1_dispatch),
  .ins_valid1_jmp(ins_valid1_jmp_dispatch),
  .prd2_jmp(prd2_dispatch),
  .rd_valid2_jmp(rd_valid2_dispatch),
  .ins_valid2_jmp(ins_valid2_jmp_dispatch),
  .req_issue_jmp(req_issue_jmp),
  .prd_issue_jmp(prd_issue_jmp),
  // Issue
  .req_issue(req_issue_alu),
  .pos_issue(pos_issue_alu),
  .prd_issue(prd_issue_alu),
  .prs1_issue(prs1_issue_alu),
  .prs1_valid_issue(prs1_valid_issue_alu),
  .prs2_issue(prs2_issue_alu),
  .prs2_valid_issue(prs2_valid_issue_alu),
  .funct3_issue(funct3_issue_alu),
  .funct7_issue(funct7_issue_alu),
  .isauipc_issue(isauipc_issue_alu),
  .rs1_issue(rs1_issue_alu),
  .rs2_issue(rs2_issue_alu),
  .pc_issue(pc_issue_alu),
  .alubypass1_issue(alubypass1_issue_alu),
  .alubypass2_issue(alubypass2_issue_alu),
  .jmpbypass1_issue(jmpbypass1_issue_alu),
  .jmpbypass2_issue(jmpbypass2_issue_alu)
);

stage_rfread_alu stage_rfread_alu(
  .clk(clk),
  .reset(reset),
  .flush_iq(flush_iq_commit),

  .req_issue(req_issue_alu),
  .pos_issue(pos_issue_alu),
  .prd_issue(prd_issue_alu),
  .prs1_issue(prs1_issue_alu),
  .prs1_valid_issue(prs1_valid_issue_alu),
  .prs2_issue(prs2_issue_alu),
  .prs2_valid_issue(prs2_valid_issue_alu),
  .funct3_issue(funct3_issue_alu),
  .funct7_issue(funct7_issue_alu),
  .isauipc_issue(isauipc_issue_alu),
  .rs1_issue(rs1_issue_alu),
  .rs2_issue(rs2_issue_alu),
  .pc_issue(pc_issue_alu),
  .alubypass1_issue(alubypass1_issue_alu),
  .alubypass2_issue(alubypass2_issue_alu),
  .jmpbypass1_issue(jmpbypass1_issue_alu),
  .jmpbypass2_issue(jmpbypass2_issue_alu),

  .req_ex(req_ex_alu),
  .pos_ex(pos_ex_alu),
  .prd_ex(prd_ex_alu),
  .funct3_ex(funct3_ex_alu),
  .src1_mux(src1_mux_ex_alu),
  .src2_mux(src2_mux_ex_alu),
  .imm(imm_ex_alu),
  .pc_ex(pc_ex_alu),
  .op_mux(op_mux_ex_alu),

  .prs1_rfread(prs1_rfread_alu),
  .prs2_rfread(prs2_rfread_alu)
);

stage_ex_alu stage_ex_alu(
  .clk(clk),
  .reset(reset),
    
  .req_ex(req_ex_alu),
  .funct3_ex(funct3_ex_alu),
  .op_mux(op_mux_ex_alu),
  .src1_mux(src1_mux_ex_alu),
  .src2_mux(src2_mux_ex_alu),
  .datars1_ex_alu(datars1_ex_alu),
  .datars2_ex_alu(datars2_ex_alu),
  .pc_ex(pc_ex_alu),
  .imm(imm_ex_alu),
  .alubypass(result_alu_wb),
  .jmpbypass(result_jmp_wb),

  .result_ex(result_ex_alu)
);

iq_jmp iq_jmp(
  .clk(clk),
  .reset(reset),
  .flush_iq(flush_iq_commit),
  .no_free_iq_jmp(no_free_iq_jmp_dispatch),
  .one_free_iq_jmp(one_free_iq_jmp_dispatch),
  .ins_valid1_jmp(ins_valid1_jmp_dispatch),
  .rd_valid1_jmp(rd_valid1_dispatch),
  .pos1_jmp(pos1_rob_dispatch),
  .prd1_jmp(prd1_dispatch),
  .prs11_jmp(prs11_dispatch),
  .prs1_valid1_jmp(prs1_valid1_jmp_dispatch),
  .prs21_jmp(prs21_dispatch),
  .prs2_valid1_jmp(prs2_valid1_jmp_dispatch),
  .funct31_jmp(funct31_dispatch),
  .funct71_jmp(funct71_dispatch),
  .rs11_jmp(rs11_dispatch),
  .rs21_jmp(rs21_dispatch),
  .rd1_jmp(rd1_dispatch),
  .pc1_jmp(pc1_dispatch),
  .ins_valid2_jmp(ins_valid2_jmp_dispatch),
  .rd_valid2_jmp(rd_valid2_dispatch),
  .pos2_jmp(pos2_rob_dispatch),
  .prd2_jmp(prd2_dispatch),
  .prs12_jmp(prs12_dispatch),
  .prs1_valid2_jmp(prs1_valid2_jmp_dispatch),
  .prs22_jmp(prs22_dispatch),
  .prs2_valid2_jmp(prs2_valid2_jmp_dispatch),
  .funct32_jmp(funct32_dispatch),
  .funct72_jmp(funct72_dispatch),
  .rs12_jmp(rs12_dispatch),
  .rs22_jmp(rs22_dispatch),
  .rd2_jmp(rd2_dispatch),
  .pc2_jmp(pc2_dispatch),
  //recover
  .pc_grant(!pc_recover_jmp && req_ex_jmp),  // TODO
  // for RdyTable
  //.rd_valid1_jmp(rd_valid1_jmp_dispatch),
  //.rd_valid2_jmp(rd_valid2_jmp_dispatch),
  .prd1_alu(prd1_dispatch),
  .ins_valid1_alu(ins_valid1_alu_dispatch),
  .prd2_alu(prd2_dispatch),
  .ins_valid2_alu(ins_valid2_alu_dispatch),
  .prd1_lsq(),
  //.rd_valid1_lqs(),
  .ins_valid1_lsq(),
  .prd2_lsq(),
  //.rd_valid2_lsq(),
  .ins_valid2_lsq(),
  .req_issue_alu(req_issue_alu),
  .prd_issue_alu(prd_issue_alu),
  // Issue
  .req_issue(req_issue_jmp),
  .pos_issue(pos_issue_jmp),
  .prd_issue(prd_issue_jmp),
  .prs1_issue(prs1_issue_jmp),
  .prs1_valid_issue(prs1_valid_issue_jmp),
  .prs2_issue(prs2_issue_jmp),
  .prs2_valid_issue(prs2_valid_issue_jmp),
  .funct3_issue(funct3_issue_jmp),
  .funct7_issue(funct7_issue_jmp),
  .rs1_issue(rs1_issue_jmp),
  .rs2_issue(rs2_issue_jmp),
  .rd_issue(rd_issue_jmp),
  .pc_issue(pc_issue_jmp),
  .alubypass1_issue(alubypass1_issue_jmp),
  .alubypass2_issue(alubypass2_issue_jmp),
  .jmpbypass1_issue(jmpbypass1_issue_jmp),
  .jmpbypass2_issue(jmpbypass2_issue_jmp)
);

stage_rfread_jmp stage_rfread_jmp(
  .clk(clk),
  .reset(reset),
  .flush_iq(flush_iq_commit),

  .req_issue(req_issue_jmp),
  .pos_issue(pos_issue_jmp),
  .prd_issue(prd_issue_jmp),
  .prs1_issue(prs1_issue_jmp),
  .prs1_valid_issue(prs1_valid_issue_jmp),
  .prs2_issue(prs2_issue_jmp),
  .prs2_valid_issue(prs2_valid_issue_jmp),
  .funct3_issue(funct3_issue_jmp),
  .funct7_issue(funct7_issue_jmp),
  .rs1_issue(rs1_issue_jmp),
  .rs2_issue(rs2_issue_jmp),
  .rd_issue(rd_issue_jmp),
  .pc_issue(pc_issue_jmp),
  .alubypass1_issue(alubypass1_issue_jmp),
  .alubypass2_issue(alubypass2_issue_jmp),
  .jmpbypass1_issue(jmpbypass1_issue_jmp),
  .jmpbypass2_issue(jmpbypass2_issue_jmp),

  .req_ex(req_ex_jmp),
  .pos_ex(pos_ex_jmp),
  .prd_ex(prd_ex_jmp),
  .funct3_ex(funct3_ex_jmp),
  .src1_mux(src1_mux_ex_jmp),
  .src2_mux(src2_mux_ex_jmp),
  .imm(imm_ex_jmp),
  .pc_ex(pc_ex_jmp),
  .op_mux(op_mux_ex_jmp),

  .prs1_rfread(prs1_rfread_jmp),
  .prs2_rfread(prs2_rfread_jmp)
);

stage_ex_jmp stage_ex_jmp(
  .clk(clk),
  .reset(reset),
    
  .req_ex(req_ex_jmp),
  .funct3_ex(funct3_ex_jmp),
  .op_mux(op_mux_ex_jmp),
  .src1_mux(src1_mux_ex_jmp),
  .src2_mux(src2_mux_ex_jmp),
  .datars1_ex_alu(datars1_ex_jmp),
  .datars2_ex_alu(datars2_ex_jmp),
  .pc_ex(pc_ex_jmp),
  .imm(imm_ex_jmp),
  .alubypass(result_alu_wb),
  .jmpbypass(result_jmp_wb),

  .rd_valid_ex(rd_valid_ex_jmp),
  .result_ex(result_ex_jmp),
  .pc_recover(pc_recover_jmp),
  .new_pc(new_pc_jmp)
);

stage_wb stage_wb(
  .clk(clk),
  .reset(reset),
  .flush_iq(flush_iq_commit),
    
  .req_ex_alu(req_ex_alu),
  .result_ex_alu(result_ex_alu),
  .pos_ex_alu(pos_ex_alu),
  .prd_ex_alu(prd_ex_alu),
  .req_alu_wb(req_alu_wb),
  .result_alu_wb(result_alu_wb),
  .pos_alu_wb(pos_alu_wb),
  .prd_alu_wb(prd_alu_wb),

  .req_ex_jmp(req_ex_jmp),
  .rd_valid_ex_jmp(rd_valid_ex_jmp),
  .result_ex_jmp(result_ex_jmp),
  .pc_recover_jmp(pc_recover_jmp),
  //.new_pc_jmp(new_pc_jmp),
  .pos_ex_jmp(pos_ex_jmp),
  .prd_ex_jmp(prd_ex_jmp),
  .req_jmp_wb(req_jmp_wb),
  .rd_valid_jmp_wb(rd_valid_jmp_wb),
  .result_jmp_wb(result_jmp_wb),
  .pc_recover_jmp_wb(pc_recover_jmp_wb),
  //.new_pc_jmp_wb(new_pc_jmp_wb),
  .pos_jmp_wb(pos_jmp_wb),
  .prd_jmp_wb(prd_jmp_wb)
  
);




endmodule

`endif
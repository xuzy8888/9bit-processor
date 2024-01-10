// Project Name:   CSE141L
// Module Name:    Ctrl
// Create Date:    ?
// Last Update:    2022.01.13

// control decoder (combinational, not clocked)
// inputs from ... [instrROM, ALU flags, ?]
// outputs to ...  [program_counter (fetch unit), ?]
// import Definitions::*;

// n.b. This is an example / starter block
//      Your processor **will be different**!
module Ctrl (
  input  [8:0] Instruction,    // machine code
                               // some designs use ALU inputs here
  output logic       Jump,
                     BranchEn, // branch at all?
                     RegWrEn,  // write to reg_file (common)
                     MemWrEn,  // write to mem (store only)
                     LoadInst, // mem or ALU to reg_file ?
                     Ack,      // "done with program"
                     SetAluInputB1,
  output logic [3:0] TargSel,   // how to target branch (maybe?)
  output logic [3:0] AluCtrl,
                     RegFileRA,
                     RegFileRB,
                     wirte_address,
  output logic       i_llbi, i_lubi, BranchRelEn,
  input  logic       zero
);


// // instruction = 9'b110??????;
// assign MemWrEn = Instruction[8:6] == 3'b110;

// assign RegWrEn = Instruction[8:7] != 2'b11;
// assign LoadInst = Instruction[8:6] == 3'b011;

// reserve instruction = 9'b111111111; for Ack
assign Ack = &Instruction;
// // branch every time instruction = 9'b?????1111;
// assign BranchEn = &Instruction[3:0];

// // Maybe define specific types of branches?
assign TargSel  = Instruction[5:2];

logic [2:0] opcode;
logic [1:0] funct;
assign opcode = Instruction[8:6];
assign funct = Instruction[1:0];

parameter R_OPCODE1 = 3'b000;
parameter R_ADD_FUNC = 2'b00;
parameter R_SUB_FUNC = 2'b01;
parameter R_AND_FUNC = 2'b10;
parameter R_XOR_FUNC  = 2'b11;

parameter R_OPCODE2 = 3'b001;
parameter R_MOV_FUNC = 2'b00;
parameter R_LB_FUNC = 2'b01;
parameter R_SB_FUNC = 2'b10;
parameter R_ADV_FUNC = 2'b11;

parameter R_OPCODE3 = 3'b010;
parameter R_MSB_ECC_FUNC = 2'b00;
parameter R_LSB_ECC_FUNC = 2'b01;
parameter R_MSB_ECC_INV_FUNC = 2'b10;
parameter R_LSB_ECC_INV_FUNC = 2'b11;

parameter R_OPCODE4 = 3'b011;
parameter R_DEC_FUNC = 2'b00;
parameter R_MOVBNZ_FUNC = 2'b01;

parameter IMM_OPCODE = 3'b111;
parameter I_LLBI_FUNC = 3'b00;
parameter I_LUBI_FUNC = 3'b01;
parameter I_BNZREL_FUNC = 3'b10;

//RESERVED

parameter IMM_OPCODE1 = 3'b110;
parameter I_BNZABS_FUNC = 3'b00;

logic r_type1, r_type2, r_type3, r_type4;
assign r_type1 = (opcode == R_OPCODE1);
assign r_type2 = (opcode == R_OPCODE2);
assign r_type3 = (opcode == R_OPCODE3);
assign r_type4 = (opcode == R_OPCODE4);

logic r_add, r_sub, r_and, r_xor;
assign r_add = r_type1 && (funct == R_ADD_FUNC);
assign r_sub = r_type1 && (funct == R_SUB_FUNC);
assign r_and = r_type1 && (funct == R_AND_FUNC);
assign r_xor  = r_type1 && (funct == R_XOR_FUNC );

logic r_mov, r_lb, r_sb, r_adv;
assign r_mov = r_type2 && (funct == R_MOV_FUNC);
assign r_lb  = r_type2 && (funct == R_LB_FUNC);
assign r_sb  = r_type2 && (funct == R_SB_FUNC);
assign r_adv = r_type2 && (funct == R_ADV_FUNC);

logic r_msb_ecc, r_lsb_ecc, r_msb_ecc_inv, r_lsb_ecc_inv;
assign r_msb_ecc = r_type3 && (funct == R_MSB_ECC_FUNC); // special instruction solve p1 msb part
assign r_lsb_ecc = r_type3 && (funct == R_LSB_ECC_FUNC); // special instruction solve p1 lsb part
assign r_msb_ecc_inv = r_type3 && (funct == R_MSB_ECC_INV_FUNC);// special instruction solve p2 msb part
assign r_lsb_ecc_inv = r_type3 && (funct == R_LSB_ECC_INV_FUNC);// special instruction solve p2 lsb part

logic r_dec, r_movbnz;
assign r_dec    = r_type4 && (funct == R_DEC_FUNC);
assign r_movbnz = r_type4 && (funct == R_MOVBNZ_FUNC);

logic i_type;
assign i_type = (opcode == IMM_OPCODE);
logic i_bnzrel;
assign i_llbi = i_type && (funct == I_LLBI_FUNC);
assign i_lubi = i_type && (funct == I_LUBI_FUNC);
assign i_bnzrel  = i_type && (funct == I_BNZREL_FUNC );

logic i_type1;
logic i_bnzabs;
assign i_type1 = (opcode == IMM_OPCODE1);
assign i_bnzabs = i_type1 && (funct == I_BNZABS_FUNC);

assign RegWrEn = r_add | r_sub | r_and | r_xor |
                 r_mov | r_lb | r_adv| r_dec | r_movbnz |
                 i_llbi | i_lubi | r_lsb_ecc | r_msb_ecc | r_msb_ecc_inv | r_lsb_ecc_inv;

assign MemWrEn = r_sb;

assign BranchRelEn = i_bnzrel;
assign Jump = (i_bnzabs && !zero);

parameter ADD         = 4'b0000;
parameter SUB         = 4'b0001;
parameter AND         = 4'b0010;
parameter XOR         = 4'b0011;
parameter MSB_ECC     = 4'b0100;
parameter LSB_ECC     = 4'b0101;
parameter MSB_ECC_INV = 4'b0110;
parameter LSB_ECC_INV = 4'b0111;


assign AluCtrl = (r_add | r_adv | i_llbi | i_lubi | r_mov | r_movbnz | i_bnzrel | i_bnzabs)  ? ADD:
                 (r_sub | r_dec)  ? SUB:
                 (r_and)          ? AND:
                 (r_xor)          ? XOR:
                 (r_msb_ecc)      ? MSB_ECC:
                 (r_lsb_ecc)      ? LSB_ECC:
                 (r_msb_ecc_inv)  ? MSB_ECC_INV:
                 (r_lsb_ecc_inv)  ? LSB_ECC_INV : 4'bxxxx;

logic [3:0] rd;
assign rd = Instruction[5:2];
assign SetAluInputB1 = r_adv | r_dec;

assign RegFileRA = (r_add | r_sub | r_and | r_xor | i_lubi | r_mov | r_sb) ? 4'b0001:
                   (r_msb_ecc| r_lsb_ecc | r_msb_ecc_inv| r_lsb_ecc_inv)? 4'b1000:
                   (r_adv | r_dec | r_movbnz) ? rd :
                   (i_bnzrel | i_bnzabs) ? 4'b1111: 4'b0000;

assign RegFileRB = (r_add | r_sub | r_and | r_xor) ? 4'b0010:
                   r_lb ? 4'b0101 :
                   r_sb ? rd :
                   (r_msb_ecc| r_lsb_ecc | r_msb_ecc_inv| r_lsb_ecc_inv)? 4'b1001:
                   4'b0000;

assign wirte_address =  (r_movbnz) ? 4'b1111: 
                        (i_llbi | i_lubi | r_msb_ecc| 
                        r_lsb_ecc | r_msb_ecc_inv| r_lsb_ecc_inv) ? 4'b0001 : Instruction[5:2];

assign LoadInst = (r_lb) ? 1 : 0;

endmodule

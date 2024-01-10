// Module Name:    ALU
// Project Name:   CSE141L
//
// Additional Comments:
//   combinational (unclocked) ALU

// includes package "Definitions"
// import Definitions::*;

module ALU #(parameter W=8, Ops=3)(
  input        [W-1:0]   InputA,       // data inputs
                         InputB,
  //input        [Ops-1:0] OP,           // ALU opcode, part of microcode
  input        [3:0]     AluCtrl,
  input                  SC_in,        // shift or carry in
  output logic [W-1:0]   Out,          // data output
  output logic           Zero,         // output = zero flag    !(Out)
                         Parity,       // outparity flag        ^(Out)
                         Odd           // output odd flag        (Out[0])
                         // you may provide additional status flags, if desired
);
assign Zero   = ~|Out;                  // reduction NOR
assign Parity = ^Out;                   // reduction XOR
assign Odd    = Out[0];                 // odd/even -- just the value of the LSB


parameter ADD         = 4'b0000;
parameter SUB         = 4'b0001;
parameter AND         = 4'b0010;
parameter XOR         = 4'b0011;
parameter MSB_ECC     = 4'b0100;
parameter LSB_ECC     = 4'b0101;
parameter MSB_ECC_INV = 4'b0110;
parameter LSB_ECC_INV = 4'b0111;


logic p8;
logic [6:0] b11_b5;
assign b11_b5 = {InputB[2:0], InputA[7:4]};
assign p8 = ^b11_b5;
logic p4, p2, p1, p16;
assign p4 = ^{InputB[2:0], InputA[7], InputA[3:1]};
assign p2 = ^{InputB[2:1], InputA[6:5], InputA[3:2], InputA[0]};
assign p1 = ^{InputB[2], InputB[0], InputA[6], 
              InputA[4], InputA[3], InputA[1:0]};
assign p16 = ^{InputB[2:0], InputA, p8, p4, p2, p1};

logic np16, np8, np4, np2, np1;
assign np16 = ^{InputB, InputA};
assign np8 = ^{InputB};
assign np4 = ^{InputB[7:4], InputA[7:4]};
assign np2 = ^{InputB[7:6], InputB[3:2], InputA[7:6], InputA[3:2]};
assign np1 = ^{InputB[7], InputB[5], InputB[3], InputB[1], InputA[7], InputA[5], InputA[3], InputA[1]};
logic [7:0] r5, r6;
assign r5 = {4'b0, np8, np4, np2, np1};
assign r6 = 8'b0000_0001 << {np4, np2, np1};
logic [7:0] r1, r0;
assign r1 = np8 ? InputB ^ r6 : InputB;
assign r0 = (np8 == 0) ? InputA ^ r6 : InputA;
always_comb begin
  case(AluCtrl)
    ADD         : Out = InputA + InputB;
    SUB         : Out = InputA + (~InputB) + 1;
    AND         : Out = InputA & InputB;
    XOR         : Out = InputA ^ InputB;
    MSB_ECC     : Out = {b11_b5, p8};
    LSB_ECC     : Out = {InputA[3:1], p4, InputA[0], p2, p1, p16};
    MSB_ECC_INV : Out = np16 ? r1: InputB;
    LSB_ECC_INV : Out = np16 ? r0 : InputA;
    default : Out = 8'bxxxx_xxxx;
  endcase
end


endmodule

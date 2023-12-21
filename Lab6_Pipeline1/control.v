`timescale 1ns/1ps
`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,  
                output reg [1:0] ALUcntrl,
                input [5:0] opcode
);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
      /* TO FILL IN: The control signal values in each and every case */
          begin 
            RegDst = 1'b1;
            Branch = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            ALUcntrl = 2'b10;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
          end
       `ADDI:begin
            RegDst = 1'b0;
            Branch = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            ALUcntrl = 2'b00;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
          end
       `LW :   
           begin 
            RegDst = 1'b0;
            Branch = 1'b0;
            MemRead = 1'b1;
            MemToReg = 1'b1;
            ALUcntrl = 2'b00;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
           end
        `SW :   
           begin 
            RegDst = 1'bx;
            Branch = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'bx;
            ALUcntrl = 2'b00;
            MemWrite = 2'b01;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
           end
       default:
           begin
            RegDst = 1'bx;
            Branch = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            ALUcntrl = 2'b11;
            MemWrite = 1'b0;
            ALUSrc = 1'bx;
            RegWrite = 1'b0;
           end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
// TO FILL IN: Module details
module Forwarding(output reg [1:0] ForwardA, 
                  output reg [1:0] ForwardB,
                  input MEMWB_RegWrite,
                  input EXMEM_RegWrite, 
                  input [4:0]IDEX_instr_rd,
                  input [4:0]IDEX_instr_rs,
                  input [4:0]IDEX_instr_rt,
                  input [4:0]EXMEM_RegWriteAddr,
                  input [4:0]MEMWB_instr_rd
);

always @(*)begin
  {ForwardA, ForwardB} <= 0;

if((EXMEM_RegWrite == 1) && (EXMEM_RegWriteAddr != 0) && (IDEX_instr_rs == EXMEM_RegWriteAddr))
  ForwardA <= 2'b10;
else if((EXMEM_RegWrite == 1) && (EXMEM_RegWriteAddr != 0) && (IDEX_instr_rt == EXMEM_RegWriteAddr))
  ForwardB <= 2'b10;
else if((MEMWB_RegWrite == 1) && (MEMWB_instr_rd != 0) && (IDEX_instr_rs == MEMWB_instr_rd))
  ForwardA <= 2'b01;
else if((MEMWB_RegWrite == 1) && (MEMWB_instr_rd != 0) && (IDEX_instr_rt == MEMWB_instr_rd))
  ForwardB <= 2'b01;
end
endmodule

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
// TO FILL IN: Module details 
module HazardUnit(
  input IDEX_MemRead,
  input [4:0] IDEX_instr_rt,
  input [4:0] IFID_instr_rt,
  input [4:0] IFID_instr_rs,
  output reg PC_Write,
  output reg IFID_Write,
  output reg MUX_select
);

always @(*)begin
  {PC_Write,IFID_Write,MUX_select} <= 3'b111 ;

  if((IDEX_MemRead == 1) && ((IDEX_instr_rt == IFID_instr_rt) || (IDEX_instr_rt == IFID_instr_rs)))begin
    PC_Write <= 1'b0;
    IFID_Write <= 1'b0;
    MUX_select <= 1'b0;
  end
end

endmodule


/************** control for ALU control in EX pipe stage  *************/
module control_alu(
               output reg [3:0] ALUOp,
               output reg shift,
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b000000: begin
                ALUOp = 4'b1101; //sll
                shift = 1'b1;
              end
              6'b000100: begin
                ALUOp = 4'b1101;
                shift = 1'b0;
              end
              6'b100000: begin
                ALUOp = 4'b0010; // add
                shift = 1'b0;
              end
              6'b100010: begin
                ALUOp = 4'b0110; // sub
                shift = 1'b0;
              end
              6'b100100: begin 
                ALUOp = 4'b0000; // and
                shift = 1'b0;
              end
              6'b100101: begin 
                ALUOp = 4'b0001; // or
                shift = 1'b0;
              end
              6'b100111: begin 
                ALUOp = 4'b1100; // nor
                shift = 1'b0;
              end
              6'b101010: begin 
                ALUOp = 4'b0111; // slt
                shift = 1'b0;
              end
              default: begin 
                ALUOp = 4'bxxxx;
                shift = 1'b0;
              end       
             endcase 
          end   
        2'b00: begin
              ALUOp  = 4'b0010; // add
              shift = 1'b0;
        end
        2'b01: begin
              ALUOp = 4'b0110; // sub
              shift = 1'b0;
        end
        default: begin
              ALUOp = 4'bxxxx;
              shift = 1'b0;
        end
     endcase
    end
endmodule

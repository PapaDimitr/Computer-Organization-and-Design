// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                        Output: all the control signals needed 
`include "constants.h"
module ALU_Control(
           output reg [3:0] ALU_Control_Out,
           input [1:0] ALUOp,
           input [5:0] func);
always@(*) begin
  if(ALUOp == 2'b10)begin
  case ({ALUOp,func})
    8'hA0:begin
      ALU_Control_Out = 4'b0010;
    end
    8'hA2:begin
      ALU_Control_Out = 4'b0110;
    end
    8'hA5:begin
      ALU_Control_Out = 4'b0001;
    end
    8'hA4:begin
      ALU_Control_Out= 4'b0000;
    end
    8'hAA:begin
      ALU_Control_Out= 4'b0111;
    end
    default: ALU_Control_Out = 4'bx;
  endcase
  end
  else begin
  case(ALUOp)
    2'b00:begin
      ALU_Control_Out = 4'b0010;
    end
    2'b01:begin
      ALU_Control_Out = 4'b0110;
    end
    2'b11:begin
      ALU_Control_Out = 4'b0110;
    end
    default: ALU_Control_Out = 4'bx;
  endcase
  end
end
endmodule

module ControlUnit(
          input [5:0] opcode,
          input [5:0] func,
          output reg RegDst,
          output reg Branch,
          output reg Bne,
          output reg MemRead,
          output reg MemtoReg,
          output reg MemWrite,
          output reg ALUsrc,
          output reg RegWrite,
          output [3:0] ALU_Control_Out
);

reg [1:0]ALUOp;

ALU_Control ALU_DEC(
  .ALU_Control_Out(ALU_Control_Out),
  .ALUOp(ALUOp),
  .func(func)
);

always @(*)begin
  case (opcode)
    `R_FORMAT:begin//R-Format
      RegDst = 1'b1;
      Branch = 1'b0;
      MemRead = 1'b0;
      MemtoReg = 1'b0;
      ALUOp = 2'b10;
      MemWrite = 1'b0;
      ALUsrc = 1'b0;
      RegWrite = 1'b1;
      Bne = 1'b0;
    end
    `ADDI:begin //addi
      RegDst = 1'b0;
      Branch = 1'b0;
      MemRead = 1'b0;
      MemtoReg = 1'b0;
      ALUOp = 2'b00;
      MemWrite = 1'b0;
      ALUsrc = 1'b1;
      RegWrite = 1'b1;
      Bne = 1'b0;
    end
    `LW:begin//lw
      RegDst = 1'b0;
      Branch = 1'b0;
      MemRead = 1'b1;
      MemtoReg = 1'b1;
      ALUOp = 2'b00;
      MemWrite = 1'b0;
      ALUsrc = 1'b1;
      RegWrite = 1'b1;
      Bne = 1'b0;
    end
    `SW:begin
      RegDst = 1'bx;
      Branch = 1'b0;
      MemRead = 1'b0;
      MemtoReg = 1'bx;
      ALUOp = 2'b00;
      MemWrite = 1'b1;
      ALUsrc = 1'b1;
      RegWrite = 1'b0;
      Bne = 1'b0;
    end
    `BEQ:begin
      RegDst = 1'bx;
      Branch = 1'b1;
      MemRead = 1'b0;
      MemtoReg = 1'b0;
      ALUOp = 2'b01;
      MemWrite = 1'bx;
      ALUsrc = 1'b0;
      RegWrite = 1'b0;
      Bne = 1'b0;
    end
    `BNE:begin
      RegDst = 1'bx;
      Branch = 1'b1;
      MemRead = 1'b0;
      MemtoReg = 1'b0;
      ALUOp = 2'b11;
      MemWrite = 1'bx;
      ALUsrc = 1'b0;
      RegWrite = 1'b0;
      Bne = 1'b1;
    end
    default: begin
      RegDst = 1'bx;
      Branch = 1'bx;
      MemRead = 1'bx;
      MemtoReg = 1'bx;
      ALUOp = 2'bxx;
      MemWrite = 1'bx;
      ALUsrc = 1'bx;
      RegWrite = 1'bx;
    end
  endcase
end
endmodule

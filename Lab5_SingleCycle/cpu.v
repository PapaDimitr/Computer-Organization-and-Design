`include "library.v"
`include "controlUnit.v"
`include "constants.h"
`timescale 1ns/1ps

module CPU(clock,reset);
    input clock, reset;
    wire [31:0] PC_out;
    wire [31:0]instr ;
    wire [31:0] rdA, rdB;
    wire RegDst ;
    wire Branch;
    wire Bne ;
    wire zero ;
    wire MemRead ;
    wire MemtoReg ;
    wire MemtoRead ;
    wire [31:0]aluResult ;
    wire ALUSrc ;
    wire MemWrite ;
    wire RegWrite ;
    wire [31:0]ReadData ;
    wire [3:0] ALU_Control_Out ;

    PC pc(
                    .clock(clock),
                    .reset(reset),
                    .PC(PC_out),
        .PC_new(
            ((zero & Branch) | (~zero & Bne))?  
            (PC_out + ({ {16{instr[15]}}, instr[15:0] } << 2) + 4) : 
            (PC_out + 4)
        )
    );
    Memory cpu_IMem(.clock(clock),
                    .reset(reset),
                    .ren(1'b1),
                    .wen(1'b0),
                    .addr(PC_out >> 2),
                    .din(32'h0),
                    .dout(instr)
    );
    RegFile cpu_regs(.reset(reset), 
                    .clock(clock), 
                    .raA(instr[25:21]), 
                    .raB(instr[20:16]), 
                    .wa(RegDst ? instr[15:11]:instr[20:16]), 
                    .rdA(rdA),
                    .rdB(rdB), 
                    .wen(RegWrite),
                    .wd(MemtoReg ? ReadData : aluResult)
    );
    Memory cpu_DataMem(
                    .clock(clock),
                    .reset(reset),
                    .ren(MemRead),
                    .wen(MemWrite),
                    .addr(aluResult),
                    .din(rdB),
                    .dout(ReadData)
    );
    ControlUnit CU1(
                    .opcode(instr[31:26]),
                    .func(instr[5:0]),
                    .RegDst(RegDst),
                    .Branch(Branch),
                    .Bne(Bne),
                    .MemRead(MemRead),
                    .MemtoReg(MemtoReg),
                    .MemWrite(MemWrite),
                    .ALUsrc(ALUSrc),
                    .RegWrite(RegWrite),
                    .ALU_Control_Out(ALU_Control_Out)
    );
    ALU alu0(
                    .out(aluResult), 
                    .inA(rdA), 
                    .inB(ALUSrc ? { {16{instr[15]}}, instr[15:0] } : rdB), 
                    .op(ALU_Control_Out), 
                    .zero(zero)
    );
endmodule

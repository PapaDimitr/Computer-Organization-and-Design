`timescale 1ns/1ps
//`include "library.v"
//`include "control.v"
/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

module cpu(input clock, input reset);
 reg [31:0] PC; 
 reg [31:0] IFID_PCplus4;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend, IDEX_signExtendshamt;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd;                            
 reg        IDEX_RegDst; 
 reg        IDEX_ALUSrc;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite; 
 reg        IDEX_MemToReg, IDEX_RegWrite;                
 reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd; 
 reg [31:0] EXMEM_ALUOut;
 reg        EXMEM_Zero;
 reg [31:0] EXMEM_MemWriteData;
 reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr ; 
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite;               
 wire [31:0] instr, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, signExtendshamt, DMemOut, wRegData, PCIncr;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd, RegWriteAddr ,shamt;
 wire [3:0] ALUOp;
 wire [1:0] ALUcntrl;
 wire [15:0] imm;
 wire [1:0] ForwardA, ForwardB;
 wire PC_Write,IFID_Write,MUX_select;
 wire shift ;

 
 

/***************** Instruction Fetch Unit (IF)  ****************/
 always @(posedge clock or negedge reset)
  begin
    if(PC_Write == 0)
       PC <= PC - 4;
    else begin
    if (reset == 1'b0)     
       PC <= -1;     
    else if (PC == -1)
       PC <= 0;
    else 
       PC <= PC + 4;
    end
  end
  
  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin
    if(IFID_Write == 0)begin
      IFID_PCplus4 <= IFID_PCplus4;
      IFID_instr <= IFID_instr;
    end
    if (reset == 1'b0)     
      begin
       IFID_PCplus4 <= 32'b0;    
       IFID_instr <= 32'b0;
    end 
    else 
      begin
       IFID_PCplus4 <= PC + 32'd4;
       IFID_instr <= instr;
    end
  end
  
// TO FILL IN: Instantiate the Instruction Memory here 
Memory cpu_IMem(.clock(clock), .reset(reset), .ren(1'b1), .wen(1'b0), .addr(PC >> 2), .din(32'bx), .dout(instr));
  
  

/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign shamt = IFID_instr[10:6];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign imm = IFID_instr[15:0];
assign signExtend = {{16{imm[15]}}, imm};
assign signExtendshamt = {{27{shamt[4]}}, shamt};

// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

  // IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)
      begin
       IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
    end 
    else 
      begin
       IDEX_rdA <= rdA;
       IDEX_rdB <= rdB;
       IDEX_signExtend <= signExtend;
       IDEX_signExtendshamt <= signExtendshamt;
       IDEX_instr_rd <= instr_rd ;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt ;
       IDEX_RegDst <= (MUX_select ? RegDst : 1'd0) ;
       IDEX_ALUcntrl <= (MUX_select ? ALUcntrl : 1'd0) ;
       IDEX_ALUSrc <= (MUX_select ? ALUSrc : 1'd0) ;
       IDEX_Branch <= (MUX_select ? Branch : 1'd0) ;
       IDEX_MemRead <= (MUX_select ? MemRead : 1'd0) ;
       IDEX_MemWrite <= (MUX_select ? MemWrite : 1'd0);
       IDEX_MemToReg <= (MUX_select ? MemToReg : 1'd0) ;                  
       IDEX_RegWrite <= (MUX_select ? RegWrite : 1'd0);
    end
  end

// Main Control Unit 
control_main control_main (RegDst,
                           Branch,
                           MemRead,
                           MemWrite,
                           MemToReg,
                           ALUSrc,
                           RegWrite,
                           ALUcntrl,
                           opcode
);
                  
// TO FILL IN: Instantiation of Control Unit that generates stalls
HazardUnit HazardUnit(
                      IDEX_MemRead,
                      IDEX_instr_rt,
                      IFID_instr[20:16],
                      IFID_instr[25:21],
                      PC_Write,
                      IFID_Write,
                      MUX_select
);

/***************** Execution Unit (EX)  ****************/
                 
assign ALUInA = shift ? IDEX_signExtendshamt : ((ForwardA[1]) ? EXMEM_ALUOut : (ForwardA[0] ? wRegData : IDEX_rdA));
                 
assign ALUInB = (IDEX_ALUSrc == 1'b0) ? ((ForwardB[1]) ? EXMEM_ALUOut : (ForwardB[0] ? wRegData : IDEX_rdB)) : IDEX_signExtend ; 

//  ALU
ALU  #(32) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       EXMEM_ALUOut <= 32'b0;    
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;                  
       EXMEM_RegWrite <= 1'b0;
      end 
    else 
      begin
       EXMEM_ALUOut <= ALUOut;    
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= (ForwardB[1]) ? EXMEM_ALUOut : (ForwardB[0] ? wRegData : IDEX_rdB);
       EXMEM_Zero <= Zero;
       EXMEM_Branch <= IDEX_Branch;
       EXMEM_MemRead <= IDEX_MemRead;
       EXMEM_MemWrite <= IDEX_MemWrite;
       EXMEM_MemToReg <= IDEX_MemToReg;                  
       EXMEM_RegWrite <= IDEX_RegWrite;
      end
  end
  
  // ALU control
  control_alu control_alu(ALUOp, shift, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
  
   // TO FILL IN: Instantiation of control logic for Forwarding goes here

  Forwarding Forward_Unit(ForwardA,
                          ForwardB,
                          MEMWB_RegWrite,
                          EXMEM_RegWrite,
                          IDEX_instr_rd,
                          IDEX_instr_rs,
                          IDEX_instr_rt,
                          EXMEM_RegWriteAddr,
                          MEMWB_RegWriteAddr
  );
  
  
/***************** Memory Unit (MEM)  ****************/  

// Data memory 1KB
// Instantiate the Data Memory here 
Memory cpu_DMem(.clock(clock), 
                .reset(reset), 
                .ren(EXMEM_MemRead), 
                .wen(EXMEM_MemWrite), 
                .addr(EXMEM_ALUOut), 
                .din(EXMEM_MemWriteData),
                .dout(DMemOut)
);


// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       MEMWB_DMemOut <= 32'b0;    
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;                  
       MEMWB_RegWrite <= 1'b0;
      end 
    else 
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;                  
       MEMWB_RegWrite <= EXMEM_RegWrite;
      end
  end

  
  
  

/***************** WriteBack Unit (WB)  ****************/  
// TO FILL IN: Write Back logic 

assign wRegData = MEMWB_MemToReg ? MEMWB_DMemOut : MEMWB_ALUOut ;

endmodule

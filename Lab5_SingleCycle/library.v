// This file contains library modules to be used in your design. 

`include "constants.h"
`timescale 1ns/1ps

// Small ALU. 
//     Inputs: inA, inB, op. 
//     Output: out, zero
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);
  parameter N = 32;
  output [N-1:0] out;
  output zero;
  input  [N-1:0] inA, inB;
  input    [3:0] op;

  reg [N-1:0] ALU_result ;
  assign out = ALU_result;
  assign zero = !out ;

  always @(*)begin
    case(op)
      4'b0000:
        begin
          ALU_result = inA & inB ;
        end
      4'b0001:
        begin
          ALU_result = inA | inB ;
        end  
      4'b0010:
        begin
          ALU_result = inA + inB ;
        end
      4'b0110:
        begin
          ALU_result = inA - inB ;
        end
      4'b0111:
        begin
          ALU_result = ((inA < inB)?1:0) ;
        end
      4'b1100:
        begin
          ALU_result = ~(inA | inB);
        end
      default: ALU_result = 4'bx ;
    endcase
  end
endmodule


// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (clock,reset,ren, wen, addr, din, dout);
  input clock,reset;
  input         ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[4095:0];
  wire [31:0] dout;
  integer i ;

  always @(ren or wen)   // It does not correspond to hardware. Just for error detection
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(posedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;  
  
  always @(negedge clock /*or din or wen or ren or addr */or negedge reset)
   begin
    if(!reset)
      for(i=0; i<4096; i=i+1)begin
        data[i] = 31'h0;
      end
    if ((wen == 1'b1) && (ren==1'b0))
        data[addr[9:0]] <= din;
   end

endmodule


// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
  input clock, reset;
  input [4:0]raA, raB, wa;
  input wen;
  input [31:0] wd ;
  output [31:0] rdA, rdB;

  reg signed [31:0] data[31:0] ;
  integer i;

  assign rdA = data[raA] ;
  assign rdB = data[raB] ;

  always @(negedge clock or negedge reset)
  begin
    if(!reset) begin
      for(i=0; i<=31; i=i+1) begin
        data[i] = 32'b0;
      end
    end
    else if(wen) begin
      data[wa] <= wd;
    end
  end
endmodule

module PC(clock, reset, PC, PC_new);
  input [31:0] PC_new ;
  input clock ,reset;
  output reg [31:0] PC;

  always@(negedge clock or negedge reset)
  begin
    if(reset == 1'b0)
      PC = 0;
    else
      PC <= PC_new ;
  end
endmodule




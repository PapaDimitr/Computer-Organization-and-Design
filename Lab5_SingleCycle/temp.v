/*MUX #(.N(5)) Dst(.input0(instr[20:16]), .input1(instr[15:11]), .selection(RegDst), .out(DstOut));
    MUX #(.N(32)) InB(.input0(rdB), .input1(shiftIn), .selection(ALUSrc), .out(inB));
    MUX #(.N(32)) Write(.input0(aluResult), .input1(ReadData), .selection(MemtoReg), .out(writeData));
    MUX #(.N(32)) newPC(.input0(PC_current), .input1(PC_branch), .selection(BranchOut), .out(PC_in));*/


    /*SignExtension SE(.num(instr[15:0]), .extended(shiftIn));
    Shift2 shift(.num(shiftIn), .shiftedNum(shiftOut));
    and BranchAND (BranchOut,Branch,zero);
    ADD addPC2(PC_branch,shiftOut,PC_current);*/

//ADD addPC(PC_current,PC_out,32'd1);
//wire [31:0]shiftIn, shiftOut ;
//wire [4:0] DstOut ;
//wire [31:0] writeData ;
//wire [31:0] writeData ;
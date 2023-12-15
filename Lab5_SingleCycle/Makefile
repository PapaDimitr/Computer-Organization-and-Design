controlUnit: controlUnit.v
	iverilog -o controlUnit controlUnit.v
library: library.v
	iverilog -o library library.v
cpu: cpu.v
	iverilog -o cpu cpu.v
testbench: testbench.v cpu.v library.v controlUnit.v
	iverilog -o testbench testbench.v
.PHONY:

clear:
	rm -rf controlUnit library cpu

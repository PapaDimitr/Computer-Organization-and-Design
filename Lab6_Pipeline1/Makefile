CC = iverilog
FLAGS = -Wall -Winfloop
EXE = lab6a.out
SRCS = control.v library.v cpu.v testbench.v

cpu: cpu.v library.v control.v
	$(CC) -o cpu cpu.v library.v control.v

all: $(SRCS)
	$(CC) $(FLAGS) -o $(EXE) $(SRCS)
	vvp $(EXE)
	gtkwave tb_dumpfile.vcd waveform.gtkw

clean:
	rm -rf $(EXE)

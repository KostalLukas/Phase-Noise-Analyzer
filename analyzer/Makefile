# paths of SystemVerilog source files for compilation
VERILOG_SOURCES = $(PWD)/TickGen.sv $(PWD)/ADC.sv $(PWD)/DAC.sv $(PWD)/CORDIC.sv $(PWD)/Mixer.sv $(PWD)/NCO.sv \
				  $(PWD)/PLL.sv $(PWD)/CIC.sv $(PWD)/FIR.sv
				
# name of toplevel SystemVerilog file
# TOPLEVEL = 

# name of Python test file
# MODULE =

# simulation using Verilator and Cocotb
# SIM=verilator
# COCOTB_HDL_TIMEPRECISION = 1ns
# EXTRA_ARGS += --trace --trace-structs

# include $(shell cocotb-config --makefiles)/makefile.sim

PROJECT = Main

QUARTUS_CPF = docker run --platform linux/amd64 -it --rm -v .:/build didiermalenfant/quartus:22.1-apple-silicon quartus_cpf
QUARTUS_SH  = docker run --platform linux/amd64 -it --rm -v .:/build didiermalenfant/quartus:22.1-apple-silicon quartus_sh
 
all:
	echo "Used for mac only. Targets: build, program, clean"

build:
	$(QUARTUS_SH) --flow compile $(PROJECT)

program:	output_files/$(PROJECT).sof
	$(QUARTUS_CPF) -c -q 24.0MHz -g 3.3 -n p output_files/$(PROJECT).sof $(PROJECT).svf
	openFPGALoader -b de10lite $(PROJECT).svf 

clean::
	rm -rf output_files db incremental_db
	rm -f $(PROJECT).svf
	rm -rf __pycache__
	rm -f results.xml
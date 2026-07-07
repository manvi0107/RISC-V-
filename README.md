# RISC-V-
RISC-V datapath in Verilog HDL, single-cycle and 5-stage pipelined implementations, register file through memory ops and branching, verified via Icarus Verilog simulation.

Overview:
Supported instructions: add, sub, and, or (R-type), addi (I-type), lw/sw (load/store), beq (branch)
This project has two verified implementations, built in stages:
   1. Single-Cycle Datapath
The baseline implementation, register file, ALU, data memory, and PC/branch logic, all completing one instruction per clock cycle.

Register file: 32 x 32-bit registers, 2 read ports + 1 write port, x0 hardwired to zero
ALU: 32-bit, supports add/sub/and/or
ALUSrc mux: selects between rs2 and a sign-extended immediate
Data memory: word-addressed, supports lw/sw, with the ALU reused to compute rs1 + offset as the memory address
PC + branch logic: beq compares rs1/rs2; on equal, next_pc = pc + offset, otherwise next_pc = pc + 4

  2. 5-Stage Pipelined Datapath
Restructures the single-cycle version into IF / ID / EX / MEM / WB stages, connected by four pipeline registers (if_id_reg, id_ex_reg, ex_mem_reg, mem_wb_reg), allowing multiple instructions to be in flight simultaneously.
Known limitations (explicitly not yet implemented):
Branch instructions are not yet integrated into the pipeline (no flush logic for a taken branch discovered after younger instructions have already been fetched)
No hazard detection or forwarding, back-to-back instructions with register dependencies closer together than the pipeline depth will read stale values


Files:
reg_file.sv - register file
alu_32bit.sv - 32-bit ALU
data_mem.sv - data memory
datapath_single_cycle.sv - single-cycle datapath (includes PC + branch logic)
pc_reg.sv, if_id_reg.sv, id_ex_reg.sv, ex_mem_reg.sv, mem_wb_reg.sv pipeline registers
pipelined_datapath.sv - top-level 5-stage pipelined datapath
tb_datapath_single_cycle.sv - testbench for the single-cycle version (covers addi/add/sub, sw/lw round-trip, and both taken/not-taken beq outcomes)
tb_pipelined_datapath.sv - testbench for the pipelined version (streams independent instructions through all 5 stages, including a sw→lw round-trip)


Verification:
Every module was verified independently before integration (register file, then ALU, then single-cycle datapath, then data memory, then branch logic, then each pipeline register, then the full pipeline).

Pipelined datapath testbench confirms:
Four independent addi instructions each complete write-back exactly 4 cycles after being issued, demonstrating correct pipeline latency and throughput
A sw followed (after a gap) by an lw to the same address correctly round-trips a stored value through all 5 stages
A follow-up add using the loaded register confirms the value was written back correctly


Run it yourself:
On EDA Playground, with Icarus Verilog selected as the simulator:
For the single-cycle version: paste reg_file.sv + alu_32bit.sv + data_mem.sv + datapath_single_cycle.sv into the Design pane, tb_datapath_single_cycle.sv into the Testbench pane
For the pipelined version: paste all pipeline register modules + pipelined_datapath.sv (along with reg_file.sv, alu_32bit.sv, data_mem.sv) into the Design pane, tb_pipelined_datapath.sv into the Testbench pane


Next Steps"
Integrate beq into the pipeline with branch resolution + flush logic for fetched-but-invalid instructions
Hazard detection unit for load-use hazards (stalling)
Forwarding/bypass paths for data hazards between EX/MEM/WB and a later instruction's EX stage


Notes:
Built as a self-directed project to understand RISC-V datapath and pipelining fundamentals hands-on, alongside coursework in Digital Electronics and Computer Architecture.

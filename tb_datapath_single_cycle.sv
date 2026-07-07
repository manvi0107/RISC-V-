// Code your testbench here
// or browse Examples
// data memory module
module tb_pipelined_datapath;
    reg clk = 0;
    reg rst;
    reg [4:0] f_rs1_addr, f_rs2_addr, f_rd_addr;
    reg [31:0] f_imm;
    reg [2:0] f_alu_op;
    reg f_we, f_imm_sel, f_mem_write, f_mem_read, f_mem_to_reg;

    wire [31:0] pc_out, wb_write_data;
    wire [4:0] wb_rd_addr;
    wire wb_we;

    pipelined_datapath uut (
        .clk(clk), .rst(rst),
        .f_rs1_addr(f_rs1_addr), .f_rs2_addr(f_rs2_addr), .f_rd_addr(f_rd_addr),
        .f_imm(f_imm), .f_alu_op(f_alu_op),
        .f_we(f_we), .f_imm_sel(f_imm_sel), .f_mem_write(f_mem_write),
        .f_mem_read(f_mem_read), .f_mem_to_reg(f_mem_to_reg),
        .pc_out(pc_out), .wb_rd_addr(wb_rd_addr), .wb_write_data(wb_write_data), .wb_we(wb_we)
    );

    always #5 clk = ~clk;

    task issue(
        input [4:0] rs1, rs2, rd,
        input [31:0] imm,
        input [2:0] op,
        input we, imm_sel, mw, mr, m2r
    );
        begin
            f_rs1_addr = rs1; f_rs2_addr = rs2; f_rd_addr = rd;
            f_imm = imm; f_alu_op = op;
            f_we = we; f_imm_sel = imm_sel; f_mem_write = mw; f_mem_read = mr; f_mem_to_reg = m2r;
        end
    endtask

    task nop;
        begin
            issue(0,0,0, 0, 3'b000, 0,0,0,0,0);
        end
    endtask

    initial begin
        $monitor("t=%0t pc=%0d | WB: we=%b rd=%0d data=%0d",
                   $time, pc_out, wb_we, wb_rd_addr, wb_write_data);

        rst = 1; nop();
        #10 rst = 0;

        issue(0,0,1, 10, 3'b000, 1,1,0,0,0); #10;
        issue(0,0,2, 20, 3'b000, 1,1,0,0,0); #10;
        issue(0,0,3, 99, 3'b000, 1,1,0,0,0); #10;
        issue(0,0,4, 8,  3'b000, 1,1,0,0,0); #10;
        nop(); #10;
        nop(); #10;
        nop(); #10;
        issue(4,3,0, 0, 3'b000, 0,1,1,0,0); #10;
        nop(); #10;
        nop(); #10;
        nop(); #10;
        issue(4,0,5, 0, 3'b000, 1,1,0,1,1); #10;
        nop(); #10;
        nop(); #10;
        nop(); #10;
        issue(5,0,6, 0, 3'b000, 1,0,0,0,0); #10;
        nop(); #10;
        nop(); #10;
        nop(); #10;
        nop(); #10;
        nop(); #10;

        $finish;
    end
endmodule

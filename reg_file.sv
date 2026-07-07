// Code your design here
// register file:
// ===================== register file =====================
module reg_file (
    input clk,
    input we,
    input  [4:0] rs1_addr,
    input  [4:0] rs2_addr,
    input  [4:0] rd_addr,
    input  [31:0] rd_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);
    reg [31:0] regs [0:31];
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];
    always @(posedge clk) begin
        if (we && rd_addr != 5'd0) begin
            regs[rd_addr] <= rd_data;
        end
    end
endmodule

// ===================== ALU =====================
module alu_32bit (
    input  [31:0] a,
    input  [31:0] b,
    input  [2:0]  alu_op,
    output reg [31:0] result
);
    always @(*) begin
        case (alu_op)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            default: result = 32'd0;
        endcase
    end
endmodule

// ===================== data memory =====================
module data_mem (
    input clk,
    input mem_write,
    input mem_read,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:255];
    assign read_data = mem_read ? mem[addr[9:2]] : 32'd0;
    always @(posedge clk) begin
        if (mem_write)
            mem[addr[9:2]] <= write_data;
    end
endmodule

// ===================== PC register =====================
module pc_reg (
    input clk,
    input rst,
    output reg [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'd0;
        else
            pc <= pc + 32'd4;
    end
endmodule

// ===================== IF/ID pipeline register =====================
module if_id_reg (
    input clk,
    input rst,
    input [31:0] pc_in,
    input [4:0]  rs1_addr_in, rs2_addr_in, rd_addr_in,
    input [31:0] imm_in,
    input [2:0]  alu_op_in,
    input we_in, imm_sel_in, mem_write_in, mem_read_in, mem_to_reg_in,

    output reg [31:0] pc_out,
    output reg [4:0]  rs1_addr_out, rs2_addr_out, rd_addr_out,
    output reg [31:0] imm_out,
    output reg [2:0]  alu_op_out,
    output reg we_out, imm_sel_out, mem_write_out, mem_read_out, mem_to_reg_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 0; rs1_addr_out <= 0; rs2_addr_out <= 0; rd_addr_out <= 0;
            imm_out <= 0; alu_op_out <= 0;
            we_out <= 0; imm_sel_out <= 0; mem_write_out <= 0; mem_read_out <= 0; mem_to_reg_out <= 0;
        end else begin
            pc_out <= pc_in; rs1_addr_out <= rs1_addr_in; rs2_addr_out <= rs2_addr_in; rd_addr_out <= rd_addr_in;
            imm_out <= imm_in; alu_op_out <= alu_op_in;
            we_out <= we_in; imm_sel_out <= imm_sel_in; mem_write_out <= mem_write_in;
            mem_read_out <= mem_read_in; mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule

// ===================== ID/EX pipeline register =====================
module id_ex_reg (
    input clk,
    input rst,
    input [31:0] rs1_data_in, rs2_data_in, imm_in,
    input [4:0]  rd_addr_in,
    input we_in, imm_sel_in, mem_write_in, mem_read_in, mem_to_reg_in,
    input [2:0]  alu_op_in,

    output reg [31:0] rs1_data_out, rs2_data_out, imm_out,
    output reg [4:0]  rd_addr_out,
    output reg we_out, imm_sel_out, mem_write_out, mem_read_out, mem_to_reg_out,
    output reg [2:0]  alu_op_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rs1_data_out <= 0; rs2_data_out <= 0; imm_out <= 0; rd_addr_out <= 0;
            we_out <= 0; imm_sel_out <= 0; mem_write_out <= 0; mem_read_out <= 0; mem_to_reg_out <= 0;
            alu_op_out <= 0;
        end else begin
            rs1_data_out <= rs1_data_in; rs2_data_out <= rs2_data_in; imm_out <= imm_in;
            rd_addr_out <= rd_addr_in;
            we_out <= we_in; imm_sel_out <= imm_sel_in; mem_write_out <= mem_write_in;
            mem_read_out <= mem_read_in; mem_to_reg_out <= mem_to_reg_in;
            alu_op_out <= alu_op_in;
        end
    end
endmodule

// ===================== EX/MEM pipeline register =====================
module ex_mem_reg (
    input clk,
    input rst,
    input [31:0] alu_result_in, rs2_data_in,
    input [4:0]  rd_addr_in,
    input we_in, mem_write_in, mem_read_in, mem_to_reg_in,

    output reg [31:0] alu_result_out, rs2_data_out,
    output reg [4:0]  rd_addr_out,
    output reg we_out, mem_write_out, mem_read_out, mem_to_reg_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 0; rs2_data_out <= 0; rd_addr_out <= 0;
            we_out <= 0; mem_write_out <= 0; mem_read_out <= 0; mem_to_reg_out <= 0;
        end else begin
            alu_result_out <= alu_result_in; rs2_data_out <= rs2_data_in; rd_addr_out <= rd_addr_in;
            we_out <= we_in; mem_write_out <= mem_write_in; mem_read_out <= mem_read_in; mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule

// ===================== MEM/WB pipeline register =====================
module mem_wb_reg (
    input clk,
    input rst,
    input [31:0] alu_result_in, mem_read_data_in,
    input [4:0]  rd_addr_in,
    input we_in, mem_to_reg_in,

    output reg [31:0] alu_result_out, mem_read_data_out,
    output reg [4:0]  rd_addr_out,
    output reg we_out, mem_to_reg_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 0; mem_read_data_out <= 0; rd_addr_out <= 0;
            we_out <= 0; mem_to_reg_out <= 0;
        end else begin
            alu_result_out <= alu_result_in; mem_read_data_out <= mem_read_data_in; rd_addr_out <= rd_addr_in;
            we_out <= we_in; mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule

// ===================== Top-level pipelined datapath =====================
module pipelined_datapath (
    input clk,
    input rst,
    input [4:0] f_rs1_addr, f_rs2_addr, f_rd_addr,
    input [31:0] f_imm,
    input [2:0] f_alu_op,
    input f_we, f_imm_sel, f_mem_write, f_mem_read, f_mem_to_reg,

    output [31:0] pc_out,
    output [4:0] wb_rd_addr,
    output [31:0] wb_write_data,
    output wb_we
);
    wire [31:0] pc;

    pc_reg pcr (.clk(clk), .rst(rst), .pc(pc));
    assign pc_out = pc;

    wire [31:0] id_pc;
    wire [4:0]  id_rs1_addr, id_rs2_addr, id_rd_addr;
    wire [31:0] id_imm;
    wire [2:0]  id_alu_op;
    wire id_we, id_imm_sel, id_mem_write, id_mem_read, id_mem_to_reg;

    if_id_reg IFID (
        .clk(clk), .rst(rst),
        .pc_in(pc),
        .rs1_addr_in(f_rs1_addr), .rs2_addr_in(f_rs2_addr), .rd_addr_in(f_rd_addr),
        .imm_in(f_imm), .alu_op_in(f_alu_op),
        .we_in(f_we), .imm_sel_in(f_imm_sel), .mem_write_in(f_mem_write),
        .mem_read_in(f_mem_read), .mem_to_reg_in(f_mem_to_reg),

        .pc_out(id_pc),
        .rs1_addr_out(id_rs1_addr), .rs2_addr_out(id_rs2_addr), .rd_addr_out(id_rd_addr),
        .imm_out(id_imm), .alu_op_out(id_alu_op),
        .we_out(id_we), .imm_sel_out(id_imm_sel), .mem_write_out(id_mem_write),
        .mem_read_out(id_mem_read), .mem_to_reg_out(id_mem_to_reg)
    );

    wire [31:0] id_rs1_data, id_rs2_data;

    reg_file rf (
        .clk(clk), .we(wb_we),
        .rs1_addr(id_rs1_addr), .rs2_addr(id_rs2_addr), .rd_addr(wb_rd_addr),
        .rd_data(wb_write_data),
        .rs1_data(id_rs1_data), .rs2_data(id_rs2_data)
    );

    wire [31:0] ex_rs1_data, ex_rs2_data, ex_imm;
    wire [4:0]  ex_rd_addr;
    wire [2:0]  ex_alu_op;
    wire ex_we, ex_imm_sel, ex_mem_write, ex_mem_read, ex_mem_to_reg;

    id_ex_reg IDEX (
        .clk(clk), .rst(rst),
        .rs1_data_in(id_rs1_data), .rs2_data_in(id_rs2_data), .imm_in(id_imm),
        .rd_addr_in(id_rd_addr),
        .we_in(id_we), .imm_sel_in(id_imm_sel), .mem_write_in(id_mem_write),
        .mem_read_in(id_mem_read), .mem_to_reg_in(id_mem_to_reg),
        .alu_op_in(id_alu_op),

        .rs1_data_out(ex_rs1_data), .rs2_data_out(ex_rs2_data), .imm_out(ex_imm),
        .rd_addr_out(ex_rd_addr),
        .we_out(ex_we), .imm_sel_out(ex_imm_sel), .mem_write_out(ex_mem_write),
        .mem_read_out(ex_mem_read), .mem_to_reg_out(ex_mem_to_reg),
        .alu_op_out(ex_alu_op)
    );

    wire [31:0] ex_alu_b_in, ex_alu_result;
    assign ex_alu_b_in = ex_imm_sel ? ex_imm : ex_rs2_data;

    alu_32bit alu (
        .a(ex_rs1_data), .b(ex_alu_b_in), .alu_op(ex_alu_op), .result(ex_alu_result)
    );

    wire [31:0] mem_alu_result, mem_rs2_data;
    wire [4:0]  mem_rd_addr;
    wire mem_we, mem_mem_write, mem_mem_read, mem_mem_to_reg;

    ex_mem_reg EXMEM (
        .clk(clk), .rst(rst),
        .alu_result_in(ex_alu_result), .rs2_data_in(ex_rs2_data),
        .rd_addr_in(ex_rd_addr),
        .we_in(ex_we), .mem_write_in(ex_mem_write), .mem_read_in(ex_mem_read), .mem_to_reg_in(ex_mem_to_reg),

        .alu_result_out(mem_alu_result), .rs2_data_out(mem_rs2_data),
        .rd_addr_out(mem_rd_addr),
        .we_out(mem_we), .mem_write_out(mem_mem_write), .mem_read_out(mem_mem_read), .mem_to_reg_out(mem_mem_to_reg)
    );

    wire [31:0] mem_read_data_w;
    data_mem dmem (
        .clk(clk), .mem_write(mem_mem_write), .mem_read(mem_mem_read),
        .addr(mem_alu_result), .write_data(mem_rs2_data),
        .read_data(mem_read_data_w)
    );

    wire [31:0] wb_alu_result, wb_mem_read_data;
    wire wb_mem_to_reg;

    mem_wb_reg MEMWB (
        .clk(clk), .rst(rst),
        .alu_result_in(mem_alu_result), .mem_read_data_in(mem_read_data_w),
        .rd_addr_in(mem_rd_addr),
        .we_in(mem_we), .mem_to_reg_in(mem_mem_to_reg),

        .alu_result_out(wb_alu_result), .mem_read_data_out(wb_mem_read_data),
        .rd_addr_out(wb_rd_addr),
        .we_out(wb_we), .mem_to_reg_out(wb_mem_to_reg)
    );

    assign wb_write_data = wb_mem_to_reg ? wb_mem_read_data : wb_alu_result;

endmodule

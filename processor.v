`timescale 1ns/1ns

/*
 * Module: processor
 * Description: The top module of this lab 
 */
module processor (
	input CLK_pi,
	input CPU_RESET_pi
); 
 

// Declare wires to interconnect the ports of the modules to implement the processor

   wire [15:0] instruction;
   
   wire [2:0] alu_func;
	
   wire [2:0] destination_reg;
   wire [2:0] source_reg1;
   wire [2:0] source_reg2;
   
   wire [11:0] immediate;
   
   wire        arith_2op;
   wire        arith_1op; 
   
   wire      movi_lower;
   wire      movi_higher;
	
   wire      addi;
   wire      subi;
   
   wire      load;
   wire      store;
   
   wire      branch_eq;
   wire      branch_ge;
   wire      branch_le;
   wire      branch_carry;
	
   wire      jump;
   wire      stc_cmd;
   wire      stb_cmd;
   wire      halt_cmd;
   wire      rst_cmd;

   wire [15:0] reg1_data;
   wire [15:0] reg2_data;
   
   wire        alu_carry_in;
   wire        alu_borrow_in; 

   wire [15:0] alu_result;
   wire        alu_carry_out;
   wire        alu_borrow_out; 

   wire        is_branch_taken;
	wire 	      arith_2op_pi;
	wire [2:0]   alu_func_pi;
	wire 	      addi_pi;
	wire 	      subi_pi;
	input 	      load_or_store_pi;
	wire [15:0]  reg1_data_pi; // Register operand 1
	wire [15:0]  reg2_data_pi; // Register operand 2

   wire [15:0] regD_data;

   wire [15:0] shadowpc;

   wire [15:0] rdata;












   wire       cpu_clk_en = 1'b1; // Used to slow down CLK in FPGA implementation
   wire       reset, clock_enable;
   
   // Write an "assign" statement for the "reset" signal
   // Write an "assign" statement for the  "clock_enable" signal

   assign reset = CPU_RESET_pi | rst_cmd;
   assign clock_enable = cpu_clk_en & ~halt_cmd;

   
   // Add the input-output ports of each module instantiated below
   
decoder myDecoder(
.instruction_pi(instruction),
.alu_func_po(alu_func),
.destination_reg_po(destination_reg),
.source_reg1_po(source_reg1),
.source_reg2_po(source_reg2), 
.immediate_po(immediate),
.arith_2op_po(arith_2op),
.arith_1op_po(arith_1op),
.movi_lower_po(movi_lower), 
.movi_higher_po(movi_higher), 
.addi_po(addi),
.subi_po(subi), 
.load_po(load), 
.store_po(store),  
.branch_eq_po(branch_eq),
.branch_ge_po(branch_ge),
.branch_le_po(branch_le),
.branch_carry_po(branch_carry),
.jump_po(jump),
.stc_cmd_po(stc_cmd),
.stb_cmd_po(stb_cmd),
.halt_cmd_po(halt_cmd),
.rst_cmd_po(rst_cmd)
); 
   
  

alu  myALU(
.arith_1op_pi(arith_1op),
.arith_2op_pi(arith_2op),
.alu_func_pi(alu_func),
.addi_pi(addi),
.subi_pi(subi),
.load_or_store_pi(load | store), 
.reg1_data_pi(reg1_data),
.reg2_data_pi(reg2_data),
.immediate_pi(immediate[5:0]),
.stc_cmd_pi(stc_cmd),
.stb_cmd_pi(stb_cmd), 
.carry_in_pi(alu_carry_in), 
.borrow_in_pi(alu_borrow_in),  
.alu_result_po(alu_result),  
.carry_out_po(alu_carry_out), 
.borrow_out_po(alu_borrow_out)
);

   
regfile   myRegfile(
.clk_pi(CLK_pi),
//.clk_en_pi(~halted & cpu_clk_en),
.clk_en_pi(clock_enable),
.reset_pi(reset),
.source_reg1_pi(source_reg1),
.source_reg2_pi(source_reg2),
.destination_reg_pi(destination_reg),
.wr_destination_reg_pi(arith_2op | arith_1op | movi_lower | movi_higher | addi | subi | load),
.dest_result_data_pi(load ? rdata : alu_result),
.movi_lower_pi(movi_lower),
.movi_higher_pi(movi_higher),	
.immediate_pi(immediate[7:0]),
.new_carry_pi(alu_carry_out),
.new_borrow_pi(alu_borrow_out),

.reg1_data_po(reg1_data),
.reg2_data_po(reg2_data),
.regD_data_po(regD_data),
.current_carry_po(alu_carry_in),
.current_borrow_po(alu_borrow_in)
);
   

branch  myBranch( 
.branch_eq_pi(branch_eq), 
.branch_ge_pi(branch_ge),
.branch_le_pi(branch_le),
.branch_carry_pi(branch_carry), 
.reg1_data_pi(reg1_data), 
.reg2_data_pi(reg2_data), 
.alu_carry_bit_pi(alu_carry_in), 
.is_branch_taken_po(is_branch_taken)
);

program_counter myProgram_counter(
.clk_pi(CLK_pi),
.clk_en_pi(clock_enable),
.reset_pi(reset),
.branch_taken_pi(is_branch_taken),
.branch_immediate_pi(immediate[5:0]),
//.branch_immediate_pi(6'h2E),
.jump_taken_pi(jump),				  
.jump_immediate_pi(immediate),
//.jump_immediate_pi(12'hEFE),
.pc_po(shadowpc)
);
			  
instruction_mem myInstruction_mem(
.pc_pi(shadowpc),
.instruction_po(instruction)
);

data_mem  myData_mem(
.clk_pi(CLK_pi),
.clk_en_pi(clock_enable),
.reset_pi(reset),
.write_pi(store),
.wdata_pi(regD_data),
.addr_pi(alu_result),
.rdata_po(rdata)
);
  
endmodule 



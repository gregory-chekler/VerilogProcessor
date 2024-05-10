/*
 * Module: program_counter
 * Description: Program counter.
 *              Synchronously clear the program counter when "reset" and "clk_en" are asserted at a positive clock edge.
 *              Default action: increment the program counter by 2 (size of an instruction in bytes) every cycle unless halted.
 *              If a taken branch or jump is asserted: update the  program counter to the target address instead 
 *                                                    Target Address is PC + 2 + Sign-extended immediate value 
 *              Return the updated PC value in the output port signal "pc_po".
 * 
 */

module program_counter (
		input 	      clk_pi,
		input 	      clk_en_pi,
		input 	      reset_pi,
		
		input 	      branch_taken_pi,
		input [5:0]   branch_immediate_pi, // Needs to be sign extended		
		input 	      jump_taken_pi,
		input [11:0]  jump_immediate_pi, // Needs to be sign extended
			
		output [15:0] pc_po
		);

   reg [15:0] 		      PC;  // Program Counter   
   
       initial
	PC <= 16'hFFFF;  // Do not remove. Assumed by the Testbench.

	always @(posedge clk_pi) begin
			if (reset_pi)
				PC <= 16'b0;
			else begin
			if (clk_en_pi) begin
				if (branch_taken_pi) begin
					PC <= PC + 2 + {{11{branch_immediate_pi[5]}}, branch_immediate_pi[4:0]};
				end
				else if (jump_taken_pi) begin
					PC <= PC + 2 + {{5{jump_immediate_pi[11]}}, jump_immediate_pi[10:0]};
				end
				else
					PC <= PC + 2;
			end
		end
	end

	assign pc_po = PC;

endmodule




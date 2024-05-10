`timescale 1ns/1ns

module branch (
input        branch_eq_pi,
input        branch_ge_pi,
input        branch_le_pi,
input        branch_carry_pi,
input [15:0] reg1_data_pi,
input [15:0] reg2_data_pi,
input        alu_carry_bit_pi,

output  is_branch_taken_po)
;

reg branch_taken_inter;


always @(*) begin
    case ({branch_eq_pi, branch_ge_pi, branch_le_pi, branch_carry_pi})
    4'b1000: branch_taken_inter = reg1_data_pi == reg2_data_pi;
    4'b0100: branch_taken_inter = reg1_data_pi >= reg2_data_pi;
    4'b0010: branch_taken_inter = reg1_data_pi <= reg2_data_pi;
    4'b0001: branch_taken_inter = alu_carry_bit_pi;
    default: branch_taken_inter = 0;
    endcase
end

assign is_branch_taken_po = branch_taken_inter;

endmodule // branch_comparator

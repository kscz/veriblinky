`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:40:03 05/30/2015 
// Design Name: 
// Module Name:    parallel_shift 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module parallel_shift
	#(
		parameter SHIFT_WIDTH = 8,
		parameter PARALLEL = 32
	)
	(
		input wire clk,
		input wire en,
		input wire latch,
		input wire [(SHIFT_WIDTH * PARALLEL) - 1:0] in,
		output wire [PARALLEL - 1:0] out
	);

genvar i;
generate for (i = 0; i < PARALLEL; i= i + 1) begin : LOOP
	shift_reg #(.N(SHIFT_WIDTH)) shift (
			.clk(clk),
			.in(in[((i + 1) * SHIFT_WIDTH) - 1:(i * SHIFT_WIDTH)]),
			.out(out[i]),
			.latch(latch),
			.en(en)
		);
end
endgenerate

endmodule

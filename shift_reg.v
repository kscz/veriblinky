`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:21:52 05/09/2015 
// Design Name: 
// Module Name:    shift_reg 
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
module shift_reg
	#(parameter N = 8)
	(
		input wire clk,
		input wire [N-1:0] in,
		input wire latch,
		input wire en,
		output reg out
    );
	 
reg [N-2:0] data;

always @(posedge clk) begin
	if(latch == 1'b1) begin
		data <= in[N-1:1];
		out <= in[0];
	end
	else if(en == 1'b1) begin
		data <= {1'b0, data[N-2:1]};
		out <= data[0];
	end
end

endmodule

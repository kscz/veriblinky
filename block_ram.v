`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:01:16 05/16/2015 
// Design Name: 
// Module Name:    block_ram 
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
module block_ram
	#(
		parameter RAM_WIDTH = 8,
		parameter RAM_ADDR_BITS = 4,
		parameter INIT_FILE = "zeros.txt"
	)
	(
		input wire clk, w_en,
		input wire [RAM_ADDR_BITS-1:0] r_addr, w_addr,
		input wire [RAM_WIDTH-1:0] in,
		output wire [RAM_WIDTH-1:0] out
	);

   (* RAM_STYLE="auto" *)
   reg [RAM_WIDTH-1:0] data [(2**RAM_ADDR_BITS)-1:0];
   reg [RAM_WIDTH-1:0] out_reg;

   initial $readmemh(INIT_FILE, data, 0, (2**RAM_ADDR_BITS)-1);

   always @(posedge clk) begin
      if (w_en)
         data[w_addr] <= in;
		out_reg <= data[r_addr];
   end
	
	assign out = out_reg;

endmodule

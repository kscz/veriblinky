`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:10:31 04/26/2015 
// Design Name: 
// Module Name:    display_stuff 
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

module display_stuff(
		input wire clk_in,
		output reg [3:0] hub_mux,
		output wire hub_clk,
		output reg hub_latch, hub_oe,
		output wire [5:0] s_out 
	);

// All the local definitions!
localparam COLOR_BITS = 8; // Representable color (8bits per color per pixel)
localparam ROW_ADDR_BITS = 6; // 64 LEDs
localparam ROW_ELEM = (2**ROW_ADDR_BITS); // Number of LEDs in a row
localparam COL_ADDR_BITS = 4; // 16 rows
localparam COL_ELEM = (2**COL_ADDR_BITS); // Number of rows addressable by the MUX
localparam ROW_DAT_WIDTH = (ROW_ELEM * COLOR_BITS); // Number of bits to hold the data for 1 row

localparam DISP_COUNT = 2; // The number of 16 row displays in our setup
localparam PARALLEL_SHIFT = (DISP_COUNT * 3); // The number of shift registers output lines

localparam HUB_ENABLED = 1'b0;
localparam HUB_LATCH = 1'b1;
localparam SHIFT_LATCH_ON = 1'b1;
localparam SHIFT_EN_ON = 1'b1;

// THE CLOCK.  ALL HAIL.
wire clk;

// Stuff we'll actually control!
reg outshift_latch = 1'b0;
reg outshift_en = 1'b0;

reg colorshift_latch = 1'b0;
reg colorshift_en = 1'b0;

reg [3:0] cur_row = 0; // For keeping track of which row we're on
reg [COLOR_BITS-1:0] bcm_count = 0; // Which bit are we on in the current row
reg [ROW_ADDR_BITS:0] load_shift_latch = 6'h0; // We need 64 shift clocks and at least 1 more for the latch

// Some things we'll want
wire [COL_ADDR_BITS - 1:0] ram_waddr [PARALLEL_SHIFT - 1:0];

wire [ROW_DAT_WIDTH-1:0] ram_in [PARALLEL_SHIFT - 1:0];

wire ram_wen [PARALLEL_SHIFT - 1:0];

// Instantiate the clock manager, take in the 50MHz clock, output 25MHz
dcm clk_mgr (
		.CLKIN_IN(clk_in), 
		.CLKDV_OUT(clk), 
		.CLKIN_IBUFG_OUT(),
		.CLK0_OUT()
	);

genvar i;
generate for (i = 0; i < PARALLEL_SHIFT; i= i + 3) begin : REDLOOP
	wire [COL_ADDR_BITS - 1:0] ram_raddr;
	wire [ROW_DAT_WIDTH-1:0] ram_out;
	block_ram #( .RAM_WIDTH(ROW_DAT_WIDTH), .RAM_ADDR_BITS(COL_ADDR_BITS), .INIT_FILE("ram_red_init.txt")) pixel_ram (
		.clk(clk), .w_en(ram_wen[i]),
		.r_addr(ram_raddr), .w_addr(ram_waddr[i]),
		.in(ram_in[i]), .out(ram_out)
	);
	
	assign ram_raddr = cur_row;
	
	wire [ROW_ELEM-1:0] color_shift_out;
	parallel_shift #(.SHIFT_WIDTH(COLOR_BITS), .PARALLEL(ROW_ELEM)) color_shift (
		.clk(clk), .en(colorshift_en), .latch(colorshift_latch),
		.in(ram_out), .out(color_shift_out)
	);

	shift_reg #(.N(ROW_ELEM)) outshift (
		.clk(clk),
		.in(color_shift_out), .out(s_out[i]),
		.latch(outshift_latch),
		.en(outshift_en)
	);
end
endgenerate

generate for (i = 1; i < PARALLEL_SHIFT; i= i + 3) begin : GREENLOOP
	wire [COL_ADDR_BITS - 1:0] ram_raddr;
	wire [ROW_DAT_WIDTH-1:0] ram_out;
	block_ram #( .RAM_WIDTH(ROW_DAT_WIDTH), .RAM_ADDR_BITS(COL_ADDR_BITS), .INIT_FILE("ram_green_init.txt")) pixel_ram (
		.clk(clk), .w_en(ram_wen[i]),
		.r_addr(ram_raddr), .w_addr(ram_waddr[i]),
		.in(ram_in[i]), .out(ram_out)
	);
	
	assign ram_raddr = cur_row;
	
	wire [ROW_ELEM-1:0] color_shift_out;
	parallel_shift #(.SHIFT_WIDTH(COLOR_BITS), .PARALLEL(ROW_ELEM)) color_shift (
		.clk(clk), .en(colorshift_en), .latch(colorshift_latch),
		.in(ram_out), .out(color_shift_out)
	);

	shift_reg #(.N(ROW_ELEM)) outshift (
		.clk(clk),
		.in(color_shift_out), .out(s_out[i]),
		.latch(outshift_latch),
		.en(outshift_en)
	);
end
endgenerate

generate for (i = 2; i < PARALLEL_SHIFT; i= i + 3) begin : BLUELOOP
	wire [COL_ADDR_BITS - 1:0] ram_raddr;
	wire [ROW_DAT_WIDTH-1:0] ram_out;
	block_ram #( .RAM_WIDTH(ROW_DAT_WIDTH), .RAM_ADDR_BITS(COL_ADDR_BITS), .INIT_FILE("ram_blue_init.txt")) pixel_ram (
		.clk(clk), .w_en(ram_wen[i]),
		.r_addr(ram_raddr), .w_addr(ram_waddr[i]),
		.in(ram_in[i]), .out(ram_out)
	);
	
	assign ram_raddr = cur_row;
	
	wire [ROW_ELEM-1:0] color_shift_out;
	parallel_shift #(.SHIFT_WIDTH(COLOR_BITS), .PARALLEL(ROW_ELEM)) color_shift (
		.clk(clk), .en(colorshift_en), .latch(colorshift_latch),
		.in(ram_out), .out(color_shift_out)
	);

	shift_reg #(.N(ROW_ELEM)) outshift (
		.clk(clk),
		.in(color_shift_out), .out(s_out[i]),
		.latch(outshift_latch),
		.en(outshift_en)
	);
end
endgenerate

// Woooooo actual logic!
always @(posedge clk) begin
	load_shift_latch <= load_shift_latch + 1;

	if (load_shift_latch == 0) begin
		if (bcm_count == 0)
			hub_mux <= cur_row; // Bring the mux up to date with the RAM
		else if (bcm_count == 1)
			cur_row <= cur_row + 1; // Get the RAM to fetch the next row

		outshift_latch <= SHIFT_LATCH_ON; // Get the next bit latched into the outshifter

		hub_latch <= HUB_LATCH; // Latch the ouput from the previous cycle
		hub_oe <= HUB_ENABLED; // Turn on the display!
	end
	else if (load_shift_latch == 1) begin
		if (bcm_count == 1) begin
			colorshift_en <= SHIFT_EN_ON; // Put the 2nd bit of the current row on the shifter
		end
		else if (bcm_count == 5) begin
			colorshift_en <= SHIFT_EN_ON; // Put the 3rd bit of the current row on the shifter
		end
		else if (bcm_count == 13) begin
			colorshift_en <= SHIFT_EN_ON;
		end
		else if (bcm_count == 29) begin
			colorshift_en <= SHIFT_EN_ON;
		end
		else if (bcm_count == 61) begin
			colorshift_en <= SHIFT_EN_ON;
		end
		else if (bcm_count == 125) begin
			colorshift_en <= SHIFT_EN_ON;
		end
		else if (bcm_count == (2**COLOR_BITS)-2) begin
			colorshift_latch <= SHIFT_LATCH_ON; // Put the 0th bit of the next row on the shifter
		end
		else if (bcm_count == (2**COLOR_BITS)-1) begin
			colorshift_en <= SHIFT_EN_ON; // Put the 1st bit of the next row on the shifter
			hub_oe <= ~HUB_ENABLED;
		end
		
		outshift_latch <= ~SHIFT_LATCH_ON;
		outshift_en <= SHIFT_EN_ON;
		
		hub_latch <= ~HUB_LATCH;
	end
	// load_shift_latch == 2 means we've clocked out 1 bit
	else if (load_shift_latch == 2) begin
		colorshift_latch <= ~SHIFT_LATCH_ON;
		colorshift_en <= ~SHIFT_EN_ON;
	end
	// load_shift_latch == 3 means we've clocked out 2 bits
	// load_shift_latch == 4 means we've clocked out 2 bits
	// ...
	// load_shift_latch == (ROW_ELEM) means we've clocked out (ROW_ELEM - 1) bits
	// load_shift_latch == (ROW_ELEM + 1) means we've clocked out (ROW_ELEM) bits
	else if (load_shift_latch == (ROW_ELEM + 1)) begin
		outshift_en <= 1'b0;
		load_shift_latch <= 0;
		bcm_count <= bcm_count + 1;
	end
end

// We need to control the external MUX with the row counter!
assign hub_clk = (outshift_en ? ~clk : 1'b0);

endmodule

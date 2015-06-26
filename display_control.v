`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:10:28 06/14/2015 
// Design Name: 
// Module Name:    display_control 
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
module display_control
	#(
		parameter COLOR_BITS = 4,
		parameter COL_ADDR_BITS = 6, // Number of address bits for columns in a row
		parameter ROW_ADDR_BITS = 4, // Number of address bits for rows in a column
		parameter COLOR_COUNT = 3
	)
	(
		input wire clk,
		input wire [ROW_DAT_WIDTH-1:0] row_in,
		output wire [ROW_ADDR_BITS-1:0] next_row,
		output reg hub_clk, hub_noe, hub_lat,
		output reg [ROW_ADDR_BITS-1:0] hub_mux,
		output wire [COLOR_COUNT-1:0] s_out
    );

// All the local definitions!
localparam NUM_COL = (2**COL_ADDR_BITS); // Number of LEDs in a row
localparam COLOR_DAT_WIDTH = (NUM_COL * COLOR_BITS);
localparam ROW_DAT_WIDTH = (COLOR_DAT_WIDTH * COLOR_COUNT); // Number of bits to hold the data for 1 row

localparam LAST_STATE = (NUM_COL * 2);
localparam LAST_BCM_STATE = (2**COLOR_BITS) - 2;

// Constants 
localparam HUB_EN_ON = 1'b0;
localparam HUB_LATCH_EN = 1'b1;
localparam SHIFT_LATCH_EN = 1'b1;
localparam SHIFT_EN_ON = 1'b1;

// convenience wires
wire [COLOR_DAT_WIDTH-1:0] color_in [COLOR_COUNT-1:0];

// Stuff we'll actually control!
reg outshift_latch = 1'b0;
reg outshift_en = 1'b0;
reg colorshift_latch = 1'b0;
reg colorshift_en = 1'b0;

// Loop variables
reg [ROW_ADDR_BITS-1:0] cur_row = 0; // For keeping track of which row we're on
reg [COLOR_BITS-1:0] bcm_count = LAST_BCM_STATE - 2; // Which bit are we on in the current row
reg [COL_ADDR_BITS+1:0] load_shift_latch = 0; // We need (2**COL_ADDR_BITS) shift clocks and 1 more for the latch

// Generators!
genvar i, j;
integer k;

generate for (i = 0; i < COLOR_COUNT; i = i + 1) begin : COLOR_BREAKOUT
	for (j = 0; j < NUM_COL; j = j + 1) begin : ELEM_BREAKOUT
		localparam CUR_SRC = ((COLOR_COUNT*j)+i)*COLOR_BITS;
		localparam NEXT_SRC = CUR_SRC + COLOR_BITS;

		localparam CUR_DST = j*COLOR_BITS;
		localparam NEXT_DST = CUR_DST + COLOR_BITS;

		assign color_in[i][NEXT_DST-1:CUR_DST] = row_in[NEXT_SRC-1:CUR_SRC];
	end
end
endgenerate

generate for (i = 0; i < COLOR_COUNT; i= i + 1) begin : COLORSHIFTGEN
	wire [NUM_COL-1:0] color_shift_out;	

	parallel_shift #(.SHIFT_WIDTH(COLOR_BITS), .PARALLEL(NUM_COL)) color_shift (
		.clk(clk), .en(colorshift_en), .latch(colorshift_latch),
		.in(color_in[i]), .out(color_shift_out)
	);

	shift_reg #(.N(NUM_COL)) outshift (
		.clk(clk),
		.in(color_shift_out), .out(s_out[i]),
		.latch(outshift_latch),
		.en(outshift_en)
	);
end
endgenerate

always @(posedge clk) begin
	// State updater!
	if (load_shift_latch == LAST_STATE) begin
		load_shift_latch <= 0;
	end
	else begin
		load_shift_latch <= load_shift_latch + 1;
	end

	// Ouput clock handler
	if (~load_shift_latch[0]) begin
		hub_clk <= ~hub_clk;
	end
	else begin
		hub_clk <= 1'b0;
	end

	// HUB75 mux pins handled here
	if (load_shift_latch == LAST_STATE) begin
		if (bcm_count == LAST_BCM_STATE) begin
			hub_mux <= cur_row; // Bring the mux up to date
		end
	end

	// HUB75 latch
	if (load_shift_latch == LAST_STATE) begin
		hub_lat <= HUB_LATCH_EN; // Latch the ouput from the previous cycle
	end
	else begin
		hub_lat <= ~HUB_LATCH_EN;
	end

	// HUB75 enable
	if (load_shift_latch == LAST_STATE - 1) begin
		if (bcm_count == LAST_BCM_STATE) begin
			hub_noe <= ~HUB_EN_ON;
		end
	end
	else if (load_shift_latch == 2) begin
		hub_noe <= HUB_EN_ON;
	end

	// Outshift enable pulses
	if (~load_shift_latch[0] && load_shift_latch != (LAST_STATE-1) && load_shift_latch != LAST_STATE) begin
		outshift_en <= SHIFT_EN_ON;
	end
	else begin
		outshift_en <= ~SHIFT_EN_ON;
	end
	
	// Latch the output shifter
	if (load_shift_latch == (LAST_STATE-1)) begin
		outshift_latch <= SHIFT_LATCH_EN; // Get the next bit latched into the outshifter
	end
	else begin
		outshift_latch <= ~SHIFT_LATCH_EN;
	end

	// Colorshifter latching
	if (load_shift_latch == 2) begin
		if (bcm_count == LAST_BCM_STATE-1) begin
			colorshift_latch <= SHIFT_LATCH_EN; // Put the 0th bit of the next row on the shifter
		end
	end
	else begin
		colorshift_latch <= ~SHIFT_LATCH_EN;
	end

	// Color shifter enabling
	if (load_shift_latch == 2) begin
		for (k = 2; ((2**k)-3) < LAST_BCM_STATE-2; k = k + 1) begin
			if (bcm_count == ((2**k)-3)) begin
				colorshift_en <= SHIFT_EN_ON;
			end
		end

		if (bcm_count == LAST_BCM_STATE) begin
			colorshift_en <= SHIFT_EN_ON; // Put the 1st bit of the next row on the shifter
		end
	end
	else begin
		colorshift_en <= ~SHIFT_EN_ON;
	end

	// Update the current row!
	if (load_shift_latch == 0) begin
		if (bcm_count == LAST_BCM_STATE) begin
			cur_row <= cur_row + 1;
		end
	end

	// BCM state update
	if (load_shift_latch == LAST_STATE) begin
		if (bcm_count == LAST_BCM_STATE) begin
			bcm_count <= 0;
		end
		else begin
			bcm_count <= bcm_count + 1;
		end
	end
end

assign next_row = cur_row + 1;

endmodule

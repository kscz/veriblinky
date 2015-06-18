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
		input wire OSC_FPGA,

		// For GPMC control/interfacing
		inout wire [15:0] GPMC_AD,
		input wire GPMC_CSN,
		input wire GPMC_OEN,
		input wire GPMC_ADVN,
		input wire GPMC_WEN,
		input wire [1:0] GPMC_BEN,
		input wire GPMC_CLK,

		// For control of the HUB75 interface
		output wire [ROW_ADDR_BITS-1:0] HUB_MUX,
		output wire HUB_CLK,
		output wire HUB_LAT, HUB_NOE,
		output wire [(COLOR_COUNT*SEGMENT_COUNT)-1:0] S_OUT
	);

// All the local definitions!
localparam COLOR_COUNT = 3; // Number of colors (RGB? RG? R?)
localparam COLOR_BITS = 4; // Representable color (bits per color, per pixel)
localparam COL_ADDR_BITS = 6; // 64 LEDs
localparam ROW_ADDR_BITS = 4; // 16 rows

localparam ROW_ELEM = (2**COL_ADDR_BITS); // Number of columns in 1 row
localparam PIXEL_WIDTH = (COLOR_BITS*COLOR_COUNT); // number of bits in a full color pixel

localparam COLOR_DAT_WIDTH = (ROW_ELEM * COLOR_BITS); // Number of bits to hold the data for 1 row
localparam  ROW_DAT_WIDTH = (COLOR_DAT_WIDTH * COLOR_COUNT);

localparam SEGMENT_COUNT = 2;

// THE CLOCK.  ALL HAIL.
wire clk;
wire disp_clk;

wire [ROW_ADDR_BITS-1:0] get_row;

reg [SEGMENT_COUNT-1:0] w_en = 0;
reg [ROW_ADDR_BITS-1:0] ram_raddr;
wire [ROW_ADDR_BITS-1:0] ram_waddr;
wire [ROW_DAT_WIDTH-1:0] ram_in;
wire [ROW_DAT_WIDTH-1:0] ram_out;

// Wishbone interface
reg gls_reset;
wire [15:0] wbm_address, wbm_writedata;
reg [15:0] wbm_readdata;
wire wbm_write, wbm_cycle;
reg wbm_ack;

// wishbone input processing
reg [15:0] cur_thing = 0;
reg [PIXEL_WIDTH-1:0] host_pix_buf [ROW_ELEM-1:0];
reg [15:0] cur_addr;

genvar i;

// Instantiate the clock manager, take in the 50MHz clock, output 25MHz
dcm clk_mgr (
		.CLK_IN1(OSC_FPGA),
		.CLK_OUT1(clk),
		.CLK_OUT2(disp_clk)
	);

gpmc_wishbone_wrapper #(.sync(1'b1), .burst(1'b0)) gpmc2wishbone (
		.gpmc_ad(GPMC_AD), .gpmc_csn(GPMC_CSN), .gpmc_oen(GPMC_OEN),
		.gpmc_wen(GPMC_WEN), .gpmc_advn(GPMC_ADVN), .gpmc_clk(GPMC_CLK),
		.gls_clk(clk), .gls_reset(gls_reset),
		.wbm_address(wbm_address), .wbm_readdata(wbm_readdata),
		.wbm_writedata(wbm_writedata), .wbm_strobe(wbm_strobe),
		.wbm_write(wbm_write), .wbm_ack(wbm_ack), .wbm_cycle(wbm_cycle)
	);

block_ram #( .RAM_WIDTH(ROW_DAT_WIDTH), .RAM_ADDR_BITS(ROW_ADDR_BITS),
		.INIT_FILE("ram_4bit_init_0.txt")
	) ram (
		.clk(clk), .w_en(w_en[0]), .r_addr(ram_raddr),
		.w_addr(ram_waddr), .in(ram_in), .out(ram_out)
	);

// The master instance which actually controls the world
display_control #(
		.COLOR_BITS(COLOR_BITS), .COL_ADDR_BITS(COL_ADDR_BITS),
		.ROW_ADDR_BITS(ROW_ADDR_BITS), .COLOR_COUNT(COLOR_COUNT)
	) disp_ctl (
		.clk(disp_clk), .row_in(ram_out),
		.next_row(get_row), .hub_clk(HUB_CLK),
		.hub_noe(HUB_NOE), .hub_lat(HUB_LAT),
		.hub_mux(HUB_MUX), .s_out(S_OUT[COLOR_COUNT-1:0])
    );

//generate for (i = 1; i < SEGMENT_COUNT; i = i + 1) begin : SEGMENT_GEN
	wire [ROW_DAT_WIDTH-1:0] ram_out_seg;

	block_ram #( .RAM_WIDTH(ROW_DAT_WIDTH), .RAM_ADDR_BITS(ROW_ADDR_BITS),
			.INIT_FILE("ram_4bit_init_1.txt")
		) ram_seg (
			.clk(clk), .w_en(w_en[1]), .r_addr(ram_raddr),
			.w_addr(ram_waddr), .in(ram_in), .out(ram_out_seg)
		);

	display_control #(
			.COLOR_BITS(COLOR_BITS), .COL_ADDR_BITS(COL_ADDR_BITS),
			.ROW_ADDR_BITS(ROW_ADDR_BITS), .COLOR_COUNT(COLOR_COUNT)
		) disp_ctl_seg (
			.clk(disp_clk), .row_in(ram_out_seg),
			.next_row(), .hub_clk(), .hub_noe(), .hub_lat(),
			.hub_mux(), .s_out(S_OUT[(2*COLOR_COUNT)-1:COLOR_COUNT])
		);
//end
//endgenerate

// Woooooo actual logic!
always @(posedge clk) begin
	ram_raddr <= get_row;

	if ((wbm_write & wbm_strobe & wbm_cycle) == 1'b1) begin
		cur_addr <= wbm_address;
		host_pix_buf[cur_thing] <= wbm_writedata[PIXEL_WIDTH-1:0];
		if (cur_addr == wbm_address) begin
			cur_thing <= cur_thing + 1;
		end
		else begin
			cur_thing <= 0;
		end
		wbm_ack <= 1'b1;

		if (cur_thing == ROW_ELEM-1) begin
			cur_thing <= 0;
			if (cur_addr < 16) begin
				w_en[0] <= 1'b1;
			end
			else if (cur_addr < 32) begin
				w_en[1] <= 1'b1;
			end
		end
	end
	else begin
		wbm_ack <= 1'b0;
		w_en <= 0;
	end
end

genvar j;
generate for (j = 0; j < ROW_ELEM; j = j + 1) begin : MAP_HOST_PIXBUF
	assign ram_in[((j+1)*PIXEL_WIDTH)-1:PIXEL_WIDTH*j] = host_pix_buf[j];
end
endgenerate

assign ram_waddr = cur_addr[ROW_ADDR_BITS-1:0];

endmodule

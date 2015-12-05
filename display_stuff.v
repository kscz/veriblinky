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
		output wire [3:0] HUB_MUX,
		output wire HUB_CLK,
		output wire HUB_LAT, HUB_NOE,
		output wire [5:0] S_OUT
	);

// Instantiate the clock manager, take in the 50MHz clock, output 25MHz
dcm clk_mgr (
		.CLK_IN1(OSC_FPGA),
		.CLK_OUT1(clk),
		.CLK_OUT2(clk_slo)
	);

// Wishbone interface
reg gls_reset;
wire [15:0] wbm_address, wbm_writedata;
reg [15:0] wbm_readdata;
wire wbm_write, wbm_cycle;
reg wbm_ack;

gpmc_wishbone_wrapper #(.sync(1'b1), .burst(1'b0)) gpmc2wishbone (
		.gpmc_ad(GPMC_AD), .gpmc_csn(GPMC_CSN), .gpmc_oen(GPMC_OEN),
		.gpmc_wen(GPMC_WEN), .gpmc_advn(GPMC_ADVN), .gpmc_clk(GPMC_CLK),
		.gls_clk(clk), .gls_reset(gls_reset),
		.wbm_address(wbm_address), .wbm_readdata(wbm_readdata),
		.wbm_writedata(wbm_writedata), .wbm_strobe(wbm_strobe),
		.wbm_write(wbm_write), .wbm_ack(wbm_ack), .wbm_cycle(wbm_cycle)
	);

reg [11:0] disp_w_addr = 0;
reg disp_w_en = 0;
reg [11:0] disp_pix_in = 0;

display_controller disp_controller (
        .clk(clk), .write_addr(disp_w_addr),
        .w_en(disp_w_en), .pixel_in(disp_pix_in),
        .s_clk(HUB_CLK), .mux(HUB_MUX), .noe(HUB_NOE),
        .s_r_t(S_OUT[0]), .s_g_t(S_OUT[1]), .s_b_t(S_OUT[2]),
        .s_r_b(S_OUT[3]), .s_g_b(S_OUT[4]), .s_b_b(S_OUT[5]),
        .latch(HUB_LAT)
    );

reg [11:0] cpu_dat;

// Woooooo actual logic!
always @(posedge clk) begin
	// Always ack the wishbone bus!
	if (wbm_write_en) begin
		wbm_ack <= 1'b1;
	end
	else begin
		wbm_ack <= 1'b0;
	end

	// Handle data which is input!
	if (wbm_write_en) begin
        disp_w_addr <= wbm_address[11:0];
        disp_pix_in <= wbm_writedata[11:0];
        disp_w_en <= 1;
	end
    else begin
        disp_w_en <= 0;
    end
end

assign wbm_write_en = (wbm_write & wbm_strobe & wbm_cycle);

endmodule

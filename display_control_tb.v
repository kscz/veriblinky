`timescale 1ns/1ps

module disp_ctl_tb;

// All the local definitions!
localparam COLOR_COUNT = 3; // Number of colors (RGB? RG? R?)
localparam COLOR_BITS = 4; // Representable color (bits per color, per pixel)
localparam COL_ADDR_BITS = 6; // 64 LEDs
localparam ROW_ADDR_BITS = 4; // 16 rows

localparam ROW_ELEM = (2**COL_ADDR_BITS); // Number of columns in 1 row
localparam COLOR_DAT_WIDTH = (ROW_ELEM * COLOR_BITS); // Number of bits to hold the data for 1 row
localparam  ROW_DAT_WIDTH = (COLOR_DAT_WIDTH * COLOR_COUNT);

reg clk;
reg [ROW_DAT_WIDTH-1:0] in;

wire [ROW_ADDR_BITS-1:0] next_row, hub_mux;
wire hub_clk, hub_noe, hub_lat;
wire [COLOR_COUNT-1:0] s_out;

display_control #(
		.COLOR_BITS(COLOR_BITS), .COL_ADDR_BITS(COL_ADDR_BITS),
		.ROW_ADDR_BITS(ROW_ADDR_BITS), .COLOR_COUNT(COLOR_COUNT)
	) disp_ctl (
		.clk(clk), .row_in(in),
		.next_row(next_row), .hub_clk(hub_clk),
		.hub_noe(hub_noe), .hub_lat(hub_lat),
		.hub_mux(hub_mux), .s_out(s_out)
    );

initial clk = 1'b0;
always clk  = #(1.0e9 / 25_000_000.0 / 2.0) ~clk;

initial begin
    $dumpfile("disp_ctl_dump.vcd");
    $dumpvars();

    // in = 768'hF00E10D20C30B40A509608707806905A04B03C02D01E00F0A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00;
    // in = 768'hA00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00A00;
    in = 768'hA00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000A00000;

    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);
    repeat(65) @(posedge clk);

    $display("SIMULATION COMPLETE");

    $finish;
end

endmodule

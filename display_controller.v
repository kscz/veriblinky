`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:31:33 07/07/2015 
// Design Name: 
// Module Name:    display_controller 
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
module display_controller
    #(
        parameter COLOR_BITS = 4,
        parameter COLOR_COUNT = 3
    )
    (
        input wire clk,
        input wire [11:0] write_addr,
        input wire w_en,
        input wire [PIXEL_BITS-1:0] pixel_in,
        output reg s_clk,
        output reg s_r_t, s_g_t, s_b_t,
        output reg s_r_b, s_g_b, s_b_b,
        output reg noe, latch,
        output wire [3:0] mux
    );

localparam PIXEL_BITS = (COLOR_BITS * COLOR_COUNT);
localparam TOP_HALF_MAX = 2047;

localparam [1:0]
    shifting = 2'h0,
    latching = 2'h1;

reg ram_w_en_top = 0, ram_w_en_bot = 0;
reg [10:0] ram_w_addr, ram_r_addr;
reg [PIXEL_BITS-1:0] ram_in;
wire [PIXEL_BITS-1:0] ram_out_top, ram_out_bot;

reg [1:0] state_reg = shifting;

reg [6:0] shift_count = 0;
reg [3:0] row_count = 0;
reg [COLOR_BITS-1:0] bcm_count = 0;

wire [3:0] red_top_pix, green_top_pix, blue_top_pix;
wire [3:0] red_bot_pix, green_bot_pix, blue_bot_pix;

block_ram #(.RAM_WIDTH(PIXEL_BITS), .RAM_ADDR_BITS(11)) framebuf_top (
        .clk(clk), .w_en(ram_w_en_top),
        .r_addr(ram_r_addr), .w_addr(ram_w_addr),
        .in(ram_in), .out(ram_out_top)
    );

block_ram #(.RAM_WIDTH(PIXEL_BITS), .RAM_ADDR_BITS(11)) framebuf_bot (
        .clk(clk), .w_en(ram_w_en_bot),
        .r_addr(ram_r_addr), .w_addr(ram_w_addr),
        .in(ram_in), .out(ram_out_bot)
    );
    
always @(posedge clk) begin
    // Host handling
    
    // Always latech the input
    ram_in <= pixel_in;
    ram_w_addr <= write_addr[10:0];

    // Latch the write bits based on the address offset
    if (w_en) begin
        ram_w_en_top <= ~write_addr[11];
        ram_w_en_bot <= write_addr[11];
    end
    else begin
        ram_w_en_bot <= 0;
        ram_w_en_bot <= 0;
    end
    
    latch <= 1'b0;
    ram_r_addr <= {row_count, shift_count};

    if (state_reg == shifting) begin
        if (s_clk == 1'b1) begin
            s_clk <= 1'b0;
            s_r_t <= red_top_bit;
            s_g_t <= green_top_bit;
            s_b_t <= blue_top_bit;

            s_r_b <= red_bot_bit;
            s_g_b <= green_bot_bit;
            s_b_b <= blue_bot_bit;

            shift_count <= shift_count + 1;
        end
        else begin
            s_clk <= 1'b1;

            if (shift_count == 0) begin
                state_reg <= latching;
            end
        end
    end
    else if (state_reg == latching) begin
        latch <= 1'b1;
        bcm_count <= bcm_count + 1;
        state_reg <= shifting;
        shift_count <= 1;
        s_clk <= 1'b1;
        if (bcm_count == 15) begin
            noe <= 1'b1;
            row_count <= row_count + 1;
            ram_r_addr <= {row_count + 1, 7'h0};
        end
        else begin
            noe <= 1'b0;
            ram_r_addr <= {row_count, 7'h0};
        end
    end 
end

wire [2:0] bit_pick;

assign bit_pick = (bcm_count < 1) ? 2'h0 :
                  (bcm_count < 3) ? 2'h1 :
                  (bcm_count < 7) ? 2'h2 :
                  2'h3;

assign red_top_pix = ram_out_top[3:0];
assign green_top_pix = ram_out_top[7:4];
assign blue_top_pix = ram_out_top[11:8];

assign red_bot_pix = ram_out_bot[3:0];
assign green_bot_pix = ram_out_bot[7:4];
assign blue_bot_pix = ram_out_bot[11:8];

assign red_top_bit = red_top_pix[bit_pick];
assign green_top_bit = green_top_pix[bit_pick];
assign blue_top_bit = blue_top_pix[bit_pick];

assign red_bot_bit = red_bot_pix[bit_pick];
assign green_bot_bit = green_bot_pix[bit_pick];
assign blue_bot_bit = blue_bot_pix[bit_pick];

assign mux = row_count;

endmodule

`timescale 1ns/1ps

module disp_ctl_tb;

reg clk;

wire [3:0] hub_mux;
wire hub_clk, hub_noe, hub_lat;
wire [5:0] s_out;

reg [11:0] disp_w_addr = 0;
reg disp_w_en = 0;
reg [11:0] disp_pix_in = 0;

display_controller disp_controller (
        .clk(clk), .write_addr(disp_w_addr),
        .w_en(disp_w_en), .pixel_in(disp_pix_in),
        .s_clk(hub_clk), .mux(), .noe(),
        .s_r_t(s_out[0]), .s_g_t(s_out[1]), .s_b_t(s_out[2]),
        .s_r_b(s_out[3]), .s_g_b(s_out[4]), .s_b_b(s_out[5]),
        .latch(hub_lat)
    );

initial clk = 1'b0;
always clk  = #(1.0e9 / 25_000_000.0 / 2.0) ~clk;

initial begin
    $dumpfile("disp_ctl_dump.vcd");
    $dumpvars();

    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);
    repeat(129) @(posedge clk);

    $display("SIMULATION COMPLETE");

    $finish;
end

endmodule

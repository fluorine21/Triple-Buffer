//Top level diagram of the frame buffer
//Copyright (C) <2018>  <James Williams>

////This program is free software: you can redistribute it and/or modify
////it under the terms of the GNU General Public License as published by
////Free Software Foundation, either version 3 of the License, or
////(at your option) any later version.

////This program is distributed in the hope that it will be useful,
////but WITHOUT ANY WARRANTY; without even the implied warranty of
////MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
////GNU General Public License for more details.

////You should have received a copy of the GNU General Public License
////along with this program.  If not, see <https://www.gnu.org/licenses/>.


module TripleBuffer
(
	//Raw 50MHz clk
	input wire clk_in_raw,
	input wire button_reset,
	input wire button_resend,
	
	//Camera inputs
	input wire camera_pclk,
	input wire camera_vsync,
	input wire camera_href,
	input wire [7:0] camera_data,
	
	//SRAM Outputs
	output wire [19:0] sram_x_addr,
	output wire sram_x_we_n,
	output wire sram_x_oe_n,
	output wire sram_x_ce_a_n,
	output wire sram_x_ub_a_n,
	output wire sram_x_lb_a_n,
	inout wire [15:0] sram_x_data_io,
	
	output wire [15:0] sram_y_addr,
	output wire sram_y_we_n,
	output wire sram_y_oe_n,
	output wire sram_y_ce_a_n,
	output wire sram_y_ub_a_n,
	output wire sram_y_lb_a_n,
	inout wire [15:0] sram_y_data_io,

	output wire [15:0] sram_z_addr,
	output wire sram_z_we_n,
	output wire sram_z_oe_n,
	output wire sram_z_ce_a_n,
	output wire sram_z_ub_a_n,
	output wire sram_z_lb_a_n,
	inout wire [15:0] sram_z_data_io,
	
	//Camera Outputs
	output wire led_config_finished,
	output wire camera_sioc,
	output wire camera_siod,
	output wire camera_reset,
	output wire camera_pwdn,
	output wire camera_xclk,
	
	//VGA Outputs
	output wire [7:0] VGA_B,
	output wire [7:0] VGA_G,
	output wire [7:0] VGA_R,
	output wire VGA_clkout,
	output wire VGA_Hsync,
	output wire VGA_Vsync,
	output wire VGA_Nblank,
	output wire VGA_Nsync
	
);


//Internal Signals
wire clk_25;
wire clk_150;
wire clk_50kHz;

//Main system clock
wire clk_in;

wire [16:0] pixel_buff_addr;
wire [11:0] pixel_buff_data;
wire pixel_buf_we;

wire [2:0] mux_select;

wire [15:0] addr_a;
wire [15:0] data_a;
wire start_a;
wire rw_a;

wire [15:0] addr_b;
wire [15:0] data_b;
wire start_b;
wire rw_b;

wire [15:0] addr_x;
wire [15:0] data_x;
wire start_x;
wire rw_x;

wire [15:0] addr_y;
wire [15:0] data_y;
wire start_y;
wire rw_y;

wire [15:0] addr_z;
wire [15:0] data_z;
wire start_z;
wire rw_z;

wire [15:0] sram_x_addr_wire;

wire [15:0] data_x_out;
wire [15:0] data_y_out;
wire [15:0] data_z_out;
wire [15:0] sram_data_out;

wire not_reset = !button_resend;

wire [16:0] vga_addr;
wire [11:0] vga_data;
wire activeArea;


wire ready_x;
wire ready_y;
wire ready_z;
wire ready_c;
wire ready_t;

wire camera_reset_t;


//Assign statements
assign sram_x_addr[15:0] = sram_x_addr_wire;
assign sram_x_addr[19:16] = 4'b0;
assign camera_reset = camera_reset_t & button_reset;

//Main clock selection
assign clk_in = clk_in_raw;


//Modules

ov7670_capture pixel_buf
(
	//Inputs
	.pclk(camera_pclk),
	.vsync(camera_vsync),
	.href(camera_href),
	.d(camera_data),
	
	//Outputs
	.addr(pixel_buff_addr),
	.dout(pixel_buff_data),
	.we(pixel_buf_we)
);


capture_buff cb
(
	//Inputs
	.clk(clk_in),
	.reset(button_reset),
	.ready(ready_c),
	.addr_in(pixel_buff_addr),
	.data_in(pixel_buff_data),
	.WE(pixel_buf_we),
	
	//Outputs
	.addr_out(addr_a),
	.data_out(data_a),
	.start(start_a),
	.rw(rw_a)
);

tr_buff tb
(
	//Inputs
	.clk(clk_in),
	.reset(button_reset),
	.ready(ready_t),
	.addr_in(vga_addr),
	.sram_data(sram_data_out),
	
	//Outputs
	.sram_addr(addr_b),
	.dummy_data(data_b),
	.start(start_b),
	.rw(rw_b),
	.data_out(vga_data)
);

tri_mem_mux mem_mux
(
	//Inputs
	.addr_a(addr_a),
	.data_a(data_a),
	.start_a(start_a),
	.rw_a(rw_a),
	
	.addr_b(addr_b),
	.data_b(data_b),
	.start_b(start_b),
	.rw_b(rw_b),
	.select(mux_select),
	
	//Outputs
	.addr_x(addr_x),
	.data_x(data_x),
	.start_x(start_x),
	.rw_x(rw_x),
	
	.addr_y(addr_y),
	.data_y(data_y),
	.start_y(start_y),
	.rw_y(rw_y),
	
	.addr_z(addr_z),
	.data_z(data_z),
	.start_z(start_z),
	.rw_z(rw_z)
	
);


sram_ctrl sc_x
(
	//Inputs
	.clk(clk_in),
	.reset_n(button_reset),
	.addr_in(addr_x),
	.data_write(data_x),
	.start_n(start_x),
	.rw(rw_x),
	
	//Outputs
	.ready(ready_x),
	.data_read(data_x_out),
	.sram_addr(sram_x_addr_wire),
	.we_n(sram_x_we_n),
	.oe_n(sram_x_oe_n),
	.ce_a_n(sram_x_ce_a_n),
	.ub_a_n(sram_x_ub_a_n),
	.lb_a_n(sram_x_lb_a_n),
	.data_io(sram_x_data_io)
);

sram_ctrl sc_y
(
	//Inputs
	.clk(clk_in),
	.reset_n(button_reset),
	.addr_in(addr_y),
	.data_write(data_y),
	.start_n(start_y),
	.rw(rw_y),
	
	//Outputs
	.ready(ready_y),
	.data_read(data_y_out),
	.sram_addr(sram_y_addr),
	.we_n(sram_y_we_n),
	.oe_n(sram_y_oe_n),
	.ce_a_n(sram_y_ce_a_n),
	.ub_a_n(sram_y_ub_a_n),
	.lb_a_n(sram_y_lb_a_n),
	.data_io(sram_y_data_io)
);

sram_ctrl sc_z
(
	//Inputs
	.clk(clk_in),
	.reset_n(button_reset),
	.addr_in(addr_z),
	.data_write(data_z),
	.start_n(start_z),
	.rw(rw_z),
	
	//Outputs
	.ready(ready_z),
	.data_read(data_z_out),
	.sram_addr(sram_z_addr),
	.we_n(sram_z_we_n),
	.oe_n(sram_z_oe_n),
	.ce_a_n(sram_z_ce_a_n),
	.ub_a_n(sram_z_ub_a_n),
	.lb_a_n(sram_z_lb_a_n),
	.data_io(sram_z_data_io)
);

tri_data_mux tdm
(
	//Inputs
	.data_x(data_x_out),
	.data_y(data_y_out),
	.data_z(data_z_out),
	.select(mux_select),
	
	//Outputs
	.data_t(sram_data_out)
);

tri_ready_mux trm
(
	//Inputs
	.ready_x(ready_x),
	.ready_y(ready_y),
	.ready_z(ready_z),
	.select(mux_select),
	
	//Outputs
	.ready_a(ready_c),
	.ready_b(ready_t)
);

tri_control tc
(
	//Inputs
	.clk(clk_in),
	.reset(button_reset),
	.capture_trigger(camera_vsync),
	.transmission_trigger(VGA_Vsync),
	
	//Outputs
	.sram_select(mux_select)
);


Address_Generator ag
(
	//Inputs
	.CLK25(clk_25),
	.enable(activeArea),
	.vsync(VGA_Vsync),
	
	//outputs
	.address(vga_addr)
);

RGB rgb
(
	//Inputs
	.Din(vga_data),
	.Nblank(activeArea),
	
	//Outputs
	.R(VGA_R),
	.G(VGA_G),
	.B(VGA_B)
);

VGA vga
(
	//Inputs
	.CLK25(clk_25),
	
	//Outputs
	.clkout(VGA_clkout),
	.Hsync(VGA_Hsync),
	.Vsync(VGA_Vsync),
	.Nblank(VGA_Nblank),
	.activeArea(activeArea),
	.Nsync(VGA_Nsync)
);

//////////////////////////
//Clocks//////////////////
//////////////////////////

//Uncomment this section if you need to use SignalTap

//pll150 pll
//(
//	//Inputs
//	.inclk0(clk_in),
//	
//	//Outputs
//	.c0(clk_150)
//);

kHz_50 k50
(
	.clk_in(clk_in),
	.reset(button_reset),
	.clk_out(clk_50kHz)
);

MHz_25 m25
(
	//Inputs
	.clk_in(clk_in),
	.reset(button_reset),
	
	//Outputs
	.clk_out(clk_25)
);

//MHz_1 m1
//(
//	.clk_in(clk_in_raw),
//	.reset(button_reset),
//	
//	.clk_out(clk_in)
//
//);



ov7670_controller ovctrl
(
	//Inputs
	.clk(clk_25),
	.resend(not_reset),
	
	//Outputs
	.config_finished(led_config_finished),
	.sioc(camera_sioc),
	.siod(camera_siod),
	.reset(camera_reset_t),
	.pwdn(camera_pwdn),
	.xclk(camera_xclk)
);


endmodule


//This is the main test bench for the top level diagram
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



`timescale 1 ns / 1 ns

module test_bench();

//Local counters
reg [5:0] i;

//Clock and Reset Inputs
reg clk_in_in;
reg reset_in;

//Camera Inputs
reg camera_pclk_in;
reg camera_vsync_in;
reg camera_href_in;
reg [7:0] camera_data_in;

//SRAM data inputs
reg [15:0] sram_x_data_reg;
reg [15:0] sram_y_data_reg;
reg [15:0] sram_z_data_reg;

//Internal Wires
wire [19:0] sram_x_addr_wire;
wire sram_x_we_wire;
wire sram_x_oe_wire;
wire sram_x_ce_wire;
wire sram_x_ub_wire;
wire sram_x_lb_wire;
wire [15:0] sram_x_data_wire;

wire [15:0] sram_y_addr_wire;
wire sram_y_we_wire;
wire sram_y_oe_wire;
wire sram_y_ce_wire;
wire sram_y_ub_wire;
wire sram_y_lb_wire;
wire [15:0] sram_y_data_wire;

wire [15:0] sram_z_addr_wire;
wire sram_z_we_wire;
wire sram_z_oe_wire;
wire sram_z_ce_wire;
wire sram_z_ub_wire;
wire sram_z_lb_wire;
wire [15:0] sram_z_data_wire;

//Outputs
wire led_config_finished_out;
wire camera_sioc_out;
wire camera_siod_out;
wire camera_reset_out;
wire camera_pwdn_out;
wire camera_xclk_out;

wire [7:0] VGA_B_out;
wire [7:0] VGA_G_out;
wire [7:0] VGA_R_out;
wire VGA_clkout_out;
wire VGA_Hsync_out;
wire VGA_Vsync_out;
wire VGA_Nblank_out;
wire VGA_Nsync_out;

//Instantiation of top level design

TripleBuffer DUT
(
	.clk_in_raw(clk_in_in),
	.button_reset(reset_in),
	
	//Camera Inputs
	.camera_pclk(camera_pclk_in),
	.camera_vsync(camera_vsync_in),
	.camera_href(camera_href_in),
	.camera_data(camera_data_in),
	
	//SRAM Connections
	.sram_x_addr(sram_x_addr_wire),
	.sram_x_we_n(sram_x_we_wire),
	.sram_x_oe_n(sram_x_oe_wire),
	.sram_x_ce_a_n(sram_x_ce_wire),
	.sram_x_ub_a_n(sram_x_ub_wire),
	.sram_x_lb_a_n(sram_x_lb_wire),
	.sram_x_data_io(sram_x_data_wire),
	
	.sram_y_addr(sram_y_addr_wire),
	.sram_y_we_n(sram_y_we_wire),
	.sram_y_oe_n(sram_y_oe_wire),
	.sram_y_ce_a_n(sram_y_ce_wire),
	.sram_y_ub_a_n(sram_y_ub_wire),
	.sram_y_lb_a_n(sram_y_lb_wire),
	.sram_y_data_io(sram_y_data_wire),

	.sram_z_addr(sram_z_addr_wire),
	.sram_z_we_n(sram_z_we_wire),
	.sram_z_oe_n(sram_z_oe_wire),
	.sram_z_ce_a_n(sram_z_ce_wire),
	.sram_z_ub_a_n(sram_z_ub_wire),
	.sram_z_lb_a_n(sram_z_lb_wire),
	.sram_z_data_io(sram_z_data_wire),
	
	//Outputs
	.led_config_finished(led_config_finished_out),
	.camera_sioc(camera_sioc_out),
	.camera_siod(camera_siod_out),
	.camera_reset(camera_reset_out),
	.camera_pwdn(camera_pwdn_out),
	.camera_xclk(camera_xclk_out),
	
	.VGA_B(VGA_B_out),
	.VGA_G(VGA_G_out),
	.VGA_R(VGA_R_out),
	.VGA_clkout(VGA_clkout_out),
	.VGA_Hsync(VGA_Hsync_out),
	.VGA_Vsync(VGA_Vsync_out),
	.VGA_Nblank(VGA_Nblank_out),
	.VGA_Nsync(VGA_Nsync_out)

);

//Assign statements for the SRAM data
assign sram_x_data_wire = (!sram_x_oe_wire) ? sram_x_data_reg : 16'bz;
assign sram_y_data_wire = (!sram_y_oe_wire) ? sram_y_data_reg : 16'bz;
assign sram_z_data_wire = (!sram_z_oe_wire) ? sram_z_data_reg : 16'bz;

initial begin

	i = 0;
	clk_in_in = 1'b0;
	reset_in = 1'b0;
	
	camera_pclk_in = 1'b0;
	camera_vsync_in = 1'b1;
	camera_href_in = 1'b0;
	camera_data_in = 8'b0;
	
	
	test();

end

task test();
begin

	pixel_test();

end
endtask

task reset();
begin
	
	//Put reset low
	reset_in = 1'b0;
	
	//Cycle the clock
	clk();
	
	//Put reset high
	reset_in = 1'b1;

end
endtask

task clk();
begin

repeat(8) #10 clk_in_in = ~clk_in_in;

end
endtask

task clk_and_pclk();
begin

	for(i = 0; i < 10; i = i + 1)
	begin
		clk_in_in = ~clk_in_in;
		if(i%2 == 0)begin
			camera_pclk_in = ~camera_pclk_in;
		end
		#10;
	end

end
endtask


task pixel_test();
begin

	//Reset everything
	reset();

	//set the camera inputs up
	camera_data_in = 8'hAA;
	camera_href_in = 1'b1;
	camera_vsync_in = 1'b0;
	
	//set up buffers x, y, and z
	sram_x_data_reg = 16'hAAAA;
	sram_y_data_reg = 16'hBBBB;
	sram_z_data_reg = 16'hCCCC;
	
	//Clock the system until VGA vsync goes high
	while(VGA_Vsync_out == 1'b0)
	begin
		repeat(5) clk_and_pclk();
		camera_href_in = 1'b0;
		clk_and_pclk();
		camera_href_in = 1'b1;
	end
	
	//Clock the system until VGA vsync goes low
	while(VGA_Vsync_out == 1'b1)
	begin
		repeat(5) clk_and_pclk();
		camera_href_in = 1'b0;
		clk_and_pclk();
		camera_href_in = 1'b1;
	end
	
	//Once VGA vsync is low, tell the camera to get out of the way
	camera_vsync_in = 1'b1;
	clk();
	camera_vsync_in = 1'b0;
	clk();
	
	//Clock the system until VGA vsync goes high
	while(VGA_Vsync_out == 1'b0)
	begin
		repeat(5) clk_and_pclk();
		camera_href_in = 1'b0;
		clk_and_pclk();
		camera_href_in = 1'b1;
	end
	
	//Clock the system until VGA vsync goes low
	while(VGA_Vsync_out == 1'b1)
	begin
		repeat(5) clk_and_pclk();
		camera_href_in = 1'b0;
		clk_and_pclk();
		camera_href_in = 1'b1;
	end

	
	//Clock the system until VGA vsync goes high
	while(VGA_Vsync_out == 1'b0)
	begin
		repeat(5) clk_and_pclk();
		camera_href_in = 1'b0;
		clk_and_pclk();
		camera_href_in = 1'b1;
	end

	//Once VGA vsync is low, tell the camera to get out of the way
	camera_vsync_in = 1'b1;
	clk();
	camera_vsync_in = 1'b0;
	clk();
	
	//Clock the system until VGA vsync goes low
	while(VGA_Vsync_out == 1'b1)
	begin
		repeat(5) clk_and_pclk();
		camera_href_in = 1'b0;
		clk_and_pclk();
		camera_href_in = 1'b1;
	end
	

end
endtask





endmodule

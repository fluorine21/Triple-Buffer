//Copyright (C) <2018>  <James Williams>

////This program is free software: you can redistribute it and/or modify
////it under the terms of the GNU General Public License as published by
////Free Software Foundation, either version 3 of the License, or
////(at your option) any later version.

////This program is distributed in the hope that it will be useful,
////but WITHOUT ANY WARRANTY; without even the implied warranty of
////MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
////GNU General Public License for more details.

 ///You should have received a copy of the GNU General Public License
////along with this program.  If not, see <https://www.gnu.org/licenses/>.
//uart top level test bench
//Input clock is 40MHz

`timescale 1 ns / 1 ns

module uart_top_level_tb();

wire uart_in;
wire uart_out;

wire [15:0] d0_addr;
wire d0_we;
wire d0_oe;
wire [15:0] d0_data_io;

wire [15:0] d1_addr;
wire d1_we;
wire d1_oe;
wire [15:0] d1_data_io;

wire [15:0] d2_addr;
wire d2_we;
wire d2_oe;
wire [15:0] d2_data_io;

//Clock registers
reg clk_in;
reg clk_10;
reg reset_reg;
reg tx_flow_control_reg;

uart_top_level dut(

//Raw 50MHz clk
	.clk_in(clk_in),
	.clk_in_10(clk_10),
	.button_reset(reset_reg),
	
	//UART Inputs
	.uart_in(uart_in),
	.tx_flow_control(tx_flow_control_reg),
	
	//UART Outputs
	.uart_out(uart_out),
	
	//SRAM Outputs
	.sram_x_addr(d0_addr),
	.sram_x_we_n(d0_we),
	.sram_x_oe_n(d0_oe),
	.sram_x_ce_a_n(),
	.sram_x_ub_a_n(),
	.sram_x_lb_a_n(),
	.sram_x_data_io(d0_data_io),
	
	.sram_y_addr(d1_addr),
	.sram_y_we_n(d1_we),
	.sram_y_oe_n(d1_oe),
	.sram_y_ce_a_n(),
	.sram_y_ub_a_n(),
	.sram_y_lb_a_n(),
	.sram_y_data_io(d1_data_io),

	.sram_z_addr(d2_addr),
	.sram_z_we_n(d2_we),
	.sram_z_oe_n(d2_oe),
	.sram_z_ce_a_n(),
	.sram_z_ub_a_n(),
	.sram_z_lb_a_n(),
	.sram_z_data_io(d2_data_io)
);

//Dummy memory declarations
d_mem d0(
	.reset(reset_reg),
	.oe(d0_oe),
	.we(d0_we),
	.addr(d0_addr),
	.data_io(d0_data_io)
);

d_mem d1(
	.reset(reset_reg),
	.oe(d1_oe),
	.we(d1_we),
	.addr(d1_addr),
	.data_io(d1_data_io)
);

d_mem d2(
	.reset(reset_reg),
	.oe(d2_oe),
	.we(d2_we),
	.addr(d2_addr),
	.data_io(d2_data_io)
);

//External transmitter for creating a test input

reg [15:0] dummy_data;
wire uart_in_done;
wire uart_in_active;
uart_tx#(87) utx
(
   .i_Clock(clk_10),
   .i_Tx_DV(1'b1),
   .i_Tx_Byte(dummy_data[7:0]), 
   .o_Tx_Active(uart_in_active),
   .o_Tx_Serial(uart_in),
   .o_Tx_Done(uart_in_done)
);

reg [7:0] count;

//External reciever for getting bytes out of the system

wire [11:0] data_out;
uart_rx #(10) urx
(
   .i_Clock(clk_10),
   .i_Rx_Serial(uart_out),
   .o_Rx_DV(),
   .o_Rx_Byte(data_out)
);

reg tx_wait;

initial begin
	tx_wait <= 0;
	dummy_data <= 0;
	count <= 0;
	reset_reg = 1'b1;
	//Reset everything
	//reset_reg = 1'b0;
	tx_flow_control_reg = 1'b0;

	repeat(10) clk_cycle();

	

	//Test loop
	while(1) begin
		if(count > 10000)begin
			tx_flow_control_reg = 1'b1;
		end
		else begin
			tx_flow_control_reg = 1'b0;
		end
		clk_cycle();
		count = count + 1;
		if(uart_in_done && tx_wait == 0) begin
			dummy_data <= dummy_data + 1;
			tx_wait <= 1'b1;
		end
		if(tx_wait == 1 && uart_in_done == 0) begin
			tx_wait <= 0;
		end
	end
	
end

task clk_cycle();
begin
	
	#10 clk_10 = 1'b1;
	clk_in = 1'b1;
	
	#10 clk_in = 1'b0;
	
	#10 clk_in = 1'b1;
	
	#10 clk_in = 1'b0;
	
	#10 clk_10 = 1'b0;
	
	clk_in = 1'b1;
	
	
	#10 clk_in = 1'b0;
	
	#10 clk_in = 1'b1;
	
	#10 clk_in = 1'b0;
	 

end
endtask


endmodule
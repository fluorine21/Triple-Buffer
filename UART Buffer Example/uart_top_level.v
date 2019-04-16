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
//Top level design


module uart_top_level(

//Raw 50MHz clk
	input wire clk_in,
	input wire clk_in_10,
	input wire button_reset,
	
	//UART Inputs
	input wire uart_in,
	input wire tx_flow_control,
	
	//UART Outputs
	output wire uart_out,
	
	//SRAM Outputs
	output wire [15:0] sram_x_addr,
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
	inout wire [15:0] sram_z_data_io
);



wire [2:0] mux_select;

//A group is the reciever
wire [15:0] addr_a;
wire [15:0] data_a;
wire start_a;
wire rw_a;

//B group is the sender
wire [15:0] addr_b;
wire [15:0] data_b;
wire start_b;
wire rw_b;

//Wires for SRAM controllers
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

wire [15:0] data_x_out;
wire [15:0] data_y_out;
wire [15:0] data_z_out;
wire [15:0] sram_data_out;


wire ready_x;
wire ready_y;
wire ready_z;
wire ready_a; //For UART sender
wire ready_b; //For UART reciever


//Buffer declarations

//Used to determine when to change buffers
wire r_switch; 
wire t_switch;

tri_control #(1, 1) tc
(
	//Inputs
	.clk(clk_in),
	.reset(button_reset),
	.capture_trigger(r_switch),
	.transmission_trigger(t_switch),
	
	//Outputs
	.sram_select(mux_select)
);


tri_mem_mux mem_mux
(
	//Inputs
	.addr_a(addr_a),
	.data_a(data_a),
	.start_a(start_a),//start is active low
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

tri_ready_mux trm
(
	//Inputs
	.ready_x(ready_x),
	.ready_y(ready_y),
	.ready_z(ready_z),
	.select(mux_select),
	
	//Outputs
	.ready_a(ready_a),
	.ready_b(ready_b)
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
	.sram_addr(sram_x_addr),
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

/////////////////////
//UART Declarations//
/////////////////////


uart_rx_controller #(87) urxc
(
	.clk(clk_in),
	.clk_10(clk_in_10),
	.rst(button_reset),
	.uart_in(uart_in),
	.sram_ready(ready_a),
	.switch(r_switch),
	.sram_addr(addr_a),
	.sram_data(data_a),
	.sram_rw(rw_a),
	.sram_start(start_a)
);



uart_tx_controller #(10) utxc
(
	.clk(clk_in),
	.clk_10(clk_in_10),
	.reset(button_reset),
	.flow_control(tx_flow_control),
	.uart_data(sram_data_out),
	.uart_tx_out(uart_out),
	.sram_addr(addr_b),
	.sram_start(start_b),
	.sram_ready(ready_b),
	.sram_rw(rw_b),
	.swap(t_switch)
	
);

endmodule


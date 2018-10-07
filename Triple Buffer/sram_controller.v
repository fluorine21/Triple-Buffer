//SRAM controller

//Origionally from Sawn Gerber
//https://drive.google.com/file/d/0ByZh57epHwSddk1ldklEaDZMRjg/edit

/*  SRAM CONTOLLER v2.0
**************************************************************** 
Summary:  a low level driver to fascillitate interaction
between an SRAM device and other peripherals.

by Shawn Gerber 
Aug 13, 2012

modifications:  Aug 16, 2012
Extended the "on" time for the tri-state buffer during a write.
****************************************************************/

module sram_ctrl
(
//inputs
input wire clk , reset_n ,
input wire [15:0] addr_in,
input wire [15:0] data_write,
input wire start_n, rw,

//outputs
output reg ready,
output wire [15:0] data_read ,
output wire [15:0] sram_addr ,
output wire we_n, oe_n,
output wire ce_a_n , ub_a_n, lb_a_n,
//inout
inout wire [15:0] data_io
);

//states
localparam [1:0]  state_idle  = 3'b00,
						state_read  = 3'b01,
						state_write = 3'b10;
						
reg [2:0]   state_reg, state_next;
reg [15:0]  data_write_reg,   data_write_next;
reg [15:0]  data_read_reg, data_read_next;
reg [15:0]  addr_reg, addr_next;
reg we_next, oe_next, tri_next;
reg we_reg, oe_reg, tri_reg;

always@(posedge clk, negedge reset_n)
if(!reset_n)
	begin
		state_reg <= state_idle;
		addr_reg <= 0;
		data_write_reg <= 0;
		data_read_reg <= 0;
		we_reg <= 1'b1;
		oe_reg <= 1'b1;
		tri_reg <= 1'b1;
	end
else
	begin
		state_reg <= state_next;
		addr_reg  <= addr_next;
		data_write_reg <= data_write_next;
		data_read_reg <= data_read_next;
		we_reg <= we_next;
		oe_reg <= oe_next;
		tri_reg <= tri_next;
	end
		
//next state values and outputs
always@*
begin
	//default values
	addr_next = addr_reg;
	data_write_next = data_write_reg;
	data_read_next = data_read_reg;
	ready = 1'b0;
	oe_next = 1'b1;
	we_next = 1'b1;
	tri_next = 1'b1;
	//state machine
case(state_reg)		
	state_idle:
	begin
		ready = 1'b1;
		oe_next = 1'b1;
		if(start_n)  						
			state_next = state_reg;
		else//start is active
			begin
			  addr_next = addr_in;
			  if(rw == 1)
				begin
					state_next = state_read;  //BEGIN READ PROCESS
					oe_next = 1'b0;   
				end	
			  else
			   begin  								
					state_next = state_write;	// BEGIN WRITE PROCESS
					data_write_next = data_write;
					we_next = 1'b0;
					tri_next = 1'b0;
				end
			end
	end
	state_read:
		begin
			state_next = state_idle;
			data_read_next = data_io;
			oe_next = 1'b1;
		end
	state_write:
		begin
			state_next = state_idle;
			tri_next = 1'b0;
		end
	default: 
		state_next = state_idle;
endcase
end

//outputs
assign ce_a_n = 1'b0; 
assign ub_a_n = 1'b0;
assign lb_a_n = 1'b0;
assign oe_n = oe_reg;
assign we_n = we_reg;
assign sram_addr = addr_reg;
assign data_read = data_read_reg;

assign data_io =  (!tri_reg) ? data_write_reg : 16'bz;
endmodule



//Small module for addressing the 20 address lines of the DE2-115 on-board SRAM
module up_conv 
#(
parameter addr_bus_size = 16,
parameter data_bus_size = 16
)
(
input [(data_bus_size - 1):0] in,
output [19:0] out
);

assign out[(data_bus_size - 1):0] = in;
assign out[19:16] = 4'b0;

endmodule




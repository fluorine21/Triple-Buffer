//Transmission Buffer
//Simple buffer for reading memory contense out to another module
//In this implementation, buffer reads out pixels to VGA controller

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

module tr_buff
#(
parameter addr_bus_size = 16,
parameter data_bus_size = 16
)
(
input clk,
input reset,
input ready,//From SRAM when data is ready
input [16:0] addr_in,//From VGA
input [(data_bus_size - 1):0] sram_data,
output [(addr_bus_size - 1):0] sram_addr,
output [(data_bus_size - 1):0] dummy_data,//For MUX
output reg start,
output rw,
output [11:0] data_out
);


reg [16:0] addr_in_old;
reg state;

//State defs
localparam state_start = 1'b0,
				state_wait = 1'b1;

initial begin
	start <= 1'b1;
	state <= state_start;
	addr_in_old <= 17'b11111111111111111;//Make sure we get triggered by the first addr
end

always @ (posedge clk or negedge reset) begin
	if(reset == 1'b0) begin//Reset State
		start <= 1'b1;
		state <= state_start;
		addr_in_old <= 17'b11111111111111111;
	end
	else begin
		case (state)
		
		//If we see a new address
			state_start: begin
				if(addr_in_old != addr_in && addr_in[16] != 1'b1) begin//VGA controller needs next pixel
					//Get the next pixel
					addr_in_old <= addr_in;
					start <= 1'b0;
					state <= state_wait;
				end
				
			end
			
			state_wait: begin
			//Wait until the data is there
				start <= 1'b1;
				if(ready == 1'b1) begin
					state <= state_start;
				end
			end

			default: begin
				state <= state_start;
			end
			
		endcase
	end

end

//sends vga controller black pixels if we're out of the address range
assign data_out = addr_in[16]? 12'b0 : sram_data[11:0];
assign sram_addr = addr_in[(addr_bus_size - 1):0];
assign dummy_data = 16'b0;
assign rw = 1'b1;//1 for read

endmodule

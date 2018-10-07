//Simple module for buffering incoming data (in this case pixels) to the SRAM
//Works by grabbing pixels when WE is active, and telling SRAM to read them 
//in to appropriate memory location

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


module capture_buff
#(
parameter addr_bus_size = 16,
parameter data_bus_size = 16
)
(
input wire clk,
input wire reset, //active low
input wire ready, //ready line from ready buffer
input [16:0] addr_in,
input [11:0] data_in,
input WE,
output [(addr_bus_size - 1):0] addr_out,
output [(data_bus_size - 1):0] data_out,
output reg start,
output rw,
output reg overflow //Detects if camera has overrun buffer (which it will if not prevented)
);

reg state;

localparam state_start = 1'b0,
				state_wait = 1'b1;
				
initial begin
	start <= 1'b1;
	state <= state_start;
	overflow <= 1'b0;
	//data_out <= 16'b0000000000000000;
end



always @ (posedge clk or negedge reset) begin
	if(reset == 1'b0) begin
		start <= 1'b1;
		state <= state_start;
		overflow <= 1'b0;
		//data_out <= 16'b0000000000000000;
	end
	else begin
		case (state)
		
			state_start: begin
				if(WE == 1'b1 && addr_in[16] == 1'b0) begin//This should prevent overflow
					start <= 1'b0;//start is active low
					state <= state_wait;
				end
				else if(addr_in[16] == 1'b1) begin//Overflow is occuring
					overflow <= 1'b1;
				end
			end
			
			state_wait: begin
				start <= 1'b1;
				if(ready == 1'b1 && WE == 1'b0) begin
					state <= state_start;
				end
			end
		
			default: begin
				state <= state_start;
			end
		
		endcase
	end


end

assign addr_out = addr_in[(addr_bus_size - 1):0];
assign data_out[11:0] = data_in;
assign data_out[15:12] = 4'b0000;
assign rw = 1'b0;

endmodule

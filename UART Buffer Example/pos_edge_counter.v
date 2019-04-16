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

//simple counter for incrementing the write address

module pos_edge_counter
#(
parameter width = 16
)
(
	input wire clk,
	input wire reset,
	output reg [width-1:0] count
);

initial begin
	count <= 0;
end


always @ (posedge clk or negedge reset) begin
	if(reset == 1'b0) begin
		count <= 0;
	end
	else begin
		count <= count + 1;
	end
end

endmodule
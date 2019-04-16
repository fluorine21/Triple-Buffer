//dummy memory
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


module d_mem(

input wire clk,
input wire reset,
input wire oe,
input wire we,
input wire [15:0] addr,
inout wire [15:0] data_io

);


reg [15:0] data_out;


reg [15:0] mem [0:65535];
reg [15:0] i;

initial begin

	data_out <= 16'b0;

	//for (i = 0; i < 65535; i = i +1) begin   	  	
		//mem[i] <= 8'b0;
  	//end

end

always @ (negedge we or negedge reset) begin

	if(reset == 1'b0) begin

		for (i = 0; i < 65535; i = i +1) begin   	  	
			mem[i] <= 8'b0;
		end
	
	end
	else begin //Gotta update memory
	
		mem[addr] <= data_io;
	
	
	end
	
end

always @ (negedge oe or negedge reset) begin
	
	if(reset == 1'b0) begin
		
		data_out <= 1'b0;
	
	end
	else begin//Pusing out 	
	
		data_out <= mem[addr];
	
	end
		
end

assign data_io =  (!oe) ? data_out : 16'bz;

endmodule

//Clock dividers
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


module MHz_25(
input wire clk_in,
input wire reset,
output reg clk_out
);

initial begin
	clk_out <= 1'b0;
end

always @ (posedge clk_in or negedge reset) begin
	if(reset == 1'b0) begin
		clk_out <= 1'b0;
	end
	else begin
		clk_out <= ~clk_out;
	end
end


endmodule


module kHz_50
(
	input wire clk_in,
	input wire reset,
	output reg clk_out
);

reg [31:0] count;

initial begin
	clk_out <= 1'b0;
	count <= 0;
end

always @ (posedge clk_in or negedge reset) begin
	if(reset == 1'b0) begin
	
	end
	else begin
		if(count < 500) begin
			count = count + 1'b1;
		end
		else begin
			count <= 1'b0;
			clk_out = ~clk_out;
		end
	end
end


endmodule

module MHz_1
(
	input wire clk_in,
	input wire reset,
	output reg clk_out
);

reg [31:0] count;

initial begin
	clk_out <= 1'b0;
	count <= 0;
end

always @ (posedge clk_in or negedge reset) begin
	if(reset == 1'b0) begin
	
	end
	else begin
		if(count < 25) begin
			count = count + 1'b1;
		end
		else begin
			count <= 1'b0;
			clk_out = ~clk_out;
		end
	end
end


endmodule

module Hz_5(
input wire clk_in,
input wire reset,
output reg clk_out
);
reg [31:0] count;

initial begin
	clk_out <= 1'b0;
	count <= 0;
end

always @ (posedge clk_in or negedge reset) begin
	if(reset == 1'b0) begin
	
	end
	else begin
		if(count < 5000000) begin
			count = count + 1'b1;
		end
		else begin
			count <= 1'b0;
			clk_out = ~clk_out;
		end
	end
end


endmodule


module notBlock(
input wire in,
output out
);

assign out = !in;

endmodule


module andBlock(
input wire a,
input wire b,
output out
);

assign out = a & b;

endmodule

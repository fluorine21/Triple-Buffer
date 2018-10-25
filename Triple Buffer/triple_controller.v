//Triple buffer controller
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

//Main Controller

module tri_control
#(
parameter wait_cycles = 0
)
(
input wire clk,//Input clock
input wire reset,//Reset line (active low)
input wire capture_trigger,//Incoming data trigger (active low)
input wire transmission_trigger,//Outgoing data trigger (active high)
output reg [2:0] sram_select,//Buffer selection line
output reg error //Used to detect when an invalid buffer selection state has occured
);

//Internal selection signal buffered for stability
wire [2:0] sram_int_select;

localparam [1:0] state_first_wait = 2'b00,//Wait for VSYNC to begin
			  state_switch = 2'b01,//Perform the buffer switch
			  state_second_wait = 2'b10;//Wait for VSYNC to end

//Buffer name definitions
localparam [1:0] X = 2'b00, 
					  Y = 2'b01,
					  Z = 2'b10;
					  
//Buffer selection states					  
localparam [2:0] A = 3'b000, //A->X : B->Y : D->Z
					  B = 3'b001, //A->X : B->Z : D->Y
					  C = 3'b010, //A->Y : B->x : D->Z
					  D = 3'b011, //A->Y : B->Z : D->X
					  E = 3'b100, //A->Z : B->X : D->Y
					  F = 3'b101; //A->Z : B->Y : D->X
					  
reg [1:0] camera_buff; //Keeps track of current incoming data buffer
reg [1:0] vga_buff; //Keeps track of current outgoing data buffer

//Buffer access couters
//These are incremented every time vga switches into them
//They are reset when the camera switches into them
reg [1:0] x_cnt;
reg [1:0] y_cnt;
reg [1:0] z_cnt;

//Holds the wrapper state machine states and wait times
reg [1:0] cap_state;
reg [1:0] trans_state;

reg [5:0] cap_count;
reg [5:0] trans_count;


			  
initial begin
	camera_buff <= X;
	vga_buff <= Y;
	sram_select <= A;
	error <= 1'b0;
	
	x_cnt <= 2'b0;
	y_cnt <= 2'b0;
	z_cnt <= 2'b0;
	
	cap_state = state_first_wait;
	trans_state = state_first_wait;
	
	cap_count = 0;
	trans_count = 0;

end

//State machine for the capture process
always @ (posedge clk) begin

	case(cap_state)
		
		state_first_wait: begin
			//If the capture trigger is active
			if(capture_trigger) begin
				if(cap_count >= wait_cycles) begin
					cap_count <= 0;
					cap_state <= state_switch;
				end
				else begin
					cap_count <= cap_count + 1'b1;
				end
			end
			//If not active, reset the counter
			else begin
				cap_count <= 0;
			end
		
		end
	
		state_switch: begin
			//Perform the buffer switch
			cap_switch();
			//Wait for the frame to start
			cap_state <= state_second_wait;
		end
		
		state_second_wait: begin
		//Once vsync deactivates
			if(!capture_trigger) begin
				cap_state <= state_first_wait;
			end
		end
		
		default: begin
			cap_state <= state_first_wait;
		end
		
	endcase
end


//State machine for the transmission process
always @ (posedge clk) begin

	case(trans_state)
		
		state_first_wait: begin
			//If the capture trigger is active
			if(!transmission_trigger) begin
				if(trans_count >= wait_cycles) begin
					trans_count <= 0;
					trans_state <= state_switch;
				end
				else begin
					trans_count <= trans_count + 1'b1;
				end
			end
			//If not active, reset the counter
			else begin
				trans_count <= 0;
			end
		
		end
	
		state_switch: begin
			//Perform the buffer switch
			trans_switch();
			//Wait for the frame to start
			trans_state <= state_second_wait;
		end
		
		state_second_wait: begin
		//Once vsync deactivates
			if(transmission_trigger) begin
				
				trans_state <= state_first_wait;
			end
		end
		
		default: begin
			trans_state <= state_first_wait;
		end
		
	endcase
end

//Advancing the capture buffer to the next state
task cap_switch;
begin

case(vga_buff) //Looking at which buffer is currently busy with VGA
		
			X: begin
				if(camera_buff == Y) begin
					camera_buff <= Z;
					z_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
				else begin
					camera_buff <= Y;
					y_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					z_cnt <= z_cnt + 1'b1;
				end
			end
			
			Y: begin
				if(camera_buff == Z) begin
					camera_buff <= X;
					x_cnt <= 2'b0;
					z_cnt <= z_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
				else begin
					camera_buff <= Z;
					z_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
			end
			
			Z: begin
				if(camera_buff == X) begin
					camera_buff <= Y;
					y_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					z_cnt <= z_cnt + 1'b1;
				end
				else begin
					camera_buff <= X;
					x_cnt <= 2'b0;
					z_cnt <= z_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
			end
			
			default begin
				camera_buff <= X;
				x_cnt <= 2'b0;
				z_cnt <= z_cnt + 1'b1;
				y_cnt <= y_cnt + 1'b1;
			end
			
		endcase

end
endtask

//Advancing the transmission buffer to the next state
task trans_switch;
begin

	case(camera_buff) //Looking at which buffer is currently busy with camera
	
		X: begin
			if(vga_buff == Y && z_cnt < 2) begin
				vga_buff <= Z;
			end
			else if(y_cnt < 2) begin
				vga_buff <= Y;
			end
		end
		
		Y: begin
			if(vga_buff == Z && x_cnt < 2) begin
				vga_buff <= X;
			end
			else if(z_cnt < 2) begin
				vga_buff <= Z;
			end
		end
		
		Z: begin
			if(vga_buff == X && y_cnt < 2) begin
				vga_buff <= Y;
			end
			else if(x_cnt < 2) begin
				vga_buff <= X;
			end
		end
		
		default begin
			vga_buff <= Y;
		end
		
	endcase

end
endtask


//Pushing the selection state out to the MUXes
always @ (posedge clk) begin

//If we're in an active state
	if(capture_trigger || !transmission_trigger) begin
		sram_select <= sram_int_select;
	end

end

assign sram_int_select = (camera_buff == X && vga_buff == Y)? A : 
							((camera_buff == X && vga_buff == Z) ? B :
							((camera_buff == Y && vga_buff == X) ? C :
							((camera_buff == Y && vga_buff == Z) ? D :
							((camera_buff == Z && vga_buff == X) ? E : F))));


endmodule



//A lesson in how NOT to build a buffer controler
//DO NOT USE


module tri_control_1(
input wire clk,//Input clock
input wire reset,//Reset line (active low)
input wire capture_trigger,//Incoming data trigger (active low)
input wire transmission_trigger,//Outgoing data trigger (active high)
output reg [2:0] sram_select,//Buffer selection line
output reg error //Used to detect when an invalid buffer selection state has occured
);

wire [2:0] sram_int_select;

//Buffer name definitions
localparam [1:0] X = 2'b00, 
					  Y = 2'b01,
					  Z = 2'b10;
					  
//Buffer selection states					  
localparam [2:0] A = 3'b000, //A->X : B->Y : D->Z
					  B = 3'b001, //A->X : B->Z : D->Y
					  C = 3'b010, //A->Y : B->x : D->Z
					  D = 3'b011, //A->Y : B->Z : D->X
					  E = 3'b100, //A->Z : B->X : D->Y
					  F = 3'b101; //A->Z : B->Y : D->X
					  
reg [1:0] camera_buff; //Keeps track of current incoming data buffer
reg [1:0] vga_buff; //Keeps track of current outgoing data buffer

//Buffer access couters
//These are incremented every time vga switches into them
//They are reset when the camera switches into them
reg [1:0] x_cnt;
reg [1:0] y_cnt;
reg [1:0] z_cnt;

reg cap_arm;
reg cap_fire;
reg trans_arm;
reg trans_fire;
			  
initial begin
	camera_buff <= X;
	vga_buff <= Y;
	sram_select <= A;
	error <= 1'b0;
	
	x_cnt <= 2'b0;
	y_cnt <= 2'b0;
	z_cnt <= 2'b0;

end
					  
always @ (posedge capture_trigger) begin 
	//if(reset == 1'b0) begin
	//	camera_buff <= X;
	//	x_cnt <= 2'b0;
	//	y_cnt <= 2'b0;
	//	z_cnt <= 2'b0;
	//end
	//else begin
	if(capture_trigger) begin
		case(vga_buff) //Looking at which buffer is currently busy with VGA
		
			X: begin
				if(camera_buff == Y) begin
					camera_buff <= Z;
					z_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
				else begin
					camera_buff <= Y;
					y_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					z_cnt <= z_cnt + 1'b1;
				end
			end
			
			Y: begin
				if(camera_buff == Z) begin
					camera_buff <= X;
					x_cnt <= 2'b0;
					z_cnt <= z_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
				else begin
					camera_buff <= Z;
					z_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
			end
			
			Z: begin
				if(camera_buff == X) begin
					camera_buff <= Y;
					y_cnt <= 2'b0;
					x_cnt <= x_cnt + 1'b1;
					z_cnt <= z_cnt + 1'b1;
				end
				else begin
					camera_buff <= X;
					x_cnt <= 2'b0;
					z_cnt <= z_cnt + 1'b1;
					y_cnt <= y_cnt + 1'b1;
				end
			end
			
			default begin
				camera_buff <= X;
				x_cnt <= 2'b0;
				z_cnt <= z_cnt + 1'b1;
				y_cnt <= y_cnt + 1'b1;
			end
			
		endcase
	end
	
	//end
end

always @ (negedge transmission_trigger) begin //Might need to modify this depending on active state of vsync
	//if(reset == 1'b0) begin
	//	vga_buff <= Y;
	//end
	
	//else begin
	if(!transmission_trigger) begin
		case(camera_buff) //Looking at which buffer is currently busy with camera
		
			X: begin
				if(vga_buff == Y && z_cnt < 2) begin
					vga_buff <= Z;
				end
				else if(y_cnt < 2) begin
					vga_buff <= Y;
				end
			end
			
			Y: begin
				if(vga_buff == Z && x_cnt < 2) begin
					vga_buff <= X;
				end
				else if(z_cnt < 2) begin
					vga_buff <= Z;
				end
			end
			
			Z: begin
				if(vga_buff == X && y_cnt < 2) begin
					vga_buff <= Y;
				end
				else if(x_cnt < 2) begin
					vga_buff <= X;
				end
			end
			
			default begin
				vga_buff <= Y;
			end
			
		endcase
	end

	
	
end



always @ (posedge clk) begin

//If we're in an active state
	if(capture_trigger || !transmission_trigger) begin
		sram_select <= sram_int_select;
	end

end

assign sram_int_select = (camera_buff == X && vga_buff == Y) ? A : 
						((camera_buff == X && vga_buff == Z) ? B :
						((camera_buff == Y && vga_buff == X) ? C :
						((camera_buff == Y && vga_buff == Z) ? D :
						((camera_buff == Z && vga_buff == X) ? E : F))));


endmodule


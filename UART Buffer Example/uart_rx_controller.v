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
//uart rx controller


module uart_rx_controller
#(
	parameter clk_per_bit = 87
)
(
	input wire clk,
	input wire clk_10,
	input wire rst,
	input wire uart_in,
	input wire sram_ready,
	output reg switch,
	output reg [15:0] sram_addr,
	output reg [15:0] sram_data,
	output wire sram_rw,
	output reg sram_start
);


wire uart_valid;
wire [7:0] uart_data;
reg [1:0] state;

//10MHz clock at 115200 baud
uart_rx #(clk_per_bit) urx
(
   .i_Clock(clk_10),
   .i_Rx_Serial(uart_in),
   .o_Rx_DV(uart_valid),
   .o_Rx_Byte(uart_data)
);

localparam state_get_byte = 2'b00,
		   state_wait_sram = 2'b01,
		   state_switch = 2'b10;
		   
initial begin
	state <= state_get_byte;
	sram_addr <= 0;
	sram_data <= 0;
	sram_start <= 1'b1;
	switch <= 1'b0;
end

always @ (posedge clk or negedge rst) begin
	if(rst == 1'b0) begin
		state <= state_get_byte;
		sram_addr <= 0;
		sram_data <= 0;
		sram_start <= 1'b1;
		switch <= 1'b0;
	end
	
	else begin
	
		case(state)
		
			state_get_byte: begin
				//Reset the switch signal 
				switch <= 1'b0;
				//If the UART data is valid
				if(uart_valid) begin
					//Set up the sram data
					sram_data[7:0] <= uart_data;
					//Tell the SRAM so start
					sram_start <= 1'b0;
					//Advance to next state
					state <= state_wait_sram;
				
				end
			
			end
			
			state_wait_sram: begin
				//Reset the sram start line
				sram_start <= 1'b1;
			
				//If UART data is no longer valid and sram is ready
				if(uart_valid == 0 && sram_ready) begin
					//If we're ready to switch
					if(sram_addr > 1000) begin
						//Set up the switch signal
						switch <= 1'b1;
						//Advance to the switch hold state
						state <= state_switch;
						sram_addr <= 0;
					end
					else begin
						//increment the address
						sram_addr = sram_addr + 1;
						//Advance back to start state 
						state <= state_get_byte;
					end
					
				
				end
			
			
			end
			
			state_switch: begin
				//Advance to the get byte state
				state <= state_get_byte;
			end
		
		endcase
	
	
	
	end

end

assign sram_rw = 1'b0;

endmodule
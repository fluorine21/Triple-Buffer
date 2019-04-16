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
//uart tx controller

module uart_tx_controller
#(
	parameter clk_per_bit = 87
)
(
	input wire clk,
	input wire clk_10,
	input wire reset,
	input wire flow_control,//When 1, module waits to read from sram 
	input wire [15:0] uart_data,
	output wire uart_tx_out,
	output reg [15:0] sram_addr,
	output reg sram_start,
	input wire sram_ready,
	output wire sram_rw,
	output reg swap
	
);

reg uart_start;
wire uart_active;
wire uart_done;

reg [1:0] state;

localparam state_get_byte = 2'b00,
		   state_run_uart = 2'b01,
		   state_wait_uart = 2'b10,
		   state_swap = 2'b11;

//tx module is much faster
uart_tx #(clk_per_bit) utx
(
   .i_Clock(clk_10),
   .i_Tx_DV(uart_start),
   .i_Tx_Byte(uart_data[7:0]), 
   .o_Tx_Active(uart_active),
   .o_Tx_Serial(uart_tx_out),
   .o_Tx_Done(uart_done)
);

initial begin

	state <= state_get_byte;
	sram_addr <= 0;
	swap <= 1'b0;
end


always @ (posedge clk or negedge reset) begin
	if(reset == 1'b0) begin
		state <= state_get_byte;
		sram_addr <= 0;
	end
	else begin
	
		case(state)
		
			state_get_byte: begin
				swap <= 1'b0;
				//If SRAM is ready and we don't need to wait
				if(sram_ready && !flow_control) begin
					//Read the next byte from sram
					sram_start <= 1'b0;
					//Advance to uart run state
					state <= state_run_uart;
				end
			end
			
			state_run_uart: begin
				//Reset SRAM start
				sram_start <= 1'b1;
				//If the uart controller is ready and sram is done
				if(uart_done && sram_ready) begin
					//Tell it to start with the next byte
					uart_start <= 1'b1;
					//Advance to next state
					state <= state_wait_uart;
				end
			
			end
			
			state_wait_uart: begin
				//If the UART has started and we're not overruning the buffer
				if(uart_active == 1'b1 && sram_addr < 1001) begin
					//Reset the start line
					uart_start <= 1'b0;
					//Increment the start address
					sram_addr <= sram_addr + 1;
					state <= state_get_byte;
				end
				else if(sram_addr > 1000) begin//Time to swap buffers
					uart_start <= 1'b0;
					sram_addr <= 0;//Reset the current address
					state <= state_swap;
					swap <= 1'b1;
				end
			end
			
			state_swap: begin
			
				state <= state_get_byte;
			end
			
		endcase
	end
end



assign sram_rw = 1'b1;

endmodule
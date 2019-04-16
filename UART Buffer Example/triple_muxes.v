//Muxes for triple buffer
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

//A is camera, B is VGA, D is dummy data (idle)
//All possible states:
//A->X : B->Y : D->Z -- 3'b000
//A->X : B->Z : D->Y -- 3'b001
//A->Y : B->x : D->Z -- 3'b010
//A->Y : B->Z : D->X -- 3'b011
//A->Z : B->X : D->Y -- 3'b100
//A->Z : B->Y : D->X -- 3'b101



module tri_mem_mux
#(
parameter addr_bus_size = 16,
parameter data_bus_size = 16
)
(

//Inputs

input [(addr_bus_size - 1):0] addr_a,
input [(data_bus_size - 1):0] data_a,
input start_a,
input rw_a,

input [(addr_bus_size - 1):0] addr_b,
input [(data_bus_size - 1):0] data_b,
input start_b,
input rw_b,
input [2:0] select,

//Outputs

output [(addr_bus_size - 1):0] addr_x,
output [(data_bus_size - 1):0] data_x,
output start_x, 
output rw_x,

output [(addr_bus_size - 1):0] addr_y,
output [(data_bus_size - 1):0] data_y,
output start_y,
output rw_y,

output [(addr_bus_size - 1):0] addr_z,
output [(data_bus_size - 1):0] data_z,
output start_z,
output rw_z

);

localparam [(addr_bus_size - 1):0] dummy_addr = 0;
localparam [(data_bus_size - 1):0] dummy_data = 0;
localparam dummy_start = 1'b1; //Start is active low
localparam dummy_rw = 1'b0; //1 for a read (although it doesn't matter)

localparam [2:0] A = 3'b000, //A->X : B->Y : D->Z
					  B = 3'b001, //A->X : B->Z : D->Y
					  C = 3'b010, //A->Y : B->x : D->Z
					  D = 3'b011, //A->Y : B->Z : D->X
					  E = 3'b100, //A->Z : B->X : D->Y
					  F = 3'b101; //A->Z : B->Y : D->X

//X Dispatching					  
assign addr_x = (select == A || select == B)? addr_a : ((select == C || select == E)? addr_b : dummy_addr);
assign data_x = (select == A || select == B)? data_a : ((select == C || select == E)? data_b : dummy_data);
assign start_x = (select == A || select == B)? start_a : ((select == C || select == E)? start_b : dummy_start);
assign rw_x = (select == A || select == B)? rw_a : ((select == C || select == E)? rw_b : dummy_rw);

//Y Dispaching
assign addr_y = (select == C || select == D)? addr_a : ((select == A || select == F)? addr_b : dummy_addr);
assign data_y = (select == C || select == D)? data_a : ((select == A || select == F)? data_b : dummy_data);
assign start_y = (select == C || select == D)? start_a : ((select == A || select == F)? start_b : dummy_start);
assign rw_y = (select == C || select == D)? rw_a : ((select == A || select == F)? rw_b : dummy_rw);

//Z Dispaching
assign addr_z = (select == E || select == F)? addr_a : ((select == B || select == D)? addr_b : dummy_addr);
assign data_z = (select == E || select == F)? data_a : ((select == B || select == D)? data_b : dummy_data);
assign start_z = (select == E || select == F)? start_a : ((select == B || select == D)? start_b : dummy_start);
assign rw_z = (select == E || select == F)? rw_a : ((select == B || select == D)? rw_b : dummy_rw);

 

endmodule



module tri_data_mux
#(
parameter addr_bus_size = 16,
parameter data_bus_size = 16
)
(
input [(data_bus_size - 1):0] data_x,
input [(data_bus_size - 1):0] data_y,
input [(data_bus_size - 1):0] data_z,
input [2:0] select,

output [(data_bus_size - 1):0] data_t //Data to be sent to transmission module
);


//A is the capture module
//B is the transmission module
//D is the dummy input
localparam [2:0] A = 3'b000, //A->X : B->Y : D->Z
					  B = 3'b001, //A->X : B->Z : D->Y
					  C = 3'b010, //A->Y : B->x : D->Z
					  D = 3'b011, //A->Y : B->Z : D->X
					  E = 3'b100, //A->Z : B->X : D->Y
					  F = 3'b101; //A->Z : B->Y : D->X

assign data_t = (select == C || select == E)? data_x : ((select == A || select == F)? data_y : data_z);
					  
endmodule


module tri_ready_mux(
input wire ready_x,
input wire ready_y,
input wire ready_z,
input [2:0] select,

output ready_a,
output ready_b
);

localparam [2:0] A = 3'b000, //A->X : B->Y : D->Z
					  B = 3'b001, //A->X : B->Z : D->Y
					  C = 3'b010, //A->Y : B->x : D->Z
					  D = 3'b011, //A->Y : B->Z : D->X
					  E = 3'b100, //A->Z : B->X : D->Y
					  F = 3'b101; //A->Z : B->Y : D->X
					  
assign ready_a = (select == A || select == B)? ready_x : ((select == C || select == D)? ready_y : ready_z);

assign ready_b = (select == C || select == E)? ready_x : ((select == A || select == F)? ready_y : ready_z);

endmodule

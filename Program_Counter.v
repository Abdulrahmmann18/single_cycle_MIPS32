module Program_Counter #(parameter WIDTH = 32)
(
	input wire 			   clk,
	input wire 			   rst,
	input wire [WIDTH-1:0] pc_in,
	output reg [WIDTH-1:0] pc_out
);
	

	always @(posedge clk or posedge rst) begin
		if (rst) 
			pc_out <= 'b0;			
		else
			pc_out <= pc_in;
	end

endmodule
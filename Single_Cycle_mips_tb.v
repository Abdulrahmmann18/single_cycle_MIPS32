module Single_Cycle_MIPS_tb();
	// signal declaration
	reg clk, rst;
	// DUT Instantiation
	Single_Cycle_MIPS DUT (clk, rst);
	// clk generation block
	initial begin
		clk = 0;
		forever
			#5 clk = ~clk;
	end
	// test stimulus 
	initial begin
		rst = 1;
		#50;
		rst = 0;
		repeat (100) begin
			@(negedge clk);
		end
		$stop;
	end
		

endmodule
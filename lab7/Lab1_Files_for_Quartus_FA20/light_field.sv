module light_field (lights_in, PL, PR, rst, clk, lights_out);
	input logic [8:0] lights_in;
	input logic PL, PR, rst, clk;
	output logic [8:0] lights_out;
	

	genvar i;
	generate 
		for (i =0; i < 9; i++) begin: eachlight
			if (i ==0) 
					normalLight led  (.PL, .PR, .rst, .clk, .NL(lights_in[1 + i]), .NR(1'b0),         .light(lights_out[i]));
			else if (i == 4)
					centerLight led   (.PL, .PR, .rst, .clk, .NL(lights_in[i + 1]), .NR(lights_in[i -1]), .light(lights_out[i]));
			else if (i == 8)
					normalLight led  (.PL, .PR, .rst, .clk, .NL(1'b0),         .NR(lights_in[i - 1]), .light(lights_out[i]));
			else 
				   normalLight two  (.PL, .PR, .rst, .clk, .NL(lights_in[i + 1]), .NR(lights_in[i - 1]), .light(lights_out[i]));
		end
	endgenerate
// 	normalLight one  (.PL, .PR, .rst, .clk, .NL(lights_in[1]), .NR(1'b0),         .light(lights_out[0]));
// 	normalLight two  (.PL, .PR, .rst, .clk, .NL(lights_in[2]), .NR(lights_in[0]), .light(lights_out[1]));
// 	normalLight three(.PL, .PR, .rst, .clk, .NL(lights_in[3]), .NR(lights_in[1]), .light(lights_out[2]));
// 	normalLight four (.PL, .PR, .rst, .clk, .NL(lights_in[4]), .NR(lights_in[2]), .light(lights_out[3]));
// 	centerLight five (.PL, .PR, .rst, .clk, .NL(lights_in[5]), .NR(lights_in[3]), .light(lights_out[4]));
// 	normalLight six  (.PL, .PR, .rst, .clk, .NL(lights_in[6]), .NR(lights_in[4]), .light(lights_out[5]));
// 	normalLight seven(.PL, .PR, .rst, .clk, .NL(lights_in[7]), .NR(lights_in[5]), .light(lights_out[6]));
//    normalLight eight(.PL, .PR, .rst, .clk, .NL(lights_in[8]), .NR(lights_in[6]), .light(lights_out[7]));
// 	normalLight nine (.PL, .PR, .rst, .clk, .NL(1'b0),         .NR(lights_in[7]), .light(lights_out[8]));
	
endmodule



module light_field_testbench();
	logic [8:0] lights_in;
	logic PL, PR, rst, clk;
	logic [8:0] lights_out;
	
	light_field dut (.lights_in(lights_out[8:0]), .PL, .PR, .rst, .clk, .lights_out);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	always_ff @(posedge clk) begin
			lights_in[8:0] <= lights_out[8:0];
	end
	
	initial begin


		rst <= 1;									@(posedge clk);
														@(posedge clk);
		rst <= 0;									@(posedge clk);
														@(posedge clk);
		
		PL <= 1; PR <= 0;  						@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		rst <= 1;									@(posedge clk);
														@(posedge clk);
		rst <= 0;									@(posedge clk);
														@(posedge clk);
		PL <= 0; PR <= 1; 						@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		PL <= 1; PR <= 1;							@(posedge clk);
														@(posedge clk);

		rst <= 1;									@(posedge clk);
														@(posedge clk);
		rst <= 0;									@(posedge clk);
														@(posedge clk);
		PL <= 1; PR <= 0;							@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		PL <= 0; PR <= 1; 						@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		PL <= 1; PR <= 0; 						@(posedge clk);
														@(posedge clk);
														@(posedge clk);
		$stop; 
	end 
endmodule 
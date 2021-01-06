module bird #(parameter FLY_THRESHOLD = 100, parameter GRAV_THRESHOLD = 150) (clk, rst, button, gameover, position);
				  
		input logic clk, rst, button, gameover;
		output int position; // from 0 (top) to 14 (bottom)
		
		int gravity, fly; // internal timing counters
		
		// clk is 1526 Hz
		always_ff @ (posedge clk) begin
				if (rst) begin
						position <= 5; // slightly above halfway up the board
						gravity <= 0;
						fly <= 0;
				end
				else begin
					// if gameover, maintain position
					if (gameover) begin
							position <= position;
					end
					// else if at bottom edge and no button, maintain position
					else if ((position == 14) && !button) begin
									position <= position;
					end
					// else if at top edge and button, maintain position
					else if ((position == 0) && button) begin
									position <= position;
					end
					// else if button, fly up
					else if (button) begin
									fly <= fly + 1;
									
								if (fly > FLY_THRESHOLD) begin
									fly <= 0;
									position <= position - 1;
								end
					end
					// else (if no button, gravity pulls down)
					// gravity increment
					else begin
						gravity <= gravity + 1;	
						
						if (gravity > GRAV_THRESHOLD && !button) begin
									gravity <= 0;
									position <= position + 1;
						end	
					end
					
				end
		end
		
endmodule

module bird_testbench();
	logic clk, rst, button, gameover;
	int position;
	bird #(.FLY_THRESHOLD(0), .GRAV_THRESHOLD(0)) dut (.clk, .rst, .button, .position,
			.gameover);
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	initial begin
		// Always reset at start
		rst <= 1; @(posedge clk);
					 @(posedge clk);
					 
		rst <= 0; button <= 0; @(posedge clk);
					              @(posedge clk);
   
		// Test case 1: gravity, ensure bird doesn’t fall off bottom
		repeat(20) @(posedge clk);
		
		// Test case 2: fly, ensure bird doesn’t fly above to
		button <= 1; repeat(20) @(posedge clk);
		
		// Test case 3: gameover (freeze)
		rst <= 1; @(posedge clk);
					 @(posedge clk);
					 
		rst <= 0; button <= 0; @(posedge clk);
					              @(posedge clk);
		gameover <= 1;  repeat(5) @(posedge clk);
		
	$stop; // End the simulation.
	end
endmodule

// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1; // Used for LED board
    input logic CLOCK_50;

	 // Turn off HEX displays
    //assign HEX0 = '1;
    //assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
	 
	 // Reset
	 logic rst;                  
	 assign rst = SW[9];//~KEY[0];

	 
	 /* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	    ===========================================================*/
	 logic [31:0] div_clk;
	 clock_divider cdiv (.clk(CLOCK_50),
								.rst,
								.divided_clocks(div_clk));

	 // Clock selection; allows for easy switching between simulation and board clocks
	 logic clkSelect;
	//	
	 // Uncomment ONE of the following two lines depending on intention
	 assign clkSelect = CLOCK_50;  // for simulation
	 //assign clkSelect = div_clk[14]; // 1526 Hz clock for board
	 	
	 
	 /* Set up LED board driver
	    ================================================================== */
	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs (row x col)
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs (row x col)
	 
	 /* Standard LED Driver instantiation - set once and 'forget it'. See LEDDriver.sv for more info. 
	 DO NOT MODIFY this line or the LEDDriver file */
	 LEDDriver Driver (.clk(clkSelect), .rst, .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	 
	 /* LED board test submodule - paints the board with a static pattern.
	    Replace with your own code driving RedPixels and GrnPixels.
		 
	 	 KEY0      : Reset (set above on line 20)
		 =================================================================== */
	 //LED_test test (.rst, .RedPixels, .GrnPixels);
	 
	 
   logic gameover;
  
	
   // instantiate bird module here
	logic o1;
	int p;
	
	series_diffs s1(.raw(~KEY[0]), .rst, .clk(clkSelect), .clean(o1));
	
	bird #(.FLY_THRESHOLD(0), .GRAV_THRESHOLD(0)) flappy (.clk(clkSelect), .rst, .button(o1), .gameover, .position(p));
	
	
   // display bird
   always_comb begin
		RedPixels = '0; // first, set entire RedPixels array off
		RedPixels[p][13] = 1'b1; // set bird top left pixel on
		RedPixels[p][12] = 1'b1; // set bird top right pixel on
		RedPixels[(p+1)][13] = 1'b1; // set bird bottom left pixel on
		RedPixels[(p+1)][12] = 1'b1; // set bird bottom right pixel on
   end
	
	
	logic [3:0] ones, tens;
	
	
	pipe_generator #(.SHIFT_THERSHOLD(0), .GAP(0)) pipes (.clk(clkSelect), .rst, .gameover, .GrnPixels(GrnPixels));
	
	score #(.SCORE_THRESHOLD(0))  counter(.clk(clkSelect), .rst, .gameover, .tens(tens), .ones(ones), .GrnPixels(GrnPixels));
	
	seg7 ten(.bcd(tens), .leds(HEX1));
	seg7 one(.bcd(ones), .leds(HEX0));
	
	collision detector(.clk(clkSelect), .rst, .RedPixels, .GrnPixels, .gameover);
	
endmodule





// score module, build on the same file for easier testing
module score #(SCORE_THRESHOLD = 218) (clk, rst, gameover, tens, ones, GrnPixels);
	input logic [15:0][15:0]GrnPixels;
	input logic clk, rst, gameover;
	output logic [3:0] tens, ones;
	
	int point;
	
	
		always_ff @(posedge clk) begin
			if (rst) begin
				tens <= 4'b0000;
				ones <= 4'b0000;
			end

			else if (gameover) begin
				tens <= tens;
				ones <= ones;
			end
			
			else begin
				if((point > SCORE_THRESHOLD) && (ones != 4'b1011)) begin
					point <= 0;
					ones <= ones + 1'b1;
				end
				
				else if(ones == 4'b1010) begin
					ones <= 4'b0000;
					tens <= tens + 1'b1;
				end
				
				else begin
					ones <= ones;
					tens <= tens;
						if(GrnPixels[0][13] == 1'b1 || GrnPixels[15][13] == 1'b1 || GrnPixels[4][13] == 1'b1 || GrnPixels[10][13] == 1'b1) begin
							point <= point + 1;
						end
				end
				
			end
			
			
		end
	
endmodule

module DE1_SoC_testbench();
	logic clkSelect, CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_1; 
	
	DE1_SoC dut (.CLOCK_50(clkSelect), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .GPIO_1);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clkSelect <= 0;
		forever #(CLOCK_PERIOD/2) clkSelect <= ~clkSelect; // Forever toggle the clock
	end
	
	// Test the design.
	initial begin
		SW[9] <= 1; @(posedge clkSelect);
						@(posedge clkSelect);
		SW[9] <= 0; @(posedge clkSelect);
						@(posedge clkSelect);
		// button test
		KEY[0] <= 0; repeat(40) @(posedge clkSelect);
		
		// gameover test
		SW[9] <= 1; @(posedge clkSelect);
						@(posedge clkSelect);
		SW[9] <= 0; @(posedge clkSelect);
						@(posedge clkSelect);
		SW[0] <= 1; @(posedge clkSelect);
		repeat(2)				@(posedge clkSelect);
	$stop;
	end
endmodule

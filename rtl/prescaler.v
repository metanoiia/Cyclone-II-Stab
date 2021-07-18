module prescaler(
	input 		clk,
	input 		rst,
	input [2:0] set_rate,
	
	output reg  clk_driver
);

reg clk_5;   // clock 5 Hz
reg clk_10;  // clock 10 Hz
reg clk_20;  // clock 20 Hz
reg clk_25;  // clock 25 Hz
reg clk_35;  // clock 35 Hz
reg clk_50;  // clock 50 Hz
reg clk_75;  // clock 75 Hz
reg clk_100; // clock 100 Hz

reg [19:0] clock_div; // clock division register

always @ ( posedge clk )
begin
	if( rst )
	begin
		clock_div <= 0;
		clk_5 	 <= 0;
		clk_10	 <= 0;
		clk_20	 <= 0;
		clk_25	 <= 0;
		clk_35	 <= 0;
		clk_50	 <= 0;
		clk_75	 <= 0;
		clk_100	 <= 0;
	end
	else
		clock_div <= clock_div + 20'd1;
		
	if( clock_div % 50_000 == 0 ) //50_000
		clk_100 <= ~clk_100;
		
	if ( clock_div % 66_666 == 0 )//66_666
		clk_75  <= ~clk_75;
		
	if ( clock_div % 100_000 == 0)//100_000
		clk_50  <= ~clk_50;
		
	if ( clock_div % 142_857 == 0)//142_857
		clk_35  <= ~clk_35;
		
	if ( clock_div % 200_000 == 0)//200_000
		clk_25  <= ~clk_25;
		
	if ( clock_div % 250_000 == 0)//250_000
		clk_20  <= ~clk_20;
		
	if ( clock_div % 500_000 == 0)//500_000
		clk_10  <= ~clk_10;
		
	if ( clock_div == 1_000_000 )//1_000_000
		clk_5   <= ~clk_5;
	
	if ( clock_div == 1_000_001 )//1_000_001
		clock_div <= 0;
		
end




//choosing one clock according to driving signal		
always @ ( * )
begin
	case ( set_rate )
		3'b000 : clk_driver = clk_5;
		3'b001 : clk_driver = clk_10;
		3'b010 : clk_driver = clk_20;
		3'b011 : clk_driver = clk_25;
		3'b100 : clk_driver = clk_35;
		3'b101 : clk_driver = clk_50;
		3'b110 : clk_driver = clk_75;
		3'b111 : clk_driver = clk_100;
	endcase
end



endmodule

module control_Unit(	
	input  		 clk,
	input	 		 rst,
	input  		 rot_dir,
	input  		 rot_en,
	input	 [2:0] set_rate,
	
	output [3:0] f
);
wire 		 clk_driver;

prescaler motor_ps(
.clk			( clk 		 ),
.rst			( rst			 ),
.set_rate	( set_rate 	 ),
.clk_driver ( clk_driver )
);

fs_motor motor(
.clk		 ( clk_driver ),
.rst		 ( rst		  ),
.rot_en   ( rot_en     ),
.rot_dir  ( rot_dir    ),
.f0		 ( f[0]       ),
.f1		 ( f[1]		  ),
.f2		 ( f[2]	     ),
.f3		 ( f[3]		  ),
);
	

endmodule
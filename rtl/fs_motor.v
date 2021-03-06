module fs_motor(
  input  	  clk,
  input 		  rst,
  input 		  rot_en,
  input  	  rot_dir,
  
  output reg  f0,
  output reg  f1,
  output reg  f2,
  output reg  f3
);

//f0 - orange wire
//f1 - pink wire
//f2 - yellow wire
//f3 - blue wire

reg [1:0] cnt; // register defines coils behavior

always @ ( posedge clk )
	if( rst )
		cnt <= 2'b00;
	else
		cnt <= cnt + 2'b01;
		
always @ ( posedge clk )
begin
	if ( rot_en )
	begin
		if ( ~rot_dir )
		begin
			f0 <= cnt==0 || cnt==3;
			f1 <= cnt==0 || cnt==1;
			f2 <= cnt==1 || cnt==2;
			f3 <= cnt==2 || cnt==3;
		end
		else 
		begin
			f0 <= cnt==0 || cnt==1;
			f1 <= cnt==0 || cnt==3;
			f2 <= cnt==2 || cnt==3;
			f3 <= cnt==1 || cnt==2;
		end
	end
end

endmodule


module top(
	input 		CLOCK_50,
	input	[3:0] KEY,
	
	output [6:0] HEX0,
	output [6:0] HEX1,
	inout [35:0] GPIO_1 //35:0
	
);

localparam SPI_MODE = 0;
localparam CLKS_PER_HALF_BIT = 250_000;


wire 		  clk;
wire 		  rst;
wire [3:0] f;

wire miso;
wire sclk;
wire mosi;
wire cs;

wire       rot_dir;
wire 		  rx_dv;
wire [7:0] rx_byte_w;

wire [3:0] h_from_byte;
wire [3:0] l_from_byte;

wire [6:0] h_to_hex;
wire [6:0] l_to_hex;

assign HEX1 = h_to_hex;
assign HEX0 = l_to_hex;

assign h_from_byte = rx_byte[7:4];
assign l_from_byte = rx_byte[3:0];

reg        rot_en;
reg        tx_dv;
reg        rdy_delay;
reg [2:0]  set_rate;
reg [7:0]  rx_byte;
reg [3:0]  delay_cnt;

wire 		  ready;

assign clk = 		   CLOCK_50;
assign rst = 		  ~KEY[0];
assign GPIO_1[3:0] = f[3:0];

assign GPIO_1[35]	 = cs;
assign GPIO_1[34]	 = mosi;
assign miso 		 = GPIO_1[33]; // rename!!!!
assign GPIO_1[32] = sclk;



assign rot_dir = rx_byte[7];

always @ ( posedge clk )
begin
	if ( rst )
	begin
		rot_en    	<= 1'b0;
		set_rate  	<= 3'b000;//000
		delay_cnt   <= 4'b0001;
	end
	
	else
	begin
		if( rdy_delay )
			delay_cnt <= delay_cnt + 4'b0001;
			
		if ( rx_byte != 0 )
			rot_en <= 1'b1;
			
		if ( rot_dir == 0 )
		begin
			if ( rx_byte[6] )  set_rate <= 3'b111;
			else 
				if ( rx_byte[5] )  set_rate <= 3'b110;
				else 
					if ( rx_byte[4] ) set_rate <= 3'b101;
					else 
						if ( rx_byte[3] ) set_rate <= 3'b100;
						else 
							if ( rx_byte[2] ) set_rate <= 3'b011;
							else
								if ( rx_byte[1] & rx_byte[0] ) set_rate <= 3'b010;
								else
									if ( rx_byte[1] ) set_rate <= 3'b001;
									else set_rate <= 3'b000;
		end
		else
		begin
			if ( rx_byte[7] )  set_rate <= 3'b111;
			else 
				if ( rx_byte[6] )  set_rate <= 3'b110;
				else 
					if ( rx_byte[5] ) set_rate <= 3'b101;
					else 
						if ( rx_byte[4] ) set_rate <= 3'b100;
						else 
							if ( rx_byte[3] ) set_rate <= 3'b011;
							else
								if ( rx_byte[2] ) set_rate <= 3'b010;
								else
									if ( rx_byte[1] ) set_rate <= 3'b001;
									else set_rate <= 3'b000;
		end
	end
end

always @ ( negedge clk )
begin
	if( rst )
	begin
		rx_byte   <= 8'b0000_0000;
		rdy_delay <= 1'b1;
	end
	else
	begin
		if ( delay_cnt == 15 )
			tx_dv <= 1'b1;
		else 
			tx_dv <= 1'b0;
		
		if ( rx_dv == 1'b1 )
		begin
			rx_byte[7:0] <= rx_byte_w[7:0];
			rdy_delay    <= 1'b1;
		end
		else	if( delay_cnt  == 4'b0000)
			rdy_delay    <= 1'b0;
	end
end


decoder dc_h(
.dec_i ( h_from_byte ),
.hex_o ( h_to_hex 	)
);

decoder dc_l(
.dec_i ( l_from_byte ),
.hex_o ( l_to_hex 	)
);

control_Unit CU(
.clk      ( clk      ),
.rst      ( rst      ),
.rot_dir  ( rot_dir  ),
.rot_en   ( rot_en   ),
.set_rate ( set_rate ),
.f			 ( f        )
);

SPI_MASTER #(SPI_MODE,CLKS_PER_HALF_BIT) spi_tr(
.rstn_i    ( !rst       ),
.sys_clk_i ( clk       ),
.tx_dv_i   ( tx_dv     ),
.tx_ready_o( ready     ),
.rx_dv_o	  ( rx_dv     ),
.rx_byte_o ( rx_byte_w ),
.sclk_o	  ( sclk      ),
.miso_i	  ( miso      ),
.mosi_o	  ( mosi      ),
.cs_o      ( cs        )
);

endmodule

module SPI_MASTER
  #(parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 1)
  (
 
   input        rstn_i,   
   input        sys_clk_i,    
         
   input        tx_dv_i,          
   output reg   tx_ready_o,       
   
   // RX (MISO) Signals
   output reg       rx_dv_o,    
   output reg [7:0] rx_byte_o,   

   // SPI Interface
   output reg sclk_o,
   input      miso_i,
   output reg mosi_o,
	output reg cs_o,
	output reg tx_done
   );
  
  localparam X_DATA      = 8'b00001000;
  localparam INSTRUCTION = 8'b00001011;
  //reg [1:0] r_gyro_cnt;
  
  wire w_CPOL;   
  wire w_CPHA;     

  reg [$clog2(CLKS_PER_HALF_BIT*2)-1:0] r_sclk_Count;
  reg r_sclk;
  reg [5:0] r_sclk_Edges;
  reg r_Leading_Edge;
  reg r_Trailing_Edge;
  reg       r_TX_DV;
  reg [15:0] r_TX_Byte;

  
  reg [2:0] r_RX_Bit_Count;
  reg [3:0] r_TX_Bit_Count;

  assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);
  assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);
  
  
  always @(posedge sys_clk_i or negedge rstn_i)
  begin
    if (!rstn_i)
    begin
      tx_ready_o      <= 1'b0;
      r_sclk_Edges    <= 0;
		r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      r_sclk          <= w_CPOL; 
      r_sclk_Count    <= 0;  
      cs_o            <= 1;      
    end
    else
    begin
	   r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;	
      if ( tx_dv_i )
      begin
        tx_ready_o    <= 1'b0;
		  cs_o          <= 0;
        r_sclk_Edges  <= 48;
      end
      else if (r_sclk_Edges > 0)
      begin
        tx_ready_o <= 1'b0;
        if (r_sclk_Count == CLKS_PER_HALF_BIT*2-1)
        begin
          r_sclk_Edges <= r_sclk_Edges - 1;
          r_Trailing_Edge <= 1'b1;
          r_sclk_Count <= 0;
          r_sclk       <= ~r_sclk;
        end
        else if (r_sclk_Count == CLKS_PER_HALF_BIT-1)
        begin
          r_sclk_Edges <= r_sclk_Edges - 1;
          r_Leading_Edge  <= 1'b1;
          r_sclk_Count <= r_sclk_Count + 1;
          r_sclk       <= ~r_sclk;
        end
        else
        begin
          r_sclk_Count <= r_sclk_Count + 1;
        end
      end  
     else begin 
	       tx_ready_o <= 1'b1;
			 if( rx_dv_o )
			 cs_o <= 1;
	  end
	       
    end 
  end 
///////////////////
  always @(posedge sys_clk_i or negedge rstn_i)
  begin
    if (!rstn_i)
    begin
      sclk_o  <= w_CPOL;
    end
    else
      begin
        sclk_o <= r_sclk;
      end 
  end 
///////////////////

  always @(posedge sys_clk_i or negedge rstn_i)
  begin
    if (!rstn_i)
    begin
      r_TX_Byte <= 16'h0000;
      r_TX_DV   <= 1'b0;
		//r_gyro_cnt<= 2'd1;
    end
    else
      begin
        r_TX_DV <= tx_dv_i; 
        if (tx_dv_i)
        begin
		    //if (r_gyro_cnt == 1)begin
			     r_TX_Byte  <= {INSTRUCTION,X_DATA};
				 // r_gyro_cnt <= r_gyro_cnt+1;
				//end
				
			 //else if(r_gyro_cnt == 2)begin
			  // r_TX_Byte  <= X_DATA;
	        // r_gyro_cnt <= r_gyro_cnt-1;
	       //end
			 
        end
      end 
  end 

  // Works with both CPHA=0 and CPHA=1
  always @(posedge sys_clk_i or negedge rstn_i)
  begin
    if (!rstn_i)
    begin
      mosi_o         <= 1'b0;
      r_TX_Bit_Count <= 4'b1111;
	   tx_done        <= 0;	
    end
    else
    begin
      if (tx_ready_o ||( r_sclk_Edges < 16 ))
      begin
        r_TX_Bit_Count <= 4'b1111;
      end
      // Начало транзакции и CPHA = 0
      else if (r_TX_DV & ~w_CPHA)
      begin
        mosi_o         <= r_TX_Byte[4'b1111];
        r_TX_Bit_Count <= 4'b1110;
      end
      else if ((r_Leading_Edge & w_CPHA)|(r_Trailing_Edge & ~w_CPHA))
      begin
        r_TX_Bit_Count <= r_TX_Bit_Count - 1;
        mosi_o         <= r_TX_Byte[r_TX_Bit_Count];
		  if( r_TX_Bit_Count == 0 )begin
		  tx_done <= 1;
		  end
		  else tx_done <= 0;
      end
    end
  end


  always @(posedge sys_clk_i or negedge rstn_i)
  begin
    if (!rstn_i)
    begin
      rx_byte_o      <= 8'h00;
      rx_dv_o        <= 1'b0;
      r_RX_Bit_Count <= 3'b111;
    end
    else
    begin
      rx_dv_o   <= 1'b0;
      if (r_sclk_Edges>=16 )
      begin
        r_RX_Bit_Count <= 3'b111;
      end
      else if (((r_Leading_Edge & ~w_CPHA) |(r_Trailing_Edge & w_CPHA)))
      begin
        rx_byte_o[r_RX_Bit_Count] <= miso_i; 
        r_RX_Bit_Count            <= r_RX_Bit_Count - 1;
        if (r_RX_Bit_Count == 3'b000)
        begin
          rx_dv_o   <= 1'b1;   // Byte done, pulse Data Valid
        end
      end
    end
  end

endmodule 
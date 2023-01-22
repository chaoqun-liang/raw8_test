/*Line Valid Indicator (active high). 
Goes high at the start of valid pixel data and goes low at the end of valid pixel data.
Available only for MIPI CSI-2 mode.
Frame Valid Indicator (active high). Goes high when frame start short packet is
received and goes low when frame end short packet is received.
*/
module sync_unpack
	(
		input logic			byte_clk_i,
		input logic			byte_rst_i,
		
		input logic			byte_vsync_i, // sp_en_o come back soon for a double check 
		input logic         byte_hsync_i, // mtvalid_o shall work,payload enable signal
		
		input logic			pixel_clk_i,
		input logic 		   pixel_rst_i,
		
		output logic		    vsync_o,
		output logic		    hsync_o
							
	);
	
	logic byte_vsync_i_next;
	logic vsync;
	logic hsync;
	
		
	//assign vsync_o = vsync;
    //assign hsync_o = hsync;
	
	// update 27/11: added pos edge detector 
	// rising edge of sp_en toggles vsync given sp_en on pixel clock
	// sp_en Active high pulse to indicate a valid short packet in the Rx side
	
	// update. 02/01  no actually use the rising edge of byte_vsync_i to toggle the output vsync
	
	always_ff @(posedge byte_clk_i or posedge byte_rst_i ) begin : vsync_detect  // this byte_rst_i shared with fifo. it is high active
		if(byte_rst_i) begin
		   vsync <= 'b0;
			byte_vsync_i_next <= 'b0;
		end else begin
			byte_vsync_i_next <= byte_vsync_i ; // 
            	vsync <=  (byte_vsync_i & ~byte_vsync_i_next) ? ~vsync :  vsync; 
             end			
	end
	
	//assign vsync =  (byte_vsync_i & ~byte_vsync_i_next) ? vsync :  ~vsync; // as long as no rising edge of vsync, vsync stays high	 
	
	
	always_ff @(posedge byte_clk_i or posedge byte_rst_i) begin : hsync_detect  // 
		if(byte_rst_i) begin
			hsync <= 'b0;
		end else begin
			hsync <= byte_hsync_i ; // 		
			end
	end


// update sync at pixel clock, any better way
	always_ff@(posedge pixel_clk_i or posedge pixel_rst_i) begin : pass_sync_at_pixel_clk // not sure, how to optimize this
		if(pixel_rst_i) begin
			vsync_o <= 'b0;
			hsync_o <= 'b0;
			end
		else begin
			hsync_o <= hsync;
			vsync_o <= vsync;
			end
			end			
		
endmodule
// THIS payload IS FOR RAW8

// need to add a pixel valid signal to reset the rd_data and wr_data inbetween lines and frames 

// or get the rd_en value from last cycle, use and logic with rd_data
module payload_unpack #(
	    parameter BYTE_WIDTH = 16,
		
	    parameter PIXEL_WIDTH = 8 // raw8
		// parameter FORMAT_DIWTH  = 10; // add raw10
		)
	(
		input  logic		byte_clk_i,
		input  logic		byte_rst_i,
		
		input  logic		pixel_clk_i,
		input  logic 		pixel_rst_i,
		
		input  logic		wr_en_i,
		input  logic 		rd_en_i,
		
		
		input  logic [BYTE_WIDTH-1:0]   wr_data_i,  // 16 LSB of mtdata
		 // 
		
		 // as logn as rd_en falledge, the pixel transmission in a line ends
		output logic [PIXEL_WIDTH-1:0]   pixel_data_o,
		// signals for debug
		output logic rd_valid_o,
		output logic full_o,
        output logic empty_o// will use it for debug
     //   output logic almost_full_o,  // will use it for debug
      //  output logic almost_empty_o
		
				
	);
	logic full;
	logic rd_valid;
	logic [PIXEL_WIDTH-1:0]rd_data;
	assign full_o = full ;
	assign rd_valid_o = rd_valid ; 
	assign pixel_data_o = (rd_valid)? rd_data: 0;
	// fifo2 with wr depth 2 and rd depth 4 will lose data from rd side
	// wr depth 4 and rd depth 8 works fifo!
	my_fifo1 fifo_inst  (
	
		.wr_clk_i			(byte_clk_i  	),
        .rd_clk_i			(pixel_clk_i 	),
        .rst_i				(byte_rst_i  	),
        .rp_rst_i			(pixel_rst_i 	),  // high active 
        .wr_en_i				(wr_en_i		 	),
        .rd_en_i				(rd_en_i		 	),
        .wr_data_i			(wr_data_i   	),
        .full_o				(full      	), // will use it for debug
        .empty_o				(empty_o     	), // will use it for debug
      //  .almost_full_o		(almost_full_o 	),  // will use it for debug
       // .almost_empty_o		(almost_empty_o	),  // will use it for debug
        .rd_data_o		    (rd_data		)
		
		);
		
	

			
	
	always_ff @(posedge pixel_clk_i or posedge pixel_rst_i ) begin 
		if(pixel_rst_i || ~rd_en_i) begin
		   rd_valid  <= 'b0;
		end else begin
			rd_valid <= rd_en_i ; // 
           
             end			
	end
	
	
		
endmodule
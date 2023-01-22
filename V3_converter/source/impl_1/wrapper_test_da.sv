// test includes dphy + axi4s
// csi2 should be excluded from DUT


// this wrapper includes only dphy and axi4s 
module wrapper_test_da #(
		parameter  NUM_RX_LANE = 2,
		parameter  RX_GEAR     = 8,
		parameter  DATA_WIDTH  = 48,
		parameter BYTE_WIDTH = 16,
	    parameter PIXEL_WIDTH = 8
)(  

		// DPHY RX Submodule
		input  logic                        	clk_p_i,
		input  logic                        	clk_n_i,
		input  logic [NUM_RX_LANE - 1 : 0]	d_p_io,
		input  logic [NUM_RX_LANE - 1 : 0]	d_n_io,
		input  logic 						clk_byte_fr_i ,
		input  logic						    reset_n_i ,
		input  logic 						reset_byte_n_i , 
		input  logic 						reset_byte_fr_n_i , 
		input  logic [5:0]					ref_dt_i ,     // reference data type . see tb
		input  logic 						tx_ready_i ,   // redundant. only availabe when axi is disabled 
		input  logic 						pd_dphy_i ,    // only for hardened dphy block, i am going for hardened for now
	/*	
		input  logic                          clk_pixel_i,
		output logic                          vsync_o ,
		output logic                          hsync_o ,
		output logic [DATA_WIDTH - 1:0]       pixel_o 
		*/
		output logic	 							clk_byte_o , // generated byte clock from dphy to latch internal parallel bate data from dphy_rx_wrap
		output logic								clk_byte_hs_o ,
		
		output logic [NUM_RX_LANE - 1 :0]           lp_d_rx_p_o ,
		output logic [NUM_RX_LANE - 1 :0]           lp_d_rx_n_o , 
		output [NUM_RX_LANE*RX_GEAR - 1 :0]        bd_o , // csi2(byte) data from parser
		
		output logic     [47:0]  axis_mtdata,       // to show data at master to compare
		output logic                             		 axis_stready,
		output logic        [47:0]					axis_srdata ,
		
		output logic                              	axis_mtvalid ,
		
		output logic 								sp_en_o ,// short packet enable
		output logic 								lp_en_o , // long packet enable 
		output logic 								lp_av_en_o , // a mindle
		output logic 								hs_sync_o,

        output logic 								clk_pixel_o,
		output logic 								pll_lock_p,
		
		output logic 		vsync_o,
		output logic 		hsync_o,
		output logic		[BYTE_WIDTH - 1 :0] wr_data_i,
		output  logic 	[PIXEL_WIDTH - 1 :0] pixel_o,
		output logic rd_valid_o,// for raw10 processing
		
		input logic  pixel_rst_i,
		inout logic  byte_rst_i,
		
		// signals for debug
		output logic full_o,
        output logic empty_o// will use it for debug
     //   output logic almost_full_o,  // will use it for debug
       // output logic almost_empty_o
		
		
	);
	//logic axi4s_svalid_i;
	//assign payload_en = axis_mtvalid;
          
    //logic 	[PIXEL_WIDTH - 1 :0] rd_data_o;
    logic rd_en_i  ;
	assign   wr_data_i = axis_srdata[BYTE_WIDTH - 1 :0];
	assign  rd_en_i = (~empty_o)? 1:0;
	logic wr_en_i ;
	logic rd_en_i_last;
    assign wr_en_i	= (~full_o) & hsync_o ;
	
	//logic payload_en;
	//	logic								axis_mtvalid ; 
//		logic        [47:0]					axis_mtdata ; 
	
		//logic								axis_stready ; 
		//logic								axis_srstn; // from slave , can be connected to another reset
		//logic	 							clk_byte ;         // generated byte clock from dphy to latch internal parallel bate data from dphy_rx_wrap
		//logic								clk_byte_hs ; 
        
		//logic              pll_lock_p; // do i have to keep this ?
	  
DPHY_INST my_dphy_inst(
		    .axis_mtvalid_o		(axis_mtvalid ),
			.axis_mtdata_o		(axis_mtdata ),
			.axis_stready_i		(axis_stready ),
			.clk_byte_o			(clk_byte_o ),
			.clk_byte_hs_o		(clk_byte_hs_o ),
			.clk_byte_fr_i		(clk_byte_fr_i ),
			.reset_n_i			(reset_n_i ),
			.reset_byte_n_i  	(reset_byte_fr_n_i ),
			.reset_byte_fr_n_i	(reset_byte_fr_n_i ),
			.clk_p_io			(clk_p_i ),
			.clk_n_io			(clk_n_i ),
			.d_p_io				(d_p_io ),
			.d_n_io				(d_n_io ),
			.lp_d_rx_p_o		    (lp_d_rx_p_o ),
			.lp_d_rx_n_o		    (lp_d_rx_n_o ),
			.bd_o				(bd_o ),
			.hs_sync_o			(hs_sync_o ),
			.ref_dt_i			(ref_dt_i ),
			.tx_rdy_i			(tx_ready_i ),
			.pd_dphy_i			(pd_dphy_i ),
			.sp_en_o			    (sp_en_o ),
			.lp_en_o		    	(lp_en_o ),
			.lp_av_en_o			(lp_av_en_o )
		);
		
		
		
axi4s_slave_if #(         // double check 
			.DATA_WIDTH(DATA_WIDTH)
			
		) axi4s_slave ( 
			.axi4s_sclk_i       (clk_byte_fr_i),
			.axi4s_rstn_i       (reset_byte_fr_n_i ),
			.axi4s_svalid_i     (axis_mtvalid ),
			.axi4s_sready_o     (axis_stready ),
			.axi4s_sdata_i      (axis_mtdata),     // only take data type-5, word count-16 and payload-16. come back soon
			.axi4s_sdata_o      (axis_srdata)
		);
		
		
 int_gpll pll_inst(
        .clki_i( clk_byte_fr_i ),
        .rstn_i( reset_n_i ),
        .clkop_o(clk_pixel_o ),
        .lock_o( pll_lock_p )
		);

sync_unpack sync_inst(
		.byte_clk_i(clk_byte_fr_i),
		.byte_rst_i(byte_rst_i ),
		
		.byte_vsync_i(sp_en_o), // 
		.byte_hsync_i(axis_mtvalid), // mtvalid_o shall work
		
		.pixel_clk_i(clk_pixel_o),
		.pixel_rst_i(pixel_rst_i),
		
		.vsync_o(vsync_o),
		.hsync_o(hsync_o)
		
							
	);
	



payload_unpack #(
			.BYTE_WIDTH(BYTE_WIDTH),
			.PIXEL_WIDTH(PIXEL_WIDTH)
		)payload_inst(
		.byte_clk_i(clk_byte_fr_i),
		.byte_rst_i(byte_rst_i),		
		.pixel_clk_i(clk_pixel_o),
		.pixel_rst_i(pixel_rst_i),		
		.wr_en_i(wr_en_i), // try payload enable
		.rd_en_i(rd_en_i),	// write 1	
		.wr_data_i(wr_data_i),  // 16 LSB of mtdata
		.pixel_data_o(pixel_o),
		//debug
		
		.full_o				(full_o      	), // will use it for debug
        .empty_o				(empty_o     	), // will use it for debug
        // will use it for debug
       .rd_valid_o(rd_valid_o)
							
	);


/*	always_ff @(posedge clk_pixel_o) begin 
			rd_en_i_last <= rd_en_i ; // 
        end			
	assign pixel_o = (rd_en_i_last)? rd_data_o : 0 ; */

endmodule 
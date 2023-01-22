`timescale 1 ps / 1 ps


`include "bus_driver.v"
`include "clk_driver.v"
`include "csi2_model.v"


module tb_da;
	//  design parameters
	parameter		    BYTECLK_MHZ			= 187;
	parameter			NUM_RX_LANE			= 2;
	parameter			RX_GEAR				= 8;
	
	//parameter integer 	DPHY_CLK				= 2000000/(BYTECLK_MHZ*RX_GEAR);//in ps, clock period of DPHY.
	parameter integer 	DPHY_CLK				= 1336;
	parameter            NUM_LINES			= 4;
	parameter  			NUM_FRAMES			= 2;  
	parameter  			NUM_PIXELS			= 1920;
	
	parameter BYTE_WIDTH = 16;
	parameter PIXEL_WIDTH = 8;
	
	parameter			DATA_WIDTH			= 48;   //axi4s  master 
    parameter            RX_CLK_MODE          = "HS_ONLY";

    // camera csi2  25 params
    //can be 8, 10 as per the selected data type RAW8, RAW10 respectively

	parameter  DATA_TYPE             = "RAW10";
	parameter  data_type1			=  (DATA_TYPE == "RAW8")? 6'h2A  :  6'h2B ;
	parameter  DATA_COUNT			= 800;

	//parameter integer DPHY_CLK       = 2000000/(BYTECLK_MHZ*RX_GEAR);//in ps, clock period of DPHY.

	parameter  t_lpx					= 60000;
	parameter  t_clk_prepare			= 38000;
	parameter  t_clk_zero			= 262000;
    parameter  t_clk_trail			= 60000;
	parameter  t_clk_pre				= 12*(DPHY_CLK/2); // in ps
	parameter  t_clk_post			= (1200000 + (52*DPHY_CLK/2)); // in ps, minimum of 60ns+52*UI
    parameter  t_hs_prepare  		    = (85000 + (6*DPHY_CLK/2)); 
    parameter  t_hs_zero				= ((145000 + (10*DPHY_CLK/2)) - t_hs_prepare); //in ps, hs_prepare + hs_zero minimum should be 145ns+10*UI
    parameter  t_hs_trail             = ((60000 + (4*DPHY_CLK/2)) + (105000 + (12*DPHY_CLK/2)))/2; 
    parameter  lps_gap				= 5000000;
    parameter  frame_gap				= 5000000; //delay between frames (in ps);
	parameter  t_init				= 1000; //in ps
    parameter  dphy_ch				= 0;
    parameter  dphy_vc				= 2'h0; // virtual channel ID. example: 2'h0
    parameter  long_even_line_en		= 0; // for raw8 raw10 raw12 
    parameter  ls_le_en				= 0;
    parameter  debug					= 0;


	parameter       INIT_DELAY                = 5000000;
	
	
	/// CSI-2
	parameter [31:0]  HEADERSP1                 = 32'h1A000100;
	parameter [31:0]  HEADERLP1                 = 32'h250BB824;
	parameter [31:0]  HEADERSP2                 = 32'h1D000101;
    // general input signals 
    logic 								clk_tb_i;
	logic 								reset_tb_i;
	
	// output signal by dphy to drive clk_byte_fr_tb_i for the wrap
	// Generated byte clock from the D-PHY module based on the input D-PHY clock lane,
	//	active only when the clock lanes are in high-speed mode.
	logic 								clk_byte_hs_o; 
	
	// input signals of TB
	// besides general signals, another input signal for cam
	logic  								pll_lock_tb_i; //  could always set high, check later. see tb_top
	
	// internal signals for TB. 5 outputs for cam
	logic 								clk_p_tb;
	logic 								clk_n_tb;
	logic 	[NUM_RX_LANE - 1 : 0] 		do_p_tb;
	logic 	[NUM_RX_LANE - 1 : 0] 		do_n_tb;
	logic 								csi_valid_tb; // come back
//	logic        [47:0] axis_mtdata_o;
	
	// input signals for TB. inputs for wrap, besides 4 from last list
	// too many rst and clks, just leave those ones i dont use. 
	logic 								clk_byte_fr_i ;
	//logic								reset_n_tb_i ;
//	logic 								reset_byte_n_tb_i ; 
	//logic 								reset_byte_fr_tb_i ; 
	//logic [5:0]						ref_dt_tb_i ;     // reference data type . see tb
	logic 						  		tx_ready_tb ;   // redundant. only availabe when axi is disabled 
	logic 								pd_dphy_tb ;
	
	logic       [5:0]  ref_dt_tb   = (DATA_TYPE == "RAW8")? 6'h2A : 6'h2B ;
                                                            
	// output signals for TB
	logic	 							clk_byte_o ;         // generated byte clock from dphy to latch internal parallel bate data from dphy_rx_wrap
	//logic								clk_byte_hs_o ; 
	logic [NUM_RX_LANE - 1 :0]           lp_d_rx_p_tb_o ; 
	logic [NUM_RX_LANE - 1 :0]           lp_d_rx_n_tb_o ; 
	logic [NUM_RX_LANE*RX_GEAR - 1 :0]   bd_o ;  // csi2(byte) data from parser
	logic [47:0]							axis_srdata_tb_o ; 
	logic [47:0]                          axis_mtdata_tb_o;
	logic                                axis_stready;
	logic                                axis_mtvalid;
	logic 								sp_en_tb_o ; // short packet enable
	logic 								lp_en_tb_o ; // long packet enable 
	logic 								lp_av_en_tb_o ; // a mindle
	logic 								hs_sync_tb_o;
	
	

	logic                    			clk_byte_fr_w;     //used to connect clk_byte_fr_i to clk_byte_hs_o
	logic 								reset_tb_i_w;
	//logic                           		reset_byte_n_w;
	logic                                pixel_rst_i_w;
	//logic           reset_byte_n_i;
	
	
	logic     hsync_o;
	logic     vsync_o;
	logic [PIXEL_WIDTH - 1 :0] pixel_o;
	logic pixel_valid_o;
	logic full_o;
    logic empty_o;
    logic almost_full_o;
    logic almost_empty_o;
        
	
  /// GSR
    logic CLK_GSR = 0;
    logic USER_GSR = 1;
  /// GSR

 logic  pixel_rst_i;
 logic byte_rst_i_w;

 ///GSR
   logic GSROUT;
  ///GSR
  //logic empty_o ;
  logic dphy_clk;
	//The clk_byte_hs_o is toggling when the D-PHY clock lane is active, 
	// therefore, this can be used as the input clock clk_byte_fr_i( clock clk_byte_fr_tb_i)
	//when the source D-PHY clock is continuously running.
	
	assign clk_byte_fr_i  =   clk_byte_fr_w;
	assign clk_byte_fr_w  =   clk_byte_hs_o;
	
	assign reset_tb_i 		= 	reset_tb_i_w;
   // assign reset_byte_n_i   =   reset_byte_n_w;
	assign pixel_rst_i = pixel_rst_i_w;
	assign byte_rst_i = byte_rst_i_w;
	
    assign tx_ready_tb         = 1;  
	
	assign pll_lock_tb_i = 1;
	
	
	
	
 csi2_model #(
        .active_dphy_lanes 	(NUM_RX_LANE ),
        .RX_CLK_MODE      	(RX_CLK_MODE ),
        .DATA_COUNT       	(DATA_COUNT ),
        .num_frames       	(NUM_FRAMES ),
        .num_lines        	(NUM_LINES ),
        .num_pixels       	(NUM_PIXELS ),
        .data_type        	(data_type1),
        .dphy_clk_period     (DPHY_CLK ),
        .t_lpx           	(t_lpx ),
        .t_clk_prepare    	(t_clk_prepare ),
        .t_clk_zero       	(t_clk_zero ),
        .t_clk_pre         	(t_clk_pre ),
        .t_clk_post        	(t_clk_post ),  
        .t_clk_trail      	(t_clk_trail ),
        .t_hs_prepare     	(t_hs_prepare ),
        .t_hs_zero        	(t_hs_zero ),
        .t_hs_trail       	(t_hs_trail),
        .lps_gap          	(lps_gap ),
        .frame_gap        	(frame_gap ),
        .t_init           	(t_init ),
        .dphy_ch          	(dphy_ch ),
        .dphy_vc          	(dphy_vc),
        .long_even_line_en	(long_even_line_en ),
        .ls_le_en        	(ls_le_en ),
        .debug           	(debug)
      )
      u_csi2_model (
        .resetn           	(reset_tb_i), 
        .refclk_i         	(clk_tb_i),
        .pll_lock         	(pll_lock_tb_i),
        .clk_p_i          	(clk_p_tb),
        .clk_n_i          	(clk_n_tb),
        .do_p_i            	(do_p_tb),
        .do_n_i            	(do_n_tb),
        .csi_valid_o       	(csi_valid_tb)
      );
	  
	  
	  
//TOP LEVEL DESIGN
wrapper_test_da #(
		.NUM_RX_LANE			(NUM_RX_LANE),
		.RX_GEAR				(RX_GEAR),
		.DATA_WIDTH			(DATA_WIDTH)
	)my_wrapper(  
		// DPHY RX Submodule
	   .clk_p_i				(clk_p_tb),
	   .clk_n_i				(clk_n_tb),
	   .d_p_io				(do_p_tb),
	   .d_n_io				(do_n_tb),
	   
	   .clk_byte_fr_i		(clk_byte_fr_i ), //someone must generate it!!!
	   .reset_n_i			(reset_tb_i),  // system reset
	   .reset_byte_n_i      (reset_tb_i),
	   .reset_byte_fr_n_i	(reset_tb_i ),   // byte clk reset connect to system clock
	   .ref_dt_i				(ref_dt_tb),     // reference data type 
	   .tx_ready_i			(tx_ready_tb),   // redundant. only availabe when axi is disabled 
	   .pd_dphy_i			(pd_dphy_tb),    // only for hardened dphy block, i am going for hardened for now
	   
	   .clk_byte_o	        (clk_byte_o),
	   .clk_byte_hs_o	    (clk_byte_hs_o),
	  .lp_d_rx_p_o        (lp_d_rx_p_tb_o),
	   .lp_d_rx_n_o        (lp_d_rx_n_tb_o),
	   .bd_o                 (bd_o),
	   .axis_srdata          (axis_srdata_tb_o),
	  // .axis_stready        (axis_stready),
	   .sp_en_o              (sp_en_tb_o),
	   .lp_en_o              (lp_en_tb_o),
	   .lp_av_en_o           (lp_av_en_tb_o),
	   .hs_sync_o            (hs_sync_tb_o),
	   .axis_mtdata          (axis_mtdata_tb_o),
	   .axis_stready        (axis_stready),
	   .axis_mtvalid         (axis_mtvalid),
	   .clk_pixel_o     	    (clk_pixel_o),
	   .pll_lock_p			(pll_lock_p),
	   .vsync_o	(vsync_o), // right
	   .hsync_o  (hsync_o), // not driven correctly
	   .pixel_o(pixel_o), // not driven correctly
		.pixel_rst_i      (pixel_rst_i),
         .byte_rst_i  (byte_rst_i),
	   // for debug
	    .full_o				(full_o      	), // will use it for debug
        .empty_o				(empty_o     	) ,// will use it for debug
  //      .almost_full_o		(almost_full_o 	),  // will use it for debug//        .almost_empty_o		(almost_empty_o	) , // will use it for debug
       .rd_valid_o(pixel_valid_o)
		);

// tb clkgen
/*initial begin 
	clk_tb_i = 0;
	forever begin
		#(DPHY_CLK/2) clk_tb_i = ~clk_tb_i;
	end
end
*/ 
//figure out why above is not working

initial begin
        $timeformat(-12,0,"",10);
        //refclk_i = 0;
        clk_tb_i = 0;
		//pay_data_pass_r = 0;
        fork
		// 1st thread
          begin
			pixel_rst_i_w = 0;
			byte_rst_i_w = 0;
            reset_tb_i_w = 1;
          end
		  // 2nd thread
          begin
           
            if(DPHY_CLK%2 > 0) begin
                dphy_clk = DPHY_CLK - 1;
            end
            else begin
                dphy_clk = DPHY_CLK;
            end
            $display("%0t TEST START\n",$realtime);
            #(DPHY_CLK*12*3);
            #(INIT_DELAY); //wait initialization delay
            u_csi2_model.dphy_active = 1;
            $display("%t Activating CSI2 model\n", $time);
            @(negedge u_csi2_model.dphy_active);
            #100000;
     /*   text_comp_t;
          #10
        if (pay_data_pass_r == 1) begin
            $display("**SIMULATION PASSED**");
          end 
          else begin
            $display("**SIMULATION FAILED**");
          end */
        end
      join
        test_end;
        $finish;
    
  end 

 task test_end;
  begin
    $display("Test end");
    $stop;
  end
endtask



initial begin
	clk_tb_i = 0;
    forever begin
        #(DPHY_CLK/2);
        clk_tb_i = ~clk_tb_i;
    end
end


initial begin
    forever begin
        #5;
        CLK_GSR = ~CLK_GSR;
    end
end

GSR GSR_INST (
    .GSR_N(USER_GSR),
    .CLK(CLK_GSR)
);

// tb system rstngen
initial begin 
	reset_tb_i_w = 0;
	#(2*DPHY_CLK) reset_tb_i_w = 1;
end
	
initial begin 
	byte_rst_i_w = 1;
	#(2*DPHY_CLK) byte_rst_i_w = 0;
end	
	
	
initial begin 
	pixel_rst_i_w = 1;
	#50 pixel_rst_i_w = 0;
end	
	
initial begin
  pd_dphy_tb = 1;
  #700000;
  pd_dphy_tb = 0;
end	

// change a bit, put internal signals to pass to tb signals. dont write directly
endmodule

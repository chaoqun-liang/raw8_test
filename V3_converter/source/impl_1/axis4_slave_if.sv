

module axi4s_slave_if #(parameter DATA_WIDTH = 48)
	(
		input  logic         			axi4s_sclk_i,
		input  logic        		 		axi4s_rstn_i,
		
		input  logic       				axi4s_svalid_i,
		output logic         			axi4s_sready_o,
		
		input  logic [DATA_WIDTH-1:0]  	axi4s_sdata_i,
		output logic [DATA_WIDTH-1:0]  	axi4s_sdata_o		
	);
	
	typedef enum logic { IDLE, START } state; // idle and rx
	state state_s, next_state_s;
	logic  axi4s_handshake; // master valid and slave ready
	logic  axi4s_sready;
	//logic [DATA_WIDTH-1:0] axi4s_sdata;
	
	assign axi4s_handshake  = axi4s_svalid_i & axi4s_sready_o;
	assign axi4s_sready     = (state_s == START) ? 1'b1 : 1'b0; // slave is set to ready when in rx state
	assign axi4s_sready_o   = axi4s_sready;
	
	
	
	always_ff @(posedge axi4s_sclk_i, negedge axi4s_rstn_i) begin : sample_data 
		if(~axi4s_rstn_i) begin
			axi4s_sdata_o <= 'h0;
		end else begin
			if(axi4s_handshake) begin
				axi4s_sdata_o <= axi4s_sdata_i;
				//axi4s_sdata_o <= axi4s_sdata;
				end else
					axi4s_sdata_o <= 'h0;
					
			end
	end

				
	always_comb begin : state_logic
		  next_state_s = IDLE;
		  case(state_s)
			IDLE:  next_state_s = START;
			START: next_state_s = START;
		  endcase
	end
			

	always_ff @(posedge axi4s_sclk_i, negedge axi4s_rstn_i) begin : set_machine_state
		if (~axi4s_rstn_i) begin
			state_s <= IDLE;
		end else begin
			state_s <= next_state_s;
		end
	end
				
endmodule
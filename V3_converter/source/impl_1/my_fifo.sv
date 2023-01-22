// dual clocked fifo for byte write and pixel read
// set threshold for almost full and almost empty. 
// still room for optimization. make it work first! forza!

// make it configurable

module dc_fifo #(
	    parameter WR_WIDTH = 16,
	    parameter RD_WIDTH = 8,
	    parameter ALMOST_FULL_VALUE = 30,
		parameter ALMOST_EMPTY_VALUE = 2,
		
		
		)
	(
  port (
    i_rst_sync : in std_logic;
    i_clk      : in std_logic;
 
    -- FIFO Write Interface
    i_wr_en   : in  std_logic;
    i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
    o_full    : out std_logic;
 
    -- FIFO Read Interface
    i_rd_en   : in  std_logic;
    o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
    o_empty   : out std_logic
    );
	
	
end module_fifo_regs_no_flags;
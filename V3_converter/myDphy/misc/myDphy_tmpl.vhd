component myDphy is
    port(
        axis_mtvalid_o: out std_logic;
        axis_mtdata_o: out std_logic_vector(47 downto 0);
        axis_stready_i: in std_logic;
        clk_byte_o: out std_logic;
        clk_byte_hs_o: out std_logic;
        clk_byte_fr_i: in std_logic;
        reset_n_i: in std_logic;
        reset_byte_n_i: in std_logic;
        reset_byte_fr_n_i: in std_logic;
        clk_p_io: inout std_logic;
        clk_n_io: inout std_logic;
        d_p_io: inout std_logic_vector(1 downto 0);
        d_n_io: inout std_logic_vector(1 downto 0);
        lp_d_rx_p_o: out std_logic_vector(1 downto 0);
        lp_d_rx_n_o: out std_logic_vector(1 downto 0);
        bd_o: out std_logic_vector(15 downto 0);
        hs_sync_o: out std_logic;
        ref_dt_i: in std_logic_vector(5 downto 0);
        tx_rdy_i: in std_logic;
        pd_dphy_i: in std_logic;
        sp_en_o: out std_logic;
        lp_en_o: out std_logic;
        lp_av_en_o: out std_logic
    );
end component;

__: myDphy port map(
    axis_mtvalid_o=>,
    axis_mtdata_o=>,
    axis_stready_i=>,
    clk_byte_o=>,
    clk_byte_hs_o=>,
    clk_byte_fr_i=>,
    reset_n_i=>,
    reset_byte_n_i=>,
    reset_byte_fr_n_i=>,
    clk_p_io=>,
    clk_n_io=>,
    d_p_io=>,
    d_n_io=>,
    lp_d_rx_p_o=>,
    lp_d_rx_n_o=>,
    bd_o=>,
    hs_sync_o=>,
    ref_dt_i=>,
    tx_rdy_i=>,
    pd_dphy_i=>,
    sp_en_o=>,
    lp_en_o=>,
    lp_av_en_o=>
);

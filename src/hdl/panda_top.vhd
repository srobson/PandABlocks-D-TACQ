--------------------------------------------------------------------------------
-- File: panda_top.vhd
-- Desc: PandA top-level design
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.top_defines.all;
use work.type_defines.all;
use work.addr_defines.all;

entity panda_top is
generic (
    AXI_BURST_LEN : integer := 16;
    AXI_ADDR_WIDTH : integer := 32;
    AXI_DATA_WIDTH : integer := 32
);
port (
    DDR_addr : inout std_logic_vector (14 downto 0);
    DDR_ba : inout std_logic_vector (2 downto 0);
    DDR_cas_n : inout std_logic;
    DDR_ck_n : inout std_logic;
    DDR_ck_p : inout std_logic;
    DDR_cke : inout std_logic;
    DDR_cs_n : inout std_logic;
    DDR_dm : inout std_logic_vector (3 downto 0);
    DDR_dq : inout std_logic_vector (31 downto 0);
    DDR_dqs_n : inout std_logic_vector (3 downto 0);
    DDR_dqs_p : inout std_logic_vector (3 downto 0);
    DDR_odt : inout std_logic;
    DDR_ras_n : inout std_logic;
    DDR_reset_n : inout std_logic;
    DDR_we_n : inout std_logic;
    FIXED_IO_ddr_vrn : inout std_logic;
    FIXED_IO_ddr_vrp : inout std_logic;
    FIXED_IO_mio : inout std_logic_vector (53 downto 0);
    FIXED_IO_ps_clk : inout std_logic;
    FIXED_IO_ps_porb : inout std_logic;
    FIXED_IO_ps_srstb : inout std_logic;

    -- Slow Controller Serial interface
    spi_sclk_o : out std_logic;
    spi_dat_o : out std_logic;
    spi_sclk_i : in std_logic;
    spi_dat_i : in std_logic;

    -- RS485 Channel 0 Encoder I/O
    Am0_pad_io : inout std_logic_vector(ENC_NUM-1 downto 0);
    Bm0_pad_io : inout std_logic_vector(ENC_NUM-1 downto 0);
    Zm0_pad_io : inout std_logic_vector(ENC_NUM-1 downto 0);
    As0_pad_io : inout std_logic_vector(ENC_NUM-1 downto 0);
    Bs0_pad_io : inout std_logic_vector(ENC_NUM-1 downto 0);
    Zs0_pad_io : inout std_logic_vector(ENC_NUM-1 downto 0);

    -- Status I/O
    leds_o : out std_logic_vector(1 downto 0);
    enc0_ctrl_pad_i : in std_logic_vector(3 downto 0);
    enc0_ctrl_pad_o : out std_logic_vector(11 downto 0);

    -- Discrete I/O
    ttlin_pad_i : in std_logic_vector(TTLIN_NUM-1 downto 0);
    ttlout_pad_o : out std_logic_vector(TTLOUT_NUM-1 downto 0);
    lvdsin_pad_i : in std_logic_vector(LVDSIN_NUM-1 downto 0);
    lvdsout_pad_o : out std_logic_vector(LVDSOUT_NUM-1 downto 0)
);
end panda_top;

architecture rtl of panda_top is

component ila_0
port (
    clk : in std_logic;
    probe0 : in std_logic_vector(63 downto 0)
);
end component;

signal probe0 : std_logic_vector(63 downto 0);

-- Signal declarations
signal FCLK_CLK0 : std_logic;
signal FCLK_RESET0_N : std_logic_vector(0 downto 0);
signal FCLK_RESET0 : std_logic;
signal FCLK_LEDS : std_logic_vector(31 downto 0);

signal M00_AXI_awaddr : std_logic_vector ( 31 downto 0 );
signal M00_AXI_awprot : std_logic_vector ( 2 downto 0 );
signal M00_AXI_awvalid : std_logic;
signal M00_AXI_awready : std_logic;
signal M00_AXI_wdata : std_logic_vector ( 31 downto 0 );
signal M00_AXI_wstrb : std_logic_vector ( 3 downto 0 );
signal M00_AXI_wvalid : std_logic;
signal M00_AXI_wready : std_logic;
signal M00_AXI_bresp : std_logic_vector ( 1 downto 0 );
signal M00_AXI_bvalid : std_logic;
signal M00_AXI_bready : std_logic;
signal M00_AXI_araddr : std_logic_vector ( 31 downto 0 );
signal M00_AXI_arprot : std_logic_vector ( 2 downto 0 );
signal M00_AXI_arvalid : std_logic;
signal M00_AXI_arready : std_logic;
signal M00_AXI_rdata : std_logic_vector ( 31 downto 0 );
signal M00_AXI_rresp : std_logic_vector ( 1 downto 0 );
signal M00_AXI_rvalid : std_logic;
signal M00_AXI_rready : std_logic;

signal S_AXI_HP0_awready : std_logic := '1';
signal S_AXI_HP0_awregion : std_logic_vector(3 downto 0);
signal S_AXI_HP0_bid : std_logic_vector(5 downto 0) := (others => '0');
signal S_AXI_HP0_bresp : std_logic_vector(1 downto 0) := (others => '0');
signal S_AXI_HP0_bvalid : std_logic := '1';
signal S_AXI_HP0_wready : std_logic := '1';
signal S_AXI_HP0_awaddr : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
signal S_AXI_HP0_awburst : std_logic_vector(1 downto 0);
signal S_AXI_HP0_awcache : std_logic_vector(3 downto 0);
signal S_AXI_HP0_awid : std_logic_vector(5 downto 0);
signal S_AXI_HP0_awlen : std_logic_vector(3 downto 0);
signal S_AXI_HP0_awlock : std_logic_vector(1 downto 0);
signal S_AXI_HP0_awprot : std_logic_vector(2 downto 0);
signal S_AXI_HP0_awqos : std_logic_vector(3 downto 0);
signal S_AXI_HP0_awsize : std_logic_vector(2 downto 0);
signal S_AXI_HP0_awvalid : std_logic;
signal S_AXI_HP0_bready : std_logic;
signal S_AXI_HP0_wdata : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
signal S_AXI_HP0_wlast : std_logic;
signal S_AXI_HP0_wstrb : std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
signal S_AXI_HP0_wvalid : std_logic;

signal mem_cs : std_logic_vector(2**PAGE_NUM-1 downto 0);
signal mem_addr : std_logic_vector(PAGE_AW-1 downto 0);
signal mem_odat : std_logic_vector(31 downto 0);
signal mem_wstb : std_logic;
signal mem_rstb : std_logic;
signal mem_read_data : std32_array(2**PAGE_NUM-1 downto 0) :=
                                (others => (others => '0'));
signal mem_addr_reg : natural range 0 to (2**mem_addr'length - 1);
signal inenc_buf_ctrl : std_logic_vector(5 downto 0);
signal outenc_buf_ctrl : std_logic_vector(5 downto 0);

signal IRQ_F2P : std_logic_vector(0 downto 0);

-- Design Level Busses :
signal sysbus : sysbus_t := (others => '0');
signal posbus : posbus_t := (others => (others => '0'));
signal extbus : extbus_t := (others => (others => '0'));

-- Input Encoder
signal posn_inenc_low : std32_array(ENC_NUM-1 downto 0);
signal posn_inenc_high : std32_array(ENC_NUM-1 downto 0) := (others => (others => '0'));
signal inenc_a : std_logic_vector(ENC_NUM-1 downto 0);
signal inenc_b : std_logic_vector(ENC_NUM-1 downto 0);
signal inenc_z : std_logic_vector(ENC_NUM-1 downto 0);
signal inenc_conn : std_logic_vector(ENC_NUM-1 downto 0);
signal inenc_ctrl : std4_array(ENC_NUM-1 downto 0);

-- Output Encoder
signal outenc_conn : std_logic_vector(ENC_NUM-1 downto 0);

-- Discrete Block Outputs :
signal ttlin_val : std_logic_vector(TTLIN_NUM-1 downto 0);
signal lvdsin_val : std_logic_vector(LVDSIN_NUM-1 downto 0);
signal lut_val : std_logic_vector(LUT_NUM-1 downto 0);
signal srgate_val : std_logic_vector(SRGATE_NUM-1 downto 0);
signal div_outd : std_logic_vector(DIV_NUM-1 downto 0);
signal div_outn : std_logic_vector(DIV_NUM-1 downto 0);
signal pulse_out : std_logic_vector(PULSE_NUM-1 downto 0);
signal pulse_perr : std_logic_vector(PULSE_NUM-1 downto 0);
signal seq_outa : std_logic_vector(SEQ_NUM-1 downto 0);
signal seq_outb : std_logic_vector(SEQ_NUM-1 downto 0);
signal seq_outc : std_logic_vector(SEQ_NUM-1 downto 0);
signal seq_outd : std_logic_vector(SEQ_NUM-1 downto 0);
signal seq_oute : std_logic_vector(SEQ_NUM-1 downto 0);
signal seq_outf : std_logic_vector(SEQ_NUM-1 downto 0);
signal seq_act : std_logic_vector(SEQ_NUM-1 downto 0);

signal counter_carry : std_logic_vector(COUNTER_NUM-1 downto 0);
signal posn_counter : std32_array(COUNTER_NUM-1 downto 0);

signal pcomp_act : std_logic_vector(PCOMP_NUM-1 downto 0);
signal pcomp_pulse : std_logic_vector(PCOMP_NUM-1 downto 0);

signal panda_spbram_wea : std_logic := '0';

signal pcap_act : std_logic_vector(0 downto 0);

signal clocks_a : std_logic_vector(0 downto 0);
signal clocks_b : std_logic_vector(0 downto 0);
signal clocks_c : std_logic_vector(0 downto 0);
signal clocks_d : std_logic_vector(0 downto 0);

signal bits_zero : std_logic_vector(0 downto 0);
signal bits_one : std_logic_vector(0 downto 0);

signal bits_a : std_logic_vector(0 downto 0);
signal bits_b : std_logic_vector(0 downto 0);
signal bits_c : std_logic_vector(0 downto 0);
signal bits_d : std_logic_vector(0 downto 0);

signal posenc_a : std_logic_vector(3 downto 0) := "0000";
signal posenc_b : std_logic_vector(3 downto 0) := "0000";

signal adc_low : std32_array(7 downto 0) := (others => (others => '0'));
signal adc_high : std32_array(7 downto 0) := (others => (others => '0'));

signal slowctrl_busy : std_logic;

signal enc0_ctrl_pad : std_logic_vector(11 downto 0);

signal inenc_slow_tlp : slow_packet;
signal outenc_slow_tlp : slow_packet;

attribute keep : string;
attribute keep of sysbus : signal is "true";
attribute keep of posbus : signal is "true";

begin

-- Internal clocks and resets
FCLK_RESET0 <= not FCLK_RESET0_N(0);

--
-- Panda Processor System Block design instantiation
--
ps : entity work.panda_ps
port map (
    FCLK_CLK0 => FCLK_CLK0,
    FCLK_RESET0_N => FCLK_RESET0_N,
    FCLK_LEDS => FCLK_LEDS,

    DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
    DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
    DDR_cas_n => DDR_cas_n,
    DDR_ck_n => DDR_ck_n,
    DDR_ck_p => DDR_ck_p,
    DDR_cke => DDR_cke,
    DDR_cs_n => DDR_cs_n,
    DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
    DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
    DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
    DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
    DDR_odt => DDR_odt,
    DDR_ras_n => DDR_ras_n,
    DDR_reset_n => DDR_reset_n,
    DDR_we_n => DDR_we_n,

    FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
    FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
    FIXED_IO_ps_clk => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb => FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
    IRQ_F2P => IRQ_F2P,

    M00_AXI_araddr(31 downto 0) => M00_AXI_araddr(31 downto 0),
    M00_AXI_arprot(2 downto 0) => M00_AXI_arprot(2 downto 0),
    M00_AXI_arready => M00_AXI_arready,
    M00_AXI_arvalid => M00_AXI_arvalid,
    M00_AXI_awaddr(31 downto 0) => M00_AXI_awaddr(31 downto 0),
    M00_AXI_awprot(2 downto 0) => M00_AXI_awprot(2 downto 0),
    M00_AXI_awready => M00_AXI_awready,
    M00_AXI_awvalid => M00_AXI_awvalid,
    M00_AXI_bready => M00_AXI_bready,
    M00_AXI_bresp(1 downto 0) => M00_AXI_bresp(1 downto 0),
    M00_AXI_bvalid => M00_AXI_bvalid,
    M00_AXI_rdata(31 downto 0) => M00_AXI_rdata(31 downto 0),
    M00_AXI_rready => M00_AXI_rready,
    M00_AXI_rresp(1 downto 0) => M00_AXI_rresp(1 downto 0),
    M00_AXI_rvalid => M00_AXI_rvalid,
    M00_AXI_wdata(31 downto 0) => M00_AXI_wdata(31 downto 0),
    M00_AXI_wready => M00_AXI_wready,
    M00_AXI_wstrb(3 downto 0) => M00_AXI_wstrb(3 downto 0),
    M00_AXI_wvalid => M00_AXI_wvalid,

    S_AXI_HP0_awaddr => S_AXI_HP0_awaddr ,
    S_AXI_HP0_awburst => S_AXI_HP0_awburst,
    S_AXI_HP0_awcache => S_AXI_HP0_awcache,
    S_AXI_HP0_awid => S_AXI_HP0_awid,
    S_AXI_HP0_awlen => S_AXI_HP0_awlen,
    S_AXI_HP0_awlock => "00", --S_AXI_HP0_awlock,
    S_AXI_HP0_awprot => S_AXI_HP0_awprot,
    S_AXI_HP0_awqos => S_AXI_HP0_awqos,
    S_AXI_HP0_awready => S_AXI_HP0_awready,
    S_AXI_HP0_awsize => S_AXI_HP0_awsize,
    S_AXI_HP0_awvalid => S_AXI_HP0_awvalid,
    S_AXI_HP0_bid => S_AXI_HP0_bid,
    S_AXI_HP0_bready => S_AXI_HP0_bready,
    S_AXI_HP0_bresp => S_AXI_HP0_bresp,
    S_AXI_HP0_bvalid => S_AXI_HP0_bvalid,
    S_AXI_HP0_wdata => S_AXI_HP0_wdata,
-- S_AXI_HP0_wid => (others => '0'),
    S_AXI_HP0_wlast => S_AXI_HP0_wlast,
    S_AXI_HP0_wready => S_AXI_HP0_wready,
    S_AXI_HP0_wstrb => S_AXI_HP0_wstrb,
    S_AXI_HP0_wvalid => S_AXI_HP0_wvalid

-- S_AXI_HP0_araddr => (others => '0'),
-- S_AXI_HP0_arburst => (others => '0'),
-- S_AXI_HP0_arcache => (others => '0'),
-- S_AXI_HP0_arid => (others => '0'),
-- S_AXI_HP0_arlen => (others => '0'),
-- S_AXI_HP0_arlock => (others => '0'),
-- S_AXI_HP0_arprot => (others => '0'),
-- S_AXI_HP0_arqos => (others => '0'),
-- S_AXI_HP0_arsize => (others => '0'),
-- S_AXI_HP0_arvalid => '0',
-- S_AXI_HP0_rready => '0',
-- S_AXI_HP0_rdata => open,
-- S_AXI_HP0_rid => open,
-- S_AXI_HP0_rresp => open,
-- S_AXI_HP0_rvalid => open,
-- S_AXI_HP0_arready => open,
-- S_AXI_HP0_rlast => open
);

--
-- Control and Status Memory Interface
--
-- 0x43c00000
panda_csr_if_inst : entity work.panda_csr_if
generic map (
    MEM_CSWIDTH => PAGE_NUM,
    MEM_AWIDTH => PAGE_AW
)
port map (
    S_AXI_CLK => FCLK_CLK0,
    S_AXI_RST => FCLK_RESET0,
    S_AXI_AWADDR => M00_AXI_awaddr,
-- S_AXI_AWPROT => M00_AXI_awprot,
    S_AXI_AWVALID => M00_AXI_awvalid,
    S_AXI_AWREADY => M00_AXI_awready,
    S_AXI_WDATA => M00_AXI_wdata,
    S_AXI_WSTRB => M00_AXI_wstrb,
    S_AXI_WVALID => M00_AXI_wvalid,
    S_AXI_WREADY => M00_AXI_wready,
    S_AXI_BRESP => M00_AXI_bresp,
    S_AXI_BVALID => M00_AXI_bvalid,
    S_AXI_BREADY => M00_AXI_bready,
    S_AXI_ARADDR => M00_AXI_araddr,
-- S_AXI_ARPROT => M00_AXI_arprot,
    S_AXI_ARVALID => M00_AXI_arvalid,
    S_AXI_ARREADY => M00_AXI_arready,
    S_AXI_RDATA => M00_AXI_rdata,
    S_AXI_RRESP => M00_AXI_rresp,
    S_AXI_RVALID => M00_AXI_rvalid,
    S_AXI_RREADY => M00_AXI_rready,
    -- Bus Memory Interface
    mem_addr_o => mem_addr,
    mem_dat_i => mem_read_data,
    mem_dat_o => mem_odat,
    mem_cs_o => mem_cs,
    mem_rstb_o => mem_rstb,
    mem_wstb_o => mem_wstb
);

--
-- TTL
--
ttlin_inst : entity work.panda_ttlin_top
port map (
    clk_i => FCLK_CLK0,
    pad_i => ttlin_pad_i,
    val_o => ttlin_val
);

ttlout_inst : entity work.panda_ttlout_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,
    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(TTLOUT_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    sysbus_i => sysbus,
    pad_o => ttlout_pad_o
);

--
-- LVDS
--
lvdsin_inst : entity work.panda_lvdsin_top
port map (
    clk_i => FCLK_CLK0,
    pad_i => lvdsin_pad_i,
    val_o => lvdsin_val
);

lvdsout_inst : entity work.panda_lvdsout_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,
    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(LVDSOUT_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    sysbus_i => sysbus,
    pad_o => lvdsout_pad_o
);

--
-- 5-Input LUT
--
lut_inst : entity work.panda_lut_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,
    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(LUT_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    sysbus_i => sysbus,
    out_o => lut_val
);

--
-- 5-Input LUT
--
srgate_inst : entity work.panda_srgate_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(SRGATE_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,

    sysbus_i => sysbus,

    out_o => srgate_val
);

---------------------------------------------------------------------------
-- DIVIDER
---------------------------------------------------------------------------
DIV_GEN : IF (DIV_INST = true) GENERATE

div_inst : entity work.panda_div_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(DIV_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(DIV_CS),

    sysbus_i => sysbus,

    outd_o => div_outd,
    outn_o => div_outn
);

END GENERATE;

---------------------------------------------------------------------------
-- PULSE GENERATOR
---------------------------------------------------------------------------
PULSE_GEN : IF (PULSE_INST = true) GENERATE

pulse_inst : entity work.panda_pulse_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(PULSE_CS),
    mem_wstb_i => mem_wstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(PULSE_CS),

    sysbus_i => sysbus,

    out_o => pulse_out,
    perr_o => pulse_perr
);

END GENERATE;

---------------------------------------------------------------------------
-- SEQEUENCER
---------------------------------------------------------------------------
SEQ_GEN : IF (SEQ_INST = true) GENERATE

seq_inst : entity work.panda_sequencer_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(SEQ_CS),
    mem_wstb_i => mem_wstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(SEQ_CS),

    sysbus_i => sysbus,

    outa_o => seq_outa,
    outb_o => seq_outb,
    outc_o => seq_outc,
    outd_o => seq_outd,
    oute_o => seq_oute,
    outf_o => seq_outf,
    active_o => seq_act
);

END GENERATE;

---------------------------------------------------------------------------
-- INENC (Encoder Inputs)
---------------------------------------------------------------------------
INENC_GEN : IF (INENC_INST = true) GENERATE

inenc_inst : entity work.panda_inenc_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(INENC_CS),
    mem_wstb_i => mem_wstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(INENC_CS),

    Am0_pad_io => Am0_pad_io,
    Bm0_pad_io => Bm0_pad_io,
    Zm0_pad_io => Zm0_pad_io,

    slow_tlp_o => inenc_slow_tlp,
    ctrl_pad_i => inenc_ctrl,

    a_o => inenc_a,
    b_o => inenc_b,
    z_o => inenc_z,
    conn_o => inenc_conn,
    posn_o => posn_inenc_low
);

END GENERATE;

---------------------------------------------------------------------------
-- OUTENC (Encoder Inputs)
---------------------------------------------------------------------------
OUTENC_GEN : IF (OUTENC_INST = true) GENERATE

outenc_inst : entity work.panda_outenc_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(OUTENC_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(OUTENC_CS),

    As0_pad_io => As0_pad_io,
    Bs0_pad_io => Bs0_pad_io,
    Zs0_pad_io => Zs0_pad_io,
    conn_o => outenc_conn,

    slow_tlp_o => outenc_slow_tlp,

    sysbus_i => sysbus,
    posbus_i => posbus
);

END GENERATE;

--
-- COUNTER/TIMER
--
counter_inst : entity work.panda_counter_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(COUNTER_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(COUNTER_CS),

    sysbus_i => sysbus,
    -- Output pulse
    carry_o => counter_carry,
    count_o => posn_counter
);

---------------------------------------------------------------------------
-- POSITION COMPARE
---------------------------------------------------------------------------
PCOMP_GEN : IF (PCOMP_INST = true) GENERATE

pcomp_inst : entity work.panda_pcomp_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(PCOMP_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(PCOMP_CS),

    sysbus_i => sysbus,
    posbus_i => posbus,

    act_o => pcomp_act,
    pulse_o => pcomp_pulse
);

END GENERATE;

---------------------------------------------------------------------------
-- POSITION CAPTURE
---------------------------------------------------------------------------
PCAP_GEN : IF (PCAP_INST = true) GENERATE

pcap_inst : entity work.panda_pcap_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    m_axi_awaddr => S_AXI_HP0_awaddr,
    m_axi_awburst => S_AXI_HP0_awburst,
    m_axi_awcache => S_AXI_HP0_awcache,
    m_axi_awid => S_AXI_HP0_awid,
    m_axi_awlen => S_AXI_HP0_awlen,
    m_axi_awlock => S_AXI_HP0_awlock,
    m_axi_awprot => S_AXI_HP0_awprot,
    m_axi_awqos => S_AXI_HP0_awqos,
    m_axi_awready => S_AXI_HP0_awready,
    m_axi_awregion => S_AXI_HP0_awregion,
    m_axi_awsize => S_AXI_HP0_awsize,
    m_axi_awvalid => S_AXI_HP0_awvalid,
    m_axi_bid => S_AXI_HP0_bid,
    m_axi_bready => S_AXI_HP0_bready,
    m_axi_bresp => S_AXI_HP0_bresp,
    m_axi_bvalid => S_AXI_HP0_bvalid,
    m_axi_wdata => S_AXI_HP0_wdata,
    m_axi_wlast => S_AXI_HP0_wlast,
    m_axi_wready => S_AXI_HP0_wready,
    m_axi_wstrb => S_AXI_HP0_wstrb,
    m_axi_wvalid => S_AXI_HP0_wvalid,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs,
    mem_wstb_i => mem_wstb,
    mem_dat_i => mem_odat,
    mem_dat_0_o => mem_read_data(PCAP_CS),
    mem_dat_1_o => mem_read_data(DRV_CS),

    sysbus_i => sysbus,
    posbus_i => posbus,
    extbus_i => extbus,

    pcap_actv_o => pcap_act(0),
    pcap_irq_o => IRQ_F2P(0)
);

END GENERATE;

--
-- REG (System, Position Bus and Special Register Readbacks)
--
reg_inst : entity work.panda_reg_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(REG_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(REG_CS),

    sysbus_i => sysbus,
    posbus_i => posbus,

    slowctrl_busy_i => slowctrl_busy
);

--
-- CLOCKS
--
clocks_inst : entity work.panda_clocks_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(CLOCKS_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(CLOCKS_CS),

    clocks_a_o => clocks_a(0),
    clocks_b_o => clocks_b(0),
    clocks_c_o => clocks_c(0),
    clocks_d_o => clocks_d(0)
);

--
-- BITS
--
bits_inst : entity work.panda_bits_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(BITS_CS),
    mem_wstb_i => mem_wstb,
    mem_rstb_i => mem_rstb,
    mem_dat_i => mem_odat,

    zero_o => bits_zero(0),
    one_o => bits_one(0),
    bits_a_o => bits_a(0),
    bits_b_o => bits_b(0),
    bits_c_o => bits_c(0),
    bits_d_o => bits_d(0)
);

--
-- SLOW CONTROLLER FPGA
--
slowctrl_inst : entity work.panda_slowctrl_top
port map (
    clk_i => FCLK_CLK0,
    reset_i => FCLK_RESET0,

    mem_addr_i => mem_addr,
    mem_cs_i => mem_cs(SLOW_CS),
    mem_wstb_i => mem_wstb,
    mem_dat_i => mem_odat,
    mem_dat_o => mem_read_data(SLOW_CS),

    inenc_tlp_i => inenc_slow_tlp,
    outenc_tlp_i => outenc_slow_tlp,
    busy_o => slowctrl_busy,

    spi_sclk_o => spi_sclk_o,
    spi_dat_o => spi_dat_o,
    spi_sclk_i => spi_sclk_i,
    spi_dat_i => spi_dat_i
);

--
-- Bit assignment for System and Position busses are managed within
-- automatically generated file. The provides a robust synchronisation
-- between hardware and software layers.
--
busses_inst : entity work.panda_busses
port map (
    -- System Bus Signals
    BITS_ZERO => bits_zero,
    BITS_ONE => bits_one,
    TTLIN_VAL => ttlin_val,
    LVDSIN_VAL => lvdsin_val,
    LUT_VAL => lut_val,
    SRGATE_VAL => srgate_val,
    DIV_OUTD => div_outd,
    DIV_OUTN => div_outn,
    PULSE_OUT => pulse_out,
    PULSE_PERR => pulse_perr,
    SEQ_OUTA => seq_outa,
    SEQ_OUTB => seq_outb,
    SEQ_OUTC => seq_outc,
    SEQ_OUTD => seq_outd,
    SEQ_OUTE => seq_oute,
    SEQ_OUTF => seq_outf,
    SEQ_ACTIVE => seq_act,
    INENC_A => inenc_a,
    INENC_B => inenc_b,
    INENC_Z => inenc_z,
    INENC_CONN => inenc_conn,
    POSENC_A => posenc_a,
    POSENC_B => posenc_b,
    COUNTER_CARRY => counter_carry,
    PCOMP_ACT => pcomp_act,
    PCOMP_PULSE => pcomp_pulse,
    PCAP_ACTIVE => pcap_act,
    BITS_A => bits_a,
    BITS_B => bits_b,
    BITS_C => bits_c,
    BITS_D => bits_d,
    CLOCKS_A => clocks_a,
    CLOCKS_B => clocks_b,
    CLOCKS_C => clocks_c,
    CLOCKS_D => clocks_d,
    -- Position Bus Signals
    POSITIONS_ZERO => (others => (others => '0')),
    INENC_POSN => posn_inenc_low,
    QDEC_POSN => (others => (others => '0')),
    ADDER_RESULT => (others => (others => '0')),
    COUNTER_COUNT => posn_counter,
    PGEN_POSN => (others => (others => '0')),
    ADC_DATA => (others => (others => '0')),
    -- Bus Outputs
    bitbus_o => sysbus,
    posbus_o => posbus
);

--
-- Extended Bus : Assignments
--
extbus(3 downto 0) <= posn_inenc_high;
extbus(11 downto 4) <= adc_high;


-- Blink some LEDs on the dev board.
leds_o <= FCLK_LEDS(26 downto 25);

-- Direct interface to Daughter Card via FMC on the dev board.
enc0_ctrl_pad_o <= enc0_ctrl_pad;

inenc_ctrl(0) <= enc0_ctrl_pad_i;
inenc_ctrl(1) <= "0000";
inenc_ctrl(2) <= "0000";
inenc_ctrl(3) <= "0000";

-- Integer conversion for address.
mem_addr_reg <= to_integer(unsigned(mem_addr));

--
-- Catch PROTOCOL write to INENC0 and OUTENC0 modules.
--
REG_WRITE : process(FCLK_CLK0)
begin
    if rising_edge(FCLK_CLK0) then
        if (FCLK_RESET0 = '1') then
            inenc_buf_ctrl <= (others => '0');
            outenc_buf_ctrl <= (others => '0');
        else

            if (mem_cs(INENC_CS) = '1' and mem_wstb = '1') then
                -- DCard Input Channel Buffer Ctrl
                -- Inc : 0x03
                -- SSI : 0x0C
                -- Endat : 0x14
                -- BiSS : 0x1C
                if (mem_addr_reg = INENC_PROTOCOL) then
                    case (mem_odat(2 downto 0)) is
                        when "000" => -- INC
                            inenc_buf_ctrl <= "00" & X"3";
                        when "001" => -- SSI
                            inenc_buf_ctrl <= "00" & X"C";
                        when "010" => -- EnDat
                            inenc_buf_ctrl <= "01" & X"4";
                        when "011" => -- BiSS
                            inenc_buf_ctrl <= "01" & X"C";
                        when others =>
                            inenc_buf_ctrl <= (others => '0');
                    end case;
                end if;
            end if;

            if (mem_cs(OUTENC_CS) = '1' and mem_wstb = '1') then
                -- DCard Output Channel Buffer Ctrl
                -- Inc : 0x07
                -- SSI : 0x28
                -- Endat : 0x10
                -- BiSS : 0x18
                -- Pass : 0x07
                -- DCard Output Channel Buffer Ctrl
                if (mem_addr_reg = OUTENC_PROTOCOL) then
                    case (mem_odat(2 downto 0)) is
                        when "000" => -- INC
                            outenc_buf_ctrl <= "00" & X"7";
                        when "001" => -- SSI
                            outenc_buf_ctrl <= "10" & X"8";
                        when "010" => -- EnDat
                            outenc_buf_ctrl <= "01" & X"0";
                        when "011" => -- BiSS
                            outenc_buf_ctrl <= "01" & X"8";
                        when "100" => -- Pass
                            outenc_buf_ctrl <= "00" & X"7";
                        when others =>
                            outenc_buf_ctrl <= (others => '0');
                    end case;
                end if;
           end if;
        end if;
    end if;
end process;

-- Daughter Card Buffer Control Signals
enc0_ctrl_pad(1 downto 0) <= inenc_buf_ctrl(1 downto 0);
enc0_ctrl_pad(3 downto 2) <= outenc_buf_ctrl(1 downto 0);
enc0_ctrl_pad(4) <= inenc_buf_ctrl(2);
enc0_ctrl_pad(5) <= outenc_buf_ctrl(2);
enc0_ctrl_pad(7 downto 6) <= inenc_buf_ctrl(4 downto 3);
enc0_ctrl_pad(9 downto 8) <= outenc_buf_ctrl(4 downto 3);
enc0_ctrl_pad(10) <= inenc_buf_ctrl(5);
enc0_ctrl_pad(11) <= outenc_buf_ctrl(5);

--
-- >>>>>>>>>>>>> 1 BOARD - ENDS
--




end rtl;

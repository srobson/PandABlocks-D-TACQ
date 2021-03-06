--------------------------------------------------------------------------------
--  PandA Motion Project - 2016
--      Diamond Light Source, Oxford, UK
--      SOLEIL Synchrotron, GIF-sur-YVETTE, France
--
--  Author      : Dr. Isa Uzun (isa.uzun@diamond.ac.uk)
--------------------------------------------------------------------------------
--
--  Description : Zynq-to-Spartan6 Slow Control Interface top-level.
--                Interface is provided with dedicated SPI-like serial links.
--
--                This is a SPECIAL block, needs all _CS in order to detect
--                slow register access.
--
--                It also monitors all digital I/O status for LED management.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.top_defines.all;
use work.addr_defines.all;

entity slowcont_top is
port (
    -- Clock and Reset
    clk_i               : in  std_logic;
    reset_i             : in  std_logic;
    -- Memory Bus Interface
    read_strobe_i       : in  std_logic;
    read_address_i      : in  std_logic_vector(PAGE_AW-1 downto 0);
    read_data_o         : out std_logic_vector(31 downto 0);
    read_ack_o          : out std_logic;

    write_strobe_i      : in  std_logic_vector(MOD_COUNT-1 downto 0);
    write_address_i     : in  std_logic_vector(PAGE_AW-1 downto 0);
    write_data_i        : in  std_logic_vector(31 downto 0);
    write_ack_o         : out std_logic;
    -- Digital I/O Interface
    ttlin_i             : in  std_logic_vector(TTLIN_NUM-1 downto 0);
    ttlout_i            : in  std_logic_vector(TTLOUT_NUM-1 downto 0);
    inenc_conn_i        : in  std_logic_vector(ENC_NUM-1 downto 0);
    outenc_conn_i       : in  std_logic_vector(ENC_NUM-1 downto 0);
    -- Block Input and Outputs
    SLOW_FPGA_VERSION   : out std_logic_vector(31 downto 0);
    DCARD_MODE          : out std32_array(ENC_NUM-1 downto 0);
    -- Serial Physical interface
    spi_sclk_o          : out std_logic;
    spi_dat_o           : out std_logic;
    spi_sclk_i          : in  std_logic;
    spi_dat_i           : in  std_logic
);
end slowcont_top;

architecture rtl of slowcont_top is

-- Gather various Temperature and Voltage readouts from Slow FPGA into
-- arrays.
signal TEMP_MON         : std32_array(4 downto 0);
signal VOLT_MON         : std32_array(7 downto 0);

signal slow_reg_tlp     : slow_packet;
signal slow_leds_tlp    : slow_packet;

signal cmd_ready_n      : std_logic;

begin

-- Accept write data if FIFO is available
write_ack_o <= not cmd_ready_n;

-- Read acknowledgement to AXI Lite interface
read_ack_delay : entity work.delay_line
generic map (DW => 1)
port map (
    clk_i       => clk_i,
    data_i(0)   => read_strobe_i,
    data_o(0)   => read_ack_o,
    DELAY       => RD_ADDR2ACK
);

---------------------------------------------------------------------------
-- Slow register access interface
---------------------------------------------------------------------------
slow_registers_inst : entity work.slow_registers
port map (
    clk_i               => clk_i,
    reset_i             => reset_i,

    write_strobe_i      => write_strobe_i,
    write_address_i     => write_address_i,
    write_data_i        => write_data_i,

    slow_tlp_o          => slow_reg_tlp
);

---------------------------------------------------------------------------
-- LED information for Digital IO goes through SlowFPGA
---------------------------------------------------------------------------
led_management_inst : entity work.led_management
port map (
    clk_i               => clk_i,
    reset_i             => reset_i,

    ttlin_i             => ttlin_i,
    ttlout_i            => ttlout_i,
    inenc_conn_i        => inenc_conn_i,
    outenc_conn_i       => outenc_conn_i,

    slow_tlp_o          => slow_leds_tlp
);

---------------------------------------------------------------------------
-- Slow controller physical serial interface
---------------------------------------------------------------------------
slow_interface : entity work.slow_interface
port map (
    clk_i               => clk_i,
    reset_i             => reset_i,

    spi_sclk_o          => spi_sclk_o,
    spi_dat_o           => spi_dat_o,
    spi_sclk_i          => spi_sclk_i,
    spi_dat_i           => spi_dat_i,

    registers_tlp_i     => slow_reg_tlp,
    leds_tlp_i          => slow_leds_tlp,
    cmd_ready_n_o       => cmd_ready_n,
    SLOW_FPGA_VERSION   => SLOW_FPGA_VERSION,
    DCARD_MODE          => DCARD_MODE,
    TEMP_MON            => TEMP_MON,
    VOLT_MON            => VOLT_MON
);

---------------------------------------------------------------------------
-- Status Read process from Slow Controller
---------------------------------------------------------------------------
slow_ctrl_inst : entity work.slow_ctrl
port map (
    -- Clock and Reset
    clk_i               => clk_i,
    reset_i             => reset_i,
    sysbus_i            => (others => '0'),
    posbus_i            => (others => (others => '0')),
    -- Block Parameters
    TEMP_PSU            => TEMP_MON(0),
    TEMP_SFP            => TEMP_MON(1),
    TEMP_ENC_L          => TEMP_MON(2),
    TEMP_PICO           => TEMP_MON(3),
    TEMP_ENC_R          => TEMP_MON(4),
    ALIM_12V0           => VOLT_MON(0),
    PICO_5V0            => VOLT_MON(1),
    IO_5V0              => VOLT_MON(2),
    SFP_3V3             => VOLT_MON(3),
    FMC_15VN            => VOLT_MON(4),
    FMC_15VP            => VOLT_MON(5),
    ENC_24V             => VOLT_MON(6),
    FMC_12V             => VOLT_MON(7),
    -- Memory Bus Interface
    read_strobe_i       => read_strobe_i,
    read_address_i      => read_address_i(BLK_AW-1 downto 0),
    read_data_o         => read_data_o,
    read_ack_o          => open,

    write_strobe_i      => write_strobe_i(SLOW_CS),
    write_address_i     => write_address_i(BLK_AW-1 downto 0),
    write_data_i        => write_data_i,
    write_ack_o         => open
);

end rtl;


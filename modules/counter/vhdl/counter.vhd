--------------------------------------------------------------------------------
--  PandA Motion Project - 2016
--      Diamond Light Source, Oxford, UK
--      SOLEIL Synchrotron, GIF-sur-YVETTE, France
--
--  Author      : Dr. Isa Uzun (isa.uzun@diamond.ac.uk)
--------------------------------------------------------------------------------
--
--  Description : 32-bit programmable counter
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
port (
    -- Clock and Reset
    clk_i               : in  std_logic;
    -- Block Input and Outputs
    enable_i            : in  std_logic;
    trigger_i           : in  std_logic;
    carry_o             : out std_logic;
    -- Block Parameters
    DIR                 : in  std_logic;
    START               : in  std_logic_vector(31 downto 0);
    START_LOAD          : in  std_logic;
    STEP                : in  std_logic_vector(31 downto 0);
    -- Block Status
    out_o               : out std_logic_vector(31 downto 0)
);
end counter;

architecture rtl of counter is

signal trigger_prev     : std_logic;
signal trigger_rise     : std_logic;
signal enable_prev      : std_logic;
signal enable_rise      : std_logic;
signal counter          : unsigned(32 downto 0) := (others => '0');

begin

--------------------------------------------------------------------------
-- Input registering
--------------------------------------------------------------------------
process(clk_i)
begin
    if rising_edge(clk_i) then
        trigger_prev <= trigger_i;
        enable_prev <= enable_i;
    end if;
end process;

trigger_rise <= trigger_i and not trigger_prev;
enable_rise <= enable_i and not enable_prev;

--------------------------------------------------------------------------
-- Up/Down Counter
-- Counter keeps its last value when it is disabled and it is re-loaded
-- on the rising edge of enable input.
--------------------------------------------------------------------------
process(clk_i)
begin
    if rising_edge(clk_i) then
        -- Load the counter
        if (START_LOAD = '1') then
            counter <= unsigned('0' & START);
        -- Re-load on enable rising edge
        elsif (enable_rise = '1') then
            counter <= unsigned('0' & START);
        -- Count up/down on trigger
        elsif (enable_i = '1' and trigger_rise = '1') then
            if (DIR = '0') then
                counter <= counter + unsigned(STEP);
            else
                counter <= counter - unsigned(STEP);
            end if;
        end if;
    end if;
end process;

out_o <= std_logic_vector(counter(31 downto 0));
carry_o <= counter(32);

end rtl;

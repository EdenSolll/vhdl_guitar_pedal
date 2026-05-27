library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_REAL.all;
use work.globals.all;
use work.all;

entity pitch_shift is
    generic (
        fft_len : integer := 1024;
        n : integer := depth;
        m : integer := 24
    );
    port (
        clk           : in std_logic;
        s_axis_tdata  : in std_logic_vector(47 downto 0);
        s_axis_tvalid : in std_logic;
        s_axis_tlast  : in std_logic
    );
end entity pitch_shift;

architecture beh of pitch_shift is
    component cordic_0
      port (
        aclk : in STD_LOGIC;
        aresetn : in STD_LOGIC;
        s_axis_cartesian_tvalid : in STD_LOGIC;
        s_axis_cartesian_tlast : in STD_LOGIC;
        s_axis_cartesian_tdata : in STD_LOGIC_VECTOR(47 downto 0);
        m_axis_dout_tvalid : out STD_LOGIC;
        m_axis_dout_tlast : out STD_LOGIC;
        m_axis_dout_tdata : out STD_LOGIC_VECTOR(47 downto 0)
      );
    end component;

    type ram_24bit is array (0 to 1023) of std_logic_vector(23 downto 0);

    signal aclk : std_logic;
    signal aresetn : std_logic;
    signal s_axis_cartesian_tvalid : std_logic;
    signal s_axis_cartesian_tlast : std_logic;
    signal rectangular_tdata : std_logic_vector(47 downto 0);
    signal m_axis_dout_tvalid : std_logic;
    signal m_axis_dout_tlast : std_logic;
    signal polar_tdata : std_logic_vector(47 downto 0);

    signal magnitude_ram : ram_24bit := (others => (others => '0'));
    signal phase_ram     : ram_24bit := (others => (others => '0'));

begin

  rectangular_to_polar : cordic_0
    PORT MAP (
      aclk => aclk,
      aresetn => aresetn,
      s_axis_cartesian_tvalid => s_axis_cartesian_tvalid,
      s_axis_cartesian_tlast => s_axis_cartesian_tlast,
      s_axis_cartesian_tdata => rectangular_tdata,
      m_axis_dout_tvalid => m_axis_dout_tvalid,
      m_axis_dout_tlast => m_axis_dout_tlast,
      m_axis_dout_tdata => polar_tdata
    );

    process(clk)
      variable write_addr : integer range 0 to 1023 := 0;
    begin
        if rising_edge(clk) then
            if m_axis_dout_tvalid = '1' then
                phase_ram(write_addr)     <= polar_tdata(47 downto 24); -- top 24 bits = phase
                magnitude_ram(write_addr) <= polar_tdata(23 downto 0);  -- bottom 24 bits = magnitude
                if m_axis_dout_tlast = '1' then
                    write_addr := 0;
                else
                    write_addr := write_addr + 1;
                end if;
            end if;
        end if;
    end process;

end architecture beh;

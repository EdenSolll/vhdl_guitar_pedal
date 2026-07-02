library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.audio_stream_pkg.all; 

entity pitch_shift is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;

        -- Input frames (from polar_fft)
        phase_in     : in  t_phase_frame;     
        magnitude_in : in  t_mag_frame;       
        input_valid  : in  std_logic;        
        
        -- Output polar stream (phase + magnitude)
        m_axis  : out t_polar_forward;
        m_ready : in  std_logic;

        -- Configuration
        pitch_shift_ratio   : in signed(15 downto 0);
        inverse_pitch_shift : in unsigned(17 downto 0)
    );
end entity pitch_shift;

architecture behavioral of pitch_shift is

    type t_frac_phase_ram is array (0 to 1023) of signed(41 downto 0);

    type state_t is (IDLE, PROCESSING);

    signal current_state     : state_t := IDLE;
    signal previous_phase    : t_phase_frame := (others => (others => '0'));
    signal accumulated_phase : t_frac_phase_ram := (others => (others => '0'));
    
begin

    process (clk)
        variable write_index           : integer range 0 to 1023 := 0; 
        variable virtual_read_index    : unsigned(17 downto 0) := (others => '0');
        variable ram_index             : integer range 0 to 2047 := 0;

        variable expected_advance      : signed(23 downto 0);
        variable phase_difference      : signed(23 downto 0);
        variable phase_deviation       : signed(23 downto 0);
        variable unwrapped_phase       : signed(25 downto 0);

        variable scaled_phase          : signed(41 downto 0);
        variable new_accumulated_phase : signed(41 downto 0);

    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= IDLE;
                m_axis.valid  <= '0';
                m_axis.last   <= '0';
                previous_phase <= (others => (others => '0'));
                accumulated_phase <= (others => (others => '0'));
            else

                case current_state is

                    -- IDLE state: Wait for the FFT to finish frame
                    when IDLE =>
                        m_axis.valid <= '0';
                        m_axis.last  <= '0';
                        write_index        := 0;
                        virtual_read_index := (others => '0');

                        if input_valid = '1' then
                            current_state <= PROCESSING; -- When valid input received, trigger processing loop
                        end if;

                    -- PROCESSING state: Process 1024 bins, then stop.
                    when PROCESSING =>
                        ram_index := to_integer(virtual_read_index(17 downto 8));

                        -- DEFAULT: output silence (phase=0, mag=0)
                        m_axis.phase     <= (others => '0');
                        m_axis.magnitude <= (others => '0');
                        m_axis.valid     <= '0';
                        m_axis.last      <= '0';

                        -- process positive frequencies (bins 0 to 511)
                        -- only output non-zero data when writing to positive half 
                        if write_index < 512 and ram_index < 512 then

                            -- Calculate expected advance using the fractional pointer
                            expected_advance := signed(shift_left(resize(virtual_read_index, 24), 14));

                            -- Phase tracking math (Automatic Modulo 2*PI wrapping)
                            phase_difference := phase_in(ram_index) - previous_phase(ram_index);
                            phase_deviation  := phase_difference - expected_advance;
                            unwrapped_phase  := resize(expected_advance, 26) + resize(phase_deviation, 26);

                            scaled_phase := unwrapped_phase * pitch_shift_ratio;

                            -- Accumulate the phase into the output bin
                            new_accumulated_phase := accumulated_phase(write_index) + scaled_phase;

                            -- Save the outputs 
                            accumulated_phase(write_index) <= new_accumulated_phase;
                            previous_phase(write_index)    <= phase_in(write_index);
                            
                            -- Drive output stream if downstream is ready
                            if m_ready = '1' then
                                m_axis.phase     <= new_accumulated_phase(35 downto 12);
                                m_axis.magnitude <= magnitude_in(ram_index);
                                m_axis.valid     <= '1';
                            end if;

                        else
                            -- Drive valid when downstream is ready.
                            if m_ready = '1' then
                                m_axis.valid <= '1';
                            end if;
                        end if;

                        -- Advance Pointers
                        if write_index = 1023 then
                            -- If last sample of the frame set flag
                            if m_ready = '1' then
                                m_axis.last <= '1';
                            end if;
                            current_state <= IDLE;
                        else
                            write_index        := write_index + 1;
                            virtual_read_index := virtual_read_index + inverse_pitch_shift;
                        end if;

                    when others =>
                        current_state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end architecture behavioral;
library IEEE
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.audio_stream_pkg.all;

entity freq_pitch_shifter is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;

        s_axis  : in  t_polar_forward;
        s_ready : out std_logic;

        m_axis  : out t_polar_forward;
        m_ready : in  std_logic;

        pitch_control       : in signed(15 downto 0);
        inverse_pitch_shift : in unsigned(17 downto 0)
    );
end entity freq_pitch_shifter;

architecture behavioral of freq_pitch_shifter is

    -- BRAM components
    -- 24 bit ram block 
    component playback_ram
        port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            wea   : in  std_logic_vector(2 downto 0);
            addra : in  std_logic_vector(9 downto 0);
            dina  : in  std_logic_vector(23 downto 0);
            clkb  : in  std_logic;
            enb   : in  std_logic;
            addrb : in  std_logic_vector(9 downto 0);
            doutb : out std_logic_vector(23 downto 0)
        );
    end component;

    -- For accumulated phase 42-bit
    component acc_phase_ram
        port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            wea   : in  std_logic_vector(2 downto 0);
            addra : in  std_logic_vector(9 downto 0);
            dina  : in  std_logic_vector(41 downto 0);
            clkb  : in  std_logic;
            enb   : in  std_logic;
            addrb : in  std_logic_vector(9 downto 0);
            doutb : out std_logic_vector(41 downto 0)
        );
    end component;

    -- State machine
    type state_t is (IDLE, COLLECT, PROCESS);
    signal state : state_t;

    -- Pointers
    signal write_idx : unsigned(9 downto 0);   -- 0..1023
    signal virt_read : unsigned(17 downto 0);  -- fractional read pointer

    -- BRAM control signals
    signal input_phase_we, input_mag_we : std_logic_vector(2 downto 0);
    signal prev_phase_we, acc_phase_we   : std_logic_vector(2 downto 0);

    -- BRAM data signals (24-bit)
    signal input_phase_din, input_mag_din : std_logic_vector(23 downto 0);
    signal input_phase_dout, input_mag_dout : std_logic_vector(23 downto 0);
    signal prev_phase_dout : std_logic_vector(23 downto 0);
    signal prev_phase_din  : std_logic_vector(23 downto 0);

    -- 42-bit for accumulated phase
    signal acc_phase_din  : std_logic_vector(41 downto 0);
    signal acc_phase_dout : std_logic_vector(41 downto 0);

    -- Pipeline registers (Stage 1 → Stage 2)
    signal read_stage_valid : std_logic;
    signal read_phase  : signed(23 downto 0);
    signal read_magnitude    : signed(23 downto 0);
    signal read_prev_phase : signed(23 downto 0);
    signal read_accumulated_phase : signed(41 downto 0);
    signal stage1_write_idx : unsigned(9 downto 0);
    signal read_ram_addr   : unsigned(9 downto 0);
    signal read_expected_advance  : signed(23 downto 0);

    -- Stage 2 compute results
    signal stage2_phase_out : signed(23 downto 0);
    signal stage2_mag_out   : signed(23 downto 0);
    signal stage2_last      : std_logic;

    -- Ready handshake
    signal ready_int : std_logic;

begin

    -- BRAM Instantiations
    -- Input Phase RAM (write during COLLECT, read during PROCESS)
    input_phase_inst : playback_ram
        port map (
            clka  => clk,
            ena   => '1',
            wea   => input_phase_we,
            addra => std_logic_vector(write_idx),          -- write address (during COLLECT)
            dina  => input_phase_din,
            clkb  => clk,
            enb   => '1',
            addrb => std_logic_vector(read_ram_addr),    -- read address (during PROCESS)
            doutb => input_phase_dout
        );

    -- Input Magnitude RAM
    input_mag_inst : playback_ram
        port map (
            clka  => clk,
            ena   => '1',
            wea   => input_mag_we,
            addra => std_logic_vector(write_idx),
            dina  => input_mag_din,
            clkb  => clk,
            enb   => '1',
            addrb => std_logic_vector(read_ram_addr),
            doutb => input_mag_dout
        );

    -- Previous Phase RAM 
    prev_phase_inst : playback_ram
        port map (
            clka  => clk,
            ena   => '1',
            wea   => prev_phase_we,
            addra => std_logic_vector(stage1_write_idx),   -- write address (write_idx)
            dina  => prev_phase_din,
            clkb  => clk,
            enb   => '1',
            addrb => std_logic_vector(read_ram_addr),      -- read address (ram_index)
            doutb => prev_phase_dout
        );

    -- Accumulated Phase RAM (42-bit)
    acc_phase_inst : acc_phase_ram
        port map (
            clka  => clk,
            ena   => '1',
            wea   => acc_phase_we,
            addra => std_logic_vector(stage1_write_idx),    
            dina  => acc_phase_din,
            clkb  => clk,
            enb   => '1',
            addrb => std_logic_vector(stage1_write_idx),   
            doutb => acc_phase_dout
        );


    process (clk)
        variable ram_idx : integer range 0 to 1023;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                s_ready <= '1';
                m_axis.valid <= '0';
                m_axis.last <= '0';
                m_axis.phase <= (others => '0');
                m_axis.magnitude <= (others => '0');
                write_idx <= (others => '0');
                virt_read <= (others => '0');
                input_phase_we <= "000";
                input_mag_we <= "000";
                prev_phase_we <= "000";
                acc_phase_we <= "000";
                read_stage_valid <= '0';
                m_axis.valid <= '0';
                m_axis.last <= '0';
            else
                -- Defaults
                s_ready <= '0';
                input_phase_we <= "000";
                input_mag_we <= "000";
                prev_phase_we <= "000";
                acc_phase_we <= "000";
                m_axis.valid <= '0';
                read_stage_valid <= '0';

                case state is

                    when IDLE =>
                        s_ready <= '1';
                        write_idx <= (others => '0');
                        virt_read <= (others => '0');
                        if s_axis.valid = '1' then
                            state <= COLLECT;
                            s_ready <= '0';
                        end if;

                    when COLLECT =>
                        s_ready <= '1';
                        -- Write incoming samples to input BRAMs
                        if s_axis.valid = '1' then
                            input_phase_we <= "111";
                            input_mag_we   <= "111";
                            input_phase_din <= std_logic_vector(s_axis.phase);
                            input_mag_din   <= std_logic_vector(s_axis.magnitude);

                            if s_axis.last = '1' then
                                -- Frame complete, start processing
                                write_idx <= (others => '0');
                                virt_read <= (others => '0');
                                state <= PROCESS;
                                s_ready <= '0';
                            else
                                write_idx <= write_idx + 1;
                            end if;
                        end if;

                    when PROCESS =>
                        s_ready <= '0';
                        -- Process one bin per cycle if downstream ready
                        if m_ready = '1' then
                            -- Stage 1: set read addresses and capture expected advance
                            ram_idx := to_integer(virt_read(17 downto 8));
                            read_ram_addr <= to_unsigned(ram_idx, 10);
                            stage1_write_idx <= write_idx;
                            read_expected_advance <= signed(shift_left(resize(virt_read, 24), 14));

                            read_stage_valid <= '1';

                            -- Advance pointers for next bin
                            if write_idx = 1023 then
                            else
                                write_idx <= write_idx + 1;
                                virt_read <= virt_read + inverse_pitch_shift;
                            end if;
                        end if;

                        -- Stage 2: compute using data from BRAMs 
                        if read_stage_valid = '1' then
                            -- Read the BRAM outputs 
                            read_phase  <= signed(input_phase_dout);
                            read_magnitude    <= signed(input_mag_dout);
                            read_prev_phase <= signed(prev_phase_dout);
                            read_accumulated_phase <= signed(acc_phase_dout);

                            -- Perform calculations
                            phase_diff := read_phase - read_prev_phase;
                            phase_dev  := phase_diff - read_expected_advance;
                            unwrapped  := resize(read_expected_advance, 26) + resize(phase_dev, 26);
                            scaled_phase := unwrapped * pitch_control;
                            new_acc_phase := read_accumulated_phase + scaled_phase;

                            -- Write back to BRAMs
                            prev_phase_we <= "111";
                            prev_phase_din <= std_logic_vector(read_phase);  -- store current phase as previous for next frame
                            acc_phase_we <= "111";
                            acc_phase_din <= std_logic_vector(new_acc_phase);

                            -- Output to m_axis if downstream ready
                            if stage1_write_idx = 1023 then
                                stage2_last <= '1';
                            else
                                stage2_last <= '0';
                            end if;

                            -- Drive output
                            m_axis.phase     <= new_acc_phase(35 downto 12);
                            m_axis.magnitude <= read_magnitude;
                            m_axis.valid     <= '1';
                            m_axis.last      <= stage2_last;

                            -- If last bin, go back to IDLE state
                            if stage1_write_idx = 1023 then
                                state <= IDLE;
                                s_ready <= '1';
                            end if;
                        end if;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- Drive s_ready
    s_ready <= ready_int;

end behavioral;

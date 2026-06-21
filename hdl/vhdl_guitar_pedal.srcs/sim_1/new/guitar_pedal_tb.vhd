library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity guitar_pedal_tb is
end guitar_pedal_tb;

architecture sim of guitar_pedal_tb is

    signal clk_100mhz : std_logic := '0';
    signal rst        : std_logic := '1';
    signal pitch_idx  : std_logic_vector(2 downto 0) := "110";

    -- Pmod I2S2 DAC Outputs (We catch these to write our output file)
    signal tx_mclk, tx_lrck, tx_sclk, tx_sd : std_logic;

    -- Pmod I2S2 ADC Inputs/Outputs (We drive rx_sd based on these clocks)
    signal rx_mclk, rx_lrck, rx_sclk : std_logic;
    signal rx_sd : std_logic := '0';

    -- === NEW: Simulation Safety Control Flag ===
    signal sim_done   : boolean := false;

begin

    -- 1. System Clock (Now stops toggling when sim_done is true to freeze the kernel)
    clk_100mhz <= not clk_100mhz after 5 ns when not sim_done else '0'; -- 100 MHz

    -- 2. Instantiate the ACTUAL Top-Level Entity
    uut: entity work.guitar_pedal
        port map (
            CLK100MHZ   => clk_100mhz,
            rst         => rst,
            pitch_index => pitch_idx,
            tx_mclk     => tx_mclk,
            tx_lrck     => tx_lrck,
            tx_sclk     => tx_sclk,
            tx_sd       => tx_sd,
            rx_mclk     => rx_mclk,
            rx_lrck     => rx_lrck,
            rx_sclk     => rx_sclk,
            rx_sd       => rx_sd
        );

    -- 3. Reset Stimulus
    process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;

    -- 4. ADC Serialization Process (Reads file -> shifts bits into rx_sd)
    process
        file infile       : text open read_mode is "/home/Sol/vhdl_guitar_pedal/python_scripts/audio_input.txt";
        variable inline   : line;
        variable audio_24 : std_logic_vector(23 downto 0);
        variable bit_cnt  : integer := 0;
    begin
        wait until rst = '0';
        
        while not endfile(infile) loop
            -- Read a full 24-bit parallel sample from the text file
            readline(infile, inline);
            hread(inline, audio_24);
            
            -- Wait for the falling edge of Word Select (Start of Left Channel Frame)
            wait until falling_edge(rx_lrck);
            
            -- I2S Standard: Delayed by 1 clock cycle after WS change
            wait until falling_edge(rx_sclk);
            
            -- Shift out the 24 bits on every subsequent falling edge of SCLK
            for i in 23 downto 0 loop
                rx_sd <= audio_24(i);
                wait until falling_edge(rx_sclk);
            end loop;
            
            -- Fill the rest of the 32-bit slot with zeros (since sclk_ws_ratio is 64)
            rx_sd <= '0';
            for i in 0 to 7 loop
                wait until falling_edge(rx_sclk);
            end loop;
            
            -- (Repeat similar loop for Right channel if testing stereo, or let it be 0)
            wait until rising_edge(rx_lrck);
        end loop;
        
        -- === NEW: Trigger termination sequence ===
        sim_done <= true;
        report "Simulation Completed: All input samples processed." severity note;
        wait;
    end process;

    -- 5. DAC Deserialization Process (Catches tx_sd -> cleanly writes/closes output file)
    process
        file outfile     : text;
        variable f_status: file_open_status;
        variable outline  : line;
        variable audio_out: std_logic_vector(23 downto 0) := (others => '0');
    begin
        -- Explicitly open file handle using standard procedures
        file_open(f_status, outfile, "/home/Sol/vhdl_guitar_pedal/python_scripts/audio_output.txt", write_mode);
        
        -- Run ONLY while the input file is feeding data
        while not sim_done loop
            -- Wake up on clock edges or if the global sim_done switch flips
            wait until falling_edge(tx_lrck) or sim_done;
            
            if not sim_done then
                wait until rising_edge(tx_sclk); -- Skip first buffer bit (I2S spec offset)
                
                -- Sample the 24 bits on the rising edges of SCLK
                for i in 23 downto 1 loop
                    wait until rising_edge(tx_sclk);
                    audio_out(i) := tx_sd;
                end loop;
                
                -- Write the post audio processing 24-bit word out to your file buffer
                hwrite(outline, audio_out);
                writeline(outfile, outline);
            end if;
        end loop;
        
        file_close(outfile);
        report "Output file successfully closed and saved." severity note;
        wait;
    end process;

end sim;
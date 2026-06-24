library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globals.ALL; 
use work.ALL;

entity standard_pitch_shift is
    Port (
        clk     : in std_logic;
        rst     : in std_logic;
        sample_ready : in std_logic;
        pitch_control : in signed(15 downto 0);
        sample_in    : in signed(23 downto 0);
        sample_out   : out signed(23 downto 0)
     );
end standard_pitch_shift;

architecture Behavioral of standard_pitch_shift is
-- 16K Buffer to allow for +-24 semitone tracking (14 bits of address)
    type circular_audio_buffer is array (0 to 16383) of signed(23 downto 0);
    signal circular_buffer : circular_audio_buffer := (others => (others => '0'));
    
    signal write_ptr : unsigned(13 downto 0);
    signal addr_A : unsigned(13 downto 0);
    signal addr_B : unsigned(13 downto 0);
    
    -- 26-bit Accumulators (Top 14 bits = RAM Address, Bottom 12 bits = Fraction)
    signal read_accum_A : unsigned(25 downto 0) := (others => '0');
    signal read_accum_B : unsigned(25 downto 0) := to_unsigned(8192 * 4096, 26); -- Start B 180 degrees out of phase
    
    signal fade_counter : unsigned(7 downto 0) := (others => '0'); 
    signal fade_out_A   : std_logic := '0';
    
    signal rom_index : integer range 0 to 255 := 0;
    signal gain_B        : signed(13 downto 0);
    signal gain_A        : signed(13 downto 0);
     
    signal audio_reg_A  : signed(23 downto 0) := (others => '0');
    signal audio_reg_B  : signed(23 downto 0) := (others => '0');
    signal mult_result_A : signed(37 downto 0) := (others => '0'); 
    signal mult_result_B : signed(37 downto 0) := (others => '0');
    
    component crossfade_rom is 
        port (
            clk : in std_logic;
            fade_index : in integer range 0 to 255;
            crossfade_const : out signed(13 downto 0)
        );
    end component;
begin

    rom_inst : crossfade_rom 
        port map ( 
            clk => clk,
            fade_index => rom_index,
            crossfade_const => gain_B
        ); 
    
    gain_A <= to_signed(4096, 14) - gain_B;
    rom_index <= to_integer(fade_counter);
        
    process(clk) 
    begin 
        if rising_edge(clk) then 
            if rst = '1' then 
                write_ptr     <= (others => '0');
                read_accum_A  <= (others => '0');
                -- Re-initialize B to the halfway point on reset
                read_accum_B  <= to_unsigned(33554432, 26);
                fade_counter <= (others => '0');
                fade_out_A  <= '0';
            elsif sample_ready = '1' then
                -- update buffer with new sample
                circular_buffer(to_integer(write_ptr)) <= sample_in;
                write_ptr <= write_ptr + 1;
                -- 
                -- extract the RAM addresses from the interger portion of the accumulators
                addr_A <= read_accum_A(25 downto 12);
                addr_B <= read_accum_B(25 downto 12);
                
                -- step accumulators forward by the pitch step 
                read_accum_A <= read_accum_A + unsigned(resize(pitch_control, 26));
                read_accum_B <= read_accum_B + unsigned(resize(pitch_control, 26));
                
                -- if pointer is about to cross write head, trigger crossfade
                if (addr_A = write_ptr) and (fade_out_A = '0') then 
                    fade_out_A <= '1'; 
                    fade_counter <= (others => '0'); 
                end if; 
                
                -- move crossfade counter through 256 samples 
                if fade_out_A = '1' then 
                    if fade_counter < 255 then 
                        fade_counter <= fade_counter + 1; 
                    else 
                        fade_out_A <= '0'; 
                    end if;
                end if;
                
                audio_reg_A <= circular_buffer(to_integer(addr_A));
                audio_reg_B <= circular_buffer(to_integer(addr_B));
                
                -- 24-bit Audio * 14-bit Gain = 38-bit product
                mult_result_A <= audio_reg_A * gain_A;
                mult_result_B <= audio_reg_B * gain_B;
                
                -- truncate the 12 fractional bits of gain to scale back to 24 bits
                sample_out <= resize(mult_result_A(35 downto 12) + mult_result_B(35 downto 12), 24);
                -- NOTE: Consider implementing better quantization techniques here
                -- e.g. Digital Saturation Logic (Clipping Protection), 
                -- convergenet rounding, or First-Order Error Feedback (Dithering / Noise Shaping)
            end if; 
        end if; 
    end process;
end Behavioral;

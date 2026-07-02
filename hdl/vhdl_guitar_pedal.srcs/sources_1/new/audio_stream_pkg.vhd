library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package audio_stream_pkg is

    -- Constants
    constant C_AUDIO_WIDTH : integer := 24;
    constant C_FFT_LEN     : integer := 1024;
    constant C_BUFFER_DEPTH : integer := 16384;  -- 2^14

    -- Sample subtype
    subtype t_audio_sample is signed(C_AUDIO_WIDTH - 1 downto 0);

    -- Circular audio buffer type 
    type t_audio_buffer is array (0 to C_BUFFER_DEPTH - 1) of t_audio_sample;

    -- Sample data bundled with control signals into a record 
    type t_axis_forward is record
        data  : t_audio_sample;  -- Audio sample
        valid : std_logic;       -- '1' when 'data' is valid and should be read
        last  : std_logic;       -- '1' when sample is the last in a frame
    end record;

    -- Outgoing sample data and control signals bundled with incoming ready signal 
    type t_axis_interface is record
        forward : t_axis_forward; -- outputs from current block
        ready   : std_logic;      -- Input to current block
    end record;
    
    -- Polar streaming record, phase + magnitude bundled with control signals
    type t_polar_forward is record
        phase     : t_audio_sample;
        magnitude : t_audio_sample;
        valid     : std_logic;
        last      : std_logic;
    end record;

    -- Array Types for frame processing 
    type t_audio_frame is array (0 to C_FFT_LEN - 1) of t_audio_sample;
    type t_phase_frame is array (0 to C_FFT_LEN - 1) of signed(23 downto 0);
    type t_mag_frame   is array (0 to C_FFT_LEN - 1) of signed(23 downto 0);

    -- Helper Functions
    
    -- Checks if an incoming stream has valid data to be accepted by next block
    function is_transferring(signal axis : t_axis_interface) return boolean;

    -- This function creates an idle state for the forward record
    function idle_forward return t_axis_forward;

end package audio_stream_pkg;

-- Package Body
package body audio_stream_pkg is

    function is_transferring(signal axis : t_axis_interface) return boolean is
    begin
        -- Transfer when source is valid and destination is ready
        return (axis.forward.valid = '1' and axis.ready = '1');
    end function;

    function idle_forward return t_axis_forward is
        variable idle : t_axis_forward;
    begin
        idle.data  := (others => '0');
        idle.valid := '0';
        idle.last  := '0';
        return idle;
    end function;

end package body;
N = 1024;

n = 0:(N-1);
window = 0.5*(1-cos(2*pi*n/N));

% Convert to 24-bit signed fixed-point format

fixed_window = round(window * 8388607);

% Open a text file to write the VHDL code
fileID = fopen('hanning_rom_vhdl.txt', 'w');

fprintf(fileID, 'type window_rom_t is array (0 to 1023) of signed(23 downto 0);\n');
fprintf(fileID, 'constant HANNING_ROM : window_rom_t := (\n');

% Loop through and format as Hexadecimal
for i = 1:N
    val = fixed_window(i);

    % Handle the comma for the last element
    if i < N
        comma = ',';
    else
        comma = '';
    end

    % convert array to be 0 indexed
    vhdl_index = i - 1;

    % Write the formatted VHDL line
    fprintf(fileID, '\t%d => x"%06X"%s\n', vhdl_index, val, comma);
end

fprintf(fileID, ');\n');
fclose(fileID);

disp('Success! Open "hanning_rom_vhdl.txt" to copy VHDL code.');

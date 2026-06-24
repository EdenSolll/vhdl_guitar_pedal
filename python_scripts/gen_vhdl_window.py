import math
import sys
import argparse

def generate_hann_window(length, bits):
    """Calculates a Hann window and scales it to unsigned fixed-point precision."""
    scaled_values = []
    # Maximum value for the given bit depth (e.g., 12-bit -> 4096)
    max_val = 2**bits

    for n in range(length):
        # Standard Hann / Raised Cosine equation
        window_val = 0.5 * (1.0 - math.cos((2.0 * math.pi * n) / length))

        # Scale to fixed-point integer precision and round safely
        scaled_int = round(window_val * max_val)

        # Guard rails to ensure no rounding edge cases overflow the bit boundary
        if scaled_int > max_val:
            scaled_int = max_val
        elif scaled_int < 0:
            scaled_int = 0

        scaled_values.append(scaled_int)

    return scaled_values

def main():
    # Setup command line argument parsing
    parser = argparse.ArgumentParser(
        description="Generate arbitrary-length Hann Window ROM arrays formatted natively for VHDL."
    )
    parser.add_argument("-n", "--length", type=int, required=True, help="The number of points in the window array (e.g., 256, 1024).")
    parser.add_argument("-b", "--bits", type=int, required=True, help="The fixed-point bit precision (e.g., 12 for 12-bit unsigned scaling).")
    parser.add_argument("-o", "--output", type=str, required=True, help="The desired name of the output text file (e.g., crossfade_rom.txt).")

    args = parser.parse_args()

    # Generate the window mathematical curve
    try:
        window_data = generate_hann_window(args.length, args.bits)
    except Exception as e:
        print(f"Error generating window math: {e}")
        sys.exit(1)

    # Write and format the VHDL output file
    try:
        with open(args.output, "w") as f:
            f.write(f"-- Auto-generated Hann Window ROM Array\n")
            f.write(f"-- Parameters: Length = {args.length}, Precision = {args.bits}-bit Unsigned\n\n")

            f.write(f"type rom_type is array (0 to {args.length - 1}) of unsigned({args.bits} downto 0);\n")
            f.write(f"constant CROSSFADE_ROM : rom_type := (\n")

            for index, val in enumerate(window_data):
                comma = "," if index < (args.length - 1) else ""
                # Format perfectly as: index => to_unsigned(val, bit_width)
                f.write(f"\t{index} => to_unsigned({val}, {args.bits + 1}){comma}\n")

            f.write(f");\n")

        print(f"Success! VHDL structure written to '{args.output}'")

    except IOError as e:
        print(f"File writing error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

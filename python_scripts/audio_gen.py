import numpy as np
import scipy.io.wavfile as wav
import os

def generate_vhdl_vectors(input_wav_path, output_txt_path, target_sample_rate=96000, max_duration_seconds=0.01):
    # Check if file exists
    if not os.path.exists(input_wav_path):
        raise FileNotFoundError(f"Could not find the input file: {input_wav_path}")

    # Load and read the guitar wav file
    native_sample_rate, data = wav.read(input_wav_path)
    print(f"--- Audio Properties ---")
    print(f"Native File Sample Rate: {native_sample_rate} Hz")
    print(f"Target Hardware Expectations: {target_sample_rate} Hz")

    # Double check sample rate alignment
    if native_sample_rate != target_sample_rate:
        print(f"WARNING: WAV file is {native_sample_rate}Hz, but FPGA hardware is configured for {target_sample_rate}Hz!")
        print(f"For an accurate simulation, please use a WAV file exported natively at {target_sample_rate}Hz.")

    # Force Mono tracking if the input audio is stereo
    if len(data.shape) > 1:
        print("Stereo file detected. Extracting Left channel for mono processing...")
        data = data[:, 0]

    # Calculate how many samples match your fast simulation time threshold (10ms)
    max_allowed_samples = int(target_sample_rate * max_duration_seconds)

    if len(data) > max_allowed_samples:
        print(f"Trimming audio from {len(data)/native_sample_rate:.2f}s down to {max_duration_seconds}s...")
        print(f"This leaves exactly {max_allowed_samples} parallel samples to serialize.")
        data = data[:max_allowed_samples]
    else:
        print(f"Total simulation duration: {len(data)/native_sample_rate:.2f} seconds.")

    # Convert native integers directly to 24-bit Hex Strings and write to disk
    print(f"\nGenerating 2's complement hexadecimal vectors...")
    with open(output_txt_path, "w") as f:
        for sample in data:
            # If Audacity data came in as scaled floats, catch it and convert to 24-bit integer
            if data.dtype in [np.float32, np.float64]:
                sample = int(np.round(sample * ((1 << 23) - 1)))
            else:
                sample = int(sample)

            # Mask to a 24-bit boundaries (handles both positive and negative signed integers)
            twos_complement_val = sample & 0xFFFFFF
        
            hex_string = f"{twos_complement_val:06X}\n"
            f.write(hex_string)

    print(f"Success! Input vector file created: '{output_txt_path}'")

if __name__ == "__main__":
    input_wav = "clean_guitar.wav"
    output_txt = "audio_input.txt"

    TARGET_SR = 96000
    SIM_LIMIT_SEC = 0.01

    generate_vhdl_vectors(input_wav, output_txt, target_sample_rate=TARGET_SR, max_duration_seconds=SIM_LIMIT_SEC)

import serial
import time
import re

# --- SERIAL CONFIGURATION ---
ser = serial.Serial(
    port='/dev/ttyUSB0',              # Adjust to your actual serial port
    baudrate=115200,                  # Match your board's UART config
    stopbits=serial.STOPBITS_TWO,     # <- important!
    bytesize=serial.EIGHTBITS,
    parity=serial.PARITY_NONE,
    timeout=1                         # Read timeout in seconds
)

def read_register(address):
    # Reset buffers to prevent stale data
    ser.reset_input_buffer()
    ser.reset_output_buffer()

    # Format the command as sent via CuteCom
    cmd = f"r {address:#010x}\r\n"
    ser.write(cmd.encode('ascii'))

    # Give device a moment to respond
    time.sleep(0.1)

    # Read all lines that come in
    lines = []
    while True:
        line = ser.readline().decode('ascii').strip()
        if not line:
            break
        #print(f"Received: {line}")
        lines.append(line)

    # Try to parse the value from any line
    for line in lines:
        match = re.search(r'data:\s*0x([0-9a-fA-F]+)', line)
        if match:
            value = int(match.group(1), 16)
            return value

    raise ValueError("Could not parse value from response.")

def write_register(address, value):
    # Reset buffers to prevent stale data
    ser.reset_input_buffer()
    ser.reset_output_buffer()

    # Format the command as sent via CuteCom
    cmd = f"w {address:#010x} {value:#010x}\r\n"
    ser.write(cmd.encode('ascii'))

    # Give device a moment to respond
    time.sleep(0.1)

    # Read all lines that come in
    lines = []
    while True:
        line = ser.readline().decode('ascii').strip()
        if not line:
            break
        #print(f"Received: {line}")
        lines.append(line)

    # Try to parse the value from any line
    for line in lines:
        match = re.search(r'data:\s*0x([0-9a-fA-F]+)', line)
        if match:
            value = int(match.group(1), 16)
            return value

    raise ValueError("Could not parse value from response.")


# Example usage
if __name__ == "__main__":
    addr = 0xf000000C
    #valu = 0x00000000
    try:
        val = read_register(addr)
        print(f"\n Register {addr:#010x} = {val:#010x}")
    except ValueError as e:
        print(f"\n Error: {e}")

if __name__ == "__main__":
    addr = 0xf0000004
    valu = 0x00005555
    try:
        val = write_register(addr, valu)
        print(f"\n Register {addr:#010x} = {val:#010x}")
    except ValueError as e:
        print(f"\n Error: {e}")

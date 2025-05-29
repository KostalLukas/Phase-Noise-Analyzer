import serial

# Configuration
SERIAL_PORT = '/dev/ttyUSB0'
BAUD_RATE = 57600  # Match this to the FPGA baud rate

def main():
    try:
        with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
            print(f"Listening on {SERIAL_PORT} at {BAUD_RATE} baud...")
            
            while True:
                if ser.in_waiting:
                    byte = ser.read(1)
                    #print(f"Received byte: {byte.hex()} ({byte})")
                    for x in byte:
                        print(x)
    except serial.SerialException as e:
        print(f"Error opening serial port: {e}")

    except KeyboardInterrupt:
        print("Interrupted by user, exiting.")

if __name__ == "__main__":
    main()

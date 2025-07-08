✅ Overview of Module
Module Name: i2c_master
It performs standard I2C operations such as sending a start condition, writing an address and data, reading data, checking for acknowledgments (ACK/NACK), and issuing a stop condition. Below is a detailed analysis of its functionality:

🔌 Inputs:
clk: System clock (e.g., 40 MHz)
rst: Reset
newd: Trigger to start a new transaction
addr [6:0]: 7-bit slave address
op: Read (1) or write (0) operation
din [7:0]: Data to transmit to slave

🔌 Outputs:
scl: I2C clock
sda: I2C data (bidirectional)
dout [7:0]: Data received from slave (in read mode)
busy: High during an ongoing transaction
ack_err: High if ACK not received (NACK)
done: High when transaction completes

🧠 I2C Timing Generation
🔄 Clock Divider
Generates a 4-phase clock from the system clock (clk) for I2C timing using a counter and pulse signal.
pulse: Ranges from 0 to 3, creating four phases per bit.

Timing parameters:

sys_freq = 40_000_000  // 40 MHz system clock
i2c_freq = 100_000     // 100 kHz I2C clock
clk_count4 = 400       // 40 MHz / 100 kHz
clk_count1 = 100       // clk_count4 / 4

⚙️ State Machine
🌐 States (FSM Type: typedef enum)
idle, start, write_addr, ack_1, write_data,
read_data, stop, ack_2, master_ack

🔁 FSM Behavior Summary:
State	Description:
idle	Waits for newd. Initializes data and transitions to start.
start	Issues I2C START condition: SDA goes low while SCL is high.
write_addr	Sends 7-bit address + R/W bit.
ack_1	Checks for ACK after address.
write_data	Sends 8-bit data to slave.
read_data	Reads 8-bit data from slave.
ack_2	Waits for ACK after writing data.
master_ack	Sends NACK to slave after reading (i.e., no more read expected).
stop	Issues I2C STOP condition: SDA goes high while SCL is high.

🧾 Detailed Functional Insights
📍 START Condition
pulse 2: SDA -> 0 while SCL is high
📤 Address and Data Transmission
Uses a bitcounter to loop through 8 bits (7 address + 1 R/W, and 8-bit data).

On each bit:
SDA is set during pulse 1
SCL goes high during pulse 2

✅ ACK Handling
During ack_1 and ack_2, sda_en = 0 (releases SDA).
Slave pulls SDA low to acknowledge.
r_ack is assumed low (indicating ACK received). In a full implementation, r_ack should be sampled from sda.

⚠️ NOTE: r_ack is always 0 in this code. It does not check SDA value, so NACKs from slave aren't correctly detected.
📥 Data Reception
During read_data:
SDA is released (sda_en = 0)
Data is sampled into rx_data[7:0] during pulse 2

⚠️ Uses a specific timing check:
rx_data[7:0] <= (count1 == 200) ? {rx_data[6:0],sda} : rx_data;
This assumes data is stable at count1 == 200, which is pulse 2 midpoint.

❌ Stop Condition
SDA goes from low to high while SCL is high.

🔄 Tristate SDA Logic
assign sda = (sda_en == 1) ? (sda_t == 0) ? 1'b0 : 1'b1 : 1'bz;
When writing (sda_en = 1):

Pulls SDA low (sda_t = 0) or lets pull-up make it high.

When reading (sda_en = 0): SDA is high-Z, allowing slave to drive the line.

✅ Final Assignments
assign scl = scl_t;
assign dout = rx_data;


✅ Overview of Module
Module Name: i2c_slave
Multi-state I²C slave implemented using a 4x clocking strategy to ensure accurate sampling and generation of data on the I2C lines. It supports both read and write operations from a master, uses bidirectional sda handling via sda_en, and supports memory-mapped addressing with a 128-byte internal memory

🔍 Key Functional Blocks
1. Memory Initialization & Access (mem)
reg [7:0] mem [128];
Memory initialized on reset.

Read when r_mem = 1, write when w_mem = 1.

2. I²C Clock Pulse Generation (4x Clock)
parameter clk_count4 = (sys_freq/i2c_freq);
parameter clk_count1 = clk_count4/4;

This aids in timing-specific events like reading/writing on correct SCL edges.

3. Start Condition Detection
assign start = ~scl & scl_t;
Detects a falling edge on SCL while SDA is LOW, i.e., start condition.

4. State Machine
The core FSM manages the I²C protocol:

State	Purpose
idle	Waits for start condition
wait_p	Settles on start, prepares for address read
read_addr	Receives 7-bit address + R/W bit
send_ack1	Sends ACK after address
read_data	Receives data byte from master
send_ack2	ACK back after writing to slave
send_data	Sends data from slave to master
master_ack	Checks ACK from master
detect_stop	Waits for stop condition


🔄 Data Transfer Mechanism
A. Writing to Slave
Master sends address + W (read_addr)
Slave sends ACK (send_ack1)
Master sends data (read_data)
Slave stores data (send_ack2)

B. Reading from Slave
Master sends address + R
Slave sends ACK
Slave puts data on SDA (send_data)
Master responds with ACK/NACK (master_ack)


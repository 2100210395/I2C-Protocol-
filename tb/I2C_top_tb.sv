`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2025 23:13:07
// Design Name: 
// Module Name: i2c_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module I2C_top_tb;
 
reg clk = 0, rst = 0, newd = 0, op;
reg [6:0] addr;
reg [7:0] din;
wire [7:0] dout;
wire busy,ack_err;
wire done;
top_I2C dut (clk,rst, newd, op, addr, din, dout, busy, ack_err, done);
 
always #5 clk = ~clk;
 
initial begin
rst = 1;
repeat(5) @(posedge clk);
rst = 0;
repeat(40) @(posedge clk);
//////////// write operation
 
for(int i = 0; i < 10 ; i++)
begin
newd = 1;
op = 0;
addr = $urandom_range(1,4);
din  =  $urandom_range(1,5);
  repeat(5) @(posedge clk);
  newd <= 1'b0;
@(posedge done);
$display("[WR] din : %0d addr: %0d",din, addr);
@(posedge clk);
 
end
 
////////////read operation
 
for(int i = 0; i < 10 ; i++)
begin
newd = 1;
op = 1;
addr = $urandom_range(1,4);
din = 0;
  repeat(5) @(posedge clk);
  newd <= 1'b0;  
@(posedge done);
$display("[RD] dout : %0d addr: %0d",dout, addr);
@(posedge clk);
end
 
repeat(10) @(posedge clk);
$stop;
end
 
endmodule
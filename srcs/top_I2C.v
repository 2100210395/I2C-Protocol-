`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2025 23:31:51
// Design Name: 
// Module Name: top_I2C
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


module top_I2C(
input clk, rst, newd, op,
input [6:0] addr,
input [7:0] din,
output [7:0] dout,
output busy,ack_err,
output done
);
wire sda, scl;
wire ack_errm, ack_errs;
 
 
i2c_master master (clk, rst, newd, addr, op, sda, scl, din, dout, busy, ack_errm , done);
i2c_slave slave (scl, clk, rst, sda, ack_errs,done );
 
assign ack_err = ack_errs | ack_errm;
 
 
endmodule
 
///////////////////////////////////////////////////////
//interface i2c_if;
  
//  logic clk;
//  logic rst;
//  logic newd;
//  logic op;   
//  logic [7:0] din;
//  logic [6:0] addr;
//  logic [7:0] dout;
//  logic  done;
//  logic busy, ack_err;  
  
//endinterface


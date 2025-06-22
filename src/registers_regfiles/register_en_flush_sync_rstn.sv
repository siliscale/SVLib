///////////////////////////////////////////////////////////////////////////////
//     Copyright (c) 2025 Siliscale Consulting, LLC
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
///////////////////////////////////////////////////////////////////////////////
//           _____          
//          /\    \         
//         /::\    \        
//        /::::\    \       
//       /::::::\    \      
//      /:::/\:::\    \     
//     /:::/__\:::\    \            Vendor      : Siliscale
//     \:::\   \:::\    \           Version     : 2025.1
//   ___\:::\   \:::\    \          Description : SVLib - Register w/ Enable & Active-High Sync Reset & Flush
//  /\   \:::\   \:::\    \ 
// /::\   \:::\   \:::\____\
// \:::\   \:::\   \::/    /
//  \:::\   \:::\   \/____/ 
//   \:::\   \:::\    \     
//    \:::\   \:::\____\    
//     \:::\  /:::/    /    
//      \:::\/:::/    /     
//       \::::::/    /      
//        \::::/    /       
//         \::/    /        
//          \/____/         
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module register_en_flush_sync_rstn #(
    parameter integer WIDTH = 1,
    parameter logic [WIDTH-1:0] RESET_VAL = '0
) (
    input logic clk,
    input logic rstn,
    input logic en,
    input logic flush,

    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

  logic [WIDTH-1:0] dout_int;
  logic [WIDTH-1:0] din_int;

  assign din_int = flush ? 0 : din;
  assign dout = flush ? 0 : dout_int;


  register_en_sync_rstn #(
      .WIDTH(WIDTH),
      .RESET_VAL(RESET_VAL)
  ) u_register_en_sync_rst (
      .clk (clk),
      .rstn(rstn),
      .en  (en),
      .din (din_int),
      .dout(dout_int)
  );


endmodule

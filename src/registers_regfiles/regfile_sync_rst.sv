///////////////////////////////////////////////////////////////////////////////
//     Copyright (c) 2025 Siliscale Inc.
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
//   ___\:::\   \:::\    \          Description : SVLib - Register File w/ Sync Active-High Reset
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

module regfile_sync_rst #(
    parameter integer WIDTH    = 1,  // Width of each register
    parameter integer N_REG    = 1,  // Number of registers
    parameter integer N_RPORTS = 1,  // Number of read ports
    parameter integer N_WPORTS = 1   // Number of write ports
) (
    input logic clk,
    input logic rst,

    // Read
    input  logic [N_RPORTS-1:0][$clog2(N_REG)-1:0] raddr,
    output logic [N_RPORTS-1:0][        WIDTH-1:0] rdata,

    // Write
    input logic [N_WPORTS-1:0][$clog2(N_REG)-1:0] waddr,
    input logic [N_WPORTS-1:0]                    wen,
    input logic [N_WPORTS-1:0][        WIDTH-1:0] wdata

);

  genvar i;
  generate
    for (i = 0; i < N_REG; i++) begin : gen_reg
      register_en_sync_rst #(
          .WIDTH(WIDTH)
      ) reg_inst (
          .clk (clk),
          .rst (rst),
          .en  (wen[i] & waddr[i] == i),
          .din (wdata[i]),
          .dout(rdata[i])
      );
    end
  endgenerate

  genvar j;
  generate
    for (j = 0; j < N_RPORTS; j++) begin : gen_rport
      assign rdata[j] = rdata[raddr[j]];
    end
  endgenerate

endmodule

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
//   ___\:::\   \:::\    \          Description : SVLib - Register w/ Enable & Active-Low Async Reset
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

module register_en_async_rstn #(
    parameter integer             WIDTH     = 1,
    parameter logic   [WIDTH-1:0] RESET_VAL = '0
) (
    input logic clk,
    input logic rstn,
    input logic en,

    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      dout <= RESET_VAL;
    end else if (en) begin
      dout <= din;
    end
  end

endmodule

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
//   ___\:::\   \:::\    \          Description : SVLib - Clock Domain Crossing (CDC) Synchronizer
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


module cdc_sync #(
    parameter integer N     = 2,
    parameter integer WIDTH = 1
) (
    input  logic             clk,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

  (* ASYNC_REG = "TRUE", SILISCALE_CDC = "TRUE" *) logic [WIDTH-1:0] sync_reg[N-1:0];

  always @(posedge clk) begin
    for (int i = 0; i < N; i++) begin
      if (i == 0) begin
        sync_reg[i] <= din;
      end else begin
        sync_reg[i] <= sync_reg[i-1];
      end
    end
  end

  assign dout = sync_reg[N-1];

endmodule

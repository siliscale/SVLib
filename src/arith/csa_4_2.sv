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
//   ___\:::\   \:::\    \          Description : SVLib - Carry Save Adder (compressor) 4 to 2
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

module csa_4_2 #(
    parameter integer WIDTH = 32
) (
    input logic [WIDTH-1:0] in0,
    input logic [WIDTH-1:0] in1,
    input logic [WIDTH-1:0] in2,
    input logic [WIDTH-1:0] in3,

    output logic [WIDTH:0] sum,
    output logic [WIDTH:0] carry
);

  logic [WIDTH-1:0] sum_i;
  logic [WIDTH-1:0] carry_i;

  csa_3_2 #(
      .WIDTH(WIDTH)
  ) csa_3_2_i0 (
      .in0  (in0),
      .in1  (in1),
      .in2  (in2),
      .sum  (sum_i),
      .carry(carry_i)
  );

  csa_3_2 #(
      .WIDTH(WIDTH + 1)
  ) csa_3_2_i1 (
      .in0  ({1'b0, in3}),
      .in1  ({1'b0, sum_i}),
      .in2  ({carry_i, 1'b0}),
      .sum  (sum),
      .carry(carry)
  );

endmodule

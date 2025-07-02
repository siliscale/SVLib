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
//   ___\:::\   \:::\    \          Description : SVLib - Booth Encoder
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

module booth_encoder #(
    parameter integer WIDTH = 32
) (

    input logic           unsign,
    input logic [    2:0] multiplier,
    input logic [WIDTH:0] multiplicand,
    input logic [WIDTH:0] multiplicand_2x,
    input logic [WIDTH:0] multiplicand_neg,
    input logic [WIDTH:0] multiplicand_neg_2x,

    output logic [WIDTH:0] pp_out,
    output logic p,
    output logic s
);

  logic s_i, e_i;

  always_comb begin
    unique case (multiplier)
      3'b001:  pp_out = multiplicand;
      3'b010:  pp_out = multiplicand;
      3'b011:  pp_out = multiplicand_2x;
      3'b100:  pp_out = multiplicand_neg_2x;
      3'b101:  pp_out = multiplicand_neg;
      3'b110:  pp_out = multiplicand_neg;
      default: pp_out = {WIDTH + 1{1'b0}};
    endcase
  end


  assign s_i = multiplier[2] & ~(&multiplier[1:0]);
  assign e_i = ~((s_i ^ multiplicand[WIDTH-1]) & ~(&multiplier[2:0])) | ~(|multiplier[2:0]);

  assign p   = (unsign) ? ~s_i : e_i;
  assign s   = s_i;

endmodule

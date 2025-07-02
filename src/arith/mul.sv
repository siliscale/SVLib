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
//   ___\:::\   \:::\    \          Description : SVLib - Booth Encoded Multiplier
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

module mul #(
    parameter integer WIDTH = 16,
    parameter integer CPA_ALGORITHM = 1  // 0: RCA, 1: CLA
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             unsign,
    output logic [WIDTH-1:0] lower,
    output logic [WIDTH-1:0] upper
);

  logic [WIDTH:0] multiplicand_ext;
  logic [WIDTH:0] multiplicand_2x_ext;
  logic [WIDTH:0] multiplicand_neg_ext;
  logic [WIDTH:0] multiplicand_neg_2x_ext;

  logic [WIDTH+2:0] multiplier_ext;

  logic [2*WIDTH-1:0] pp_out[WIDTH/2:0];  // 8 + 1 extra in case is unsigned
  logic p[WIDTH/2:0];
  logic s[WIDTH/2:0];
  logic unsign_i;

  logic [2*WIDTH-1:0] correction_factor;
  logic [2*WIDTH-1:0] sum;

  assign multiplicand_ext        = {~unsign & a[WIDTH-1], a[WIDTH-1:0]};
  assign multiplicand_2x_ext     = {a[WIDTH-1:0], 1'b0};
  assign multiplicand_neg_ext    = {~(~unsign & a[WIDTH-1]), ~a[WIDTH-1:0]};
  assign multiplicand_neg_2x_ext = {~a[WIDTH-1:0], 1'b1};

  assign multiplier_ext          = {2'b0, b[WIDTH-1:0], 1'b0};

  assign unsign_i                = unsign;

  logic [2*WIDTH-1:0] pp_sum_final;
  logic [2*WIDTH-1:0] pp_carry_final;

  genvar i;
  generate
    for (i = 0; i <= WIDTH / 2; i = i + 1) begin : gen_pp_out
      logic [WIDTH:0] pp_out_i;

      if (i == 0) begin
        booth_encoder #(
            .WIDTH(WIDTH)
        ) booth_encoder_inst (
            .unsign             (unsign_i),
            .multiplier         (multiplier_ext[2:0]),
            .multiplicand       (multiplicand_ext),
            .multiplicand_2x    (multiplicand_2x_ext),
            .multiplicand_neg   (multiplicand_neg_ext),
            .multiplicand_neg_2x(multiplicand_neg_2x_ext),
            .pp_out             (pp_out_i),
            .p                  (p[i]),
            .s                  (s[i])
        );
        assign pp_out[i] = {
          {2 * WIDTH - 3 - WIDTH - 1{1'b0}}, p[i], ~p[i], ~p[i], pp_out_i[WIDTH:0]
        };
      end else begin
        booth_encoder #(
            .WIDTH(WIDTH)
        ) booth_encoder_inst (
            .unsign             (unsign_i),
            .multiplier         (multiplier_ext[2*i+2:2*i]),
            .multiplicand       (multiplicand_ext),
            .multiplicand_2x    (multiplicand_2x_ext),
            .multiplicand_neg   (multiplicand_neg_ext),
            .multiplicand_neg_2x(multiplicand_neg_2x_ext),
            .pp_out             (pp_out_i),
            .p                  (p[i]),
            .s                  (s[i])
        );

        assign pp_out[i] = {1'b1, p[i], pp_out_i[WIDTH:0], 1'b0, s[i-1]} << (2 * (i - 1));
      end
    end
  endgenerate

  assign correction_factor = (unsign_i) ?  pp_out[WIDTH/2] | {{WIDTH+1{1'b0}}, s[WIDTH/2-1], {WIDTH-2{1'b0}}} : {{WIDTH+1{1'b0}}, s[WIDTH/2-1], {WIDTH-2{1'b0}}};

  localparam NUM_LAYERS = 1 + $clog2(WIDTH / 2 / 4);
  logic [2*WIDTH-1:0] pp_sum  [NUM_LAYERS-1:0][WIDTH / 2 / 4-1:0];
  logic [2*WIDTH-1:0] pp_carry[NUM_LAYERS-1:0][WIDTH / 2 / 4-1:0];

  genvar layer;
  generate
    for (layer = 0; layer < NUM_LAYERS; layer = layer + 1) begin : gen_layer
      if (layer == 0) begin : gen_layer_0
        for (genvar lr = 0; lr < WIDTH / 2 / 4; lr = lr + 1) begin : gen_lr
          csa_4_2 #(
              .WIDTH(2 * WIDTH)
          ) csa_4_2_inst (
              .in0(pp_out[4*lr]),
              .in1(pp_out[4*lr+1]),
              .in2(pp_out[4*lr+2]),
              .in3(pp_out[4*lr+3]),  // Fast input, goes only through the 3-2 compressor
              .sum(pp_sum[layer][lr]),  // Fast, only XORs are needed
              .carry(pp_carry[layer][lr])  // Slow, AND and OR are needed
          );
        end
      end else begin : gen_layer_1
        for (genvar lr = 0; lr < WIDTH / 2 / 4 / (2 ** layer); lr = lr + 1) begin : gen_lr
          csa_4_2 #(
              .WIDTH(2 * WIDTH)
          ) csa_4_2_inst (
              .in0(pp_sum[layer-1][2*lr]),
              .in1({pp_carry[layer-1][2*lr][2*WIDTH-2:0], 1'b0}),
              .in2(pp_sum[layer-1][2*lr+1]),
              .in3({
                pp_carry[layer-1][2*lr+1][2*WIDTH-2:0], 1'b0
              }),  // Fast input, goes only through the 3-2 compressor
              .sum(pp_sum[layer][lr]),  // Fast, only XORs are needed
              .carry(pp_carry[layer][lr])  // Slow, AND and OR are needed
          );
        end
      end
    end
  endgenerate

  assign pp_sum_final   = pp_sum[NUM_LAYERS-1][0];
  assign pp_carry_final = pp_carry[NUM_LAYERS-1][0];

  logic [2*WIDTH-1:0] pp_sum_correction;
  logic [2*WIDTH-1:0] pp_carry_correction;

  csa_3_2 #(
      .WIDTH(2 * WIDTH)
  ) csa_3_2_inst (
      .in0  (pp_sum_final),
      .in1  ({pp_carry_final[2*WIDTH-2:0], 1'b0}),
      .in2  (correction_factor),
      .sum  (pp_sum_correction),
      .carry(pp_carry_correction)
  );

  /* Carry-Propagate Adder */
  adder #(
      .WIDTH    (2 * WIDTH),
      .ALGORITHM(CPA_ALGORITHM)
  ) adder_inst (
      .in0(pp_sum_correction),
      .in1({pp_carry_correction[2*WIDTH-2:0], 1'b0}),
      .sum(sum)
  );
  assign lower = sum[WIDTH-1:0];
  assign upper = sum[2*WIDTH-1:WIDTH];

endmodule

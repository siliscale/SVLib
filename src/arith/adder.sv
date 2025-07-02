module adder #(
    parameter integer WIDTH,
    parameter integer ALGORITHM // 0: Ripple-Carry, 1: Carry-Look-Ahead
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    output logic [  WIDTH:0] sum
);

  generate
    if (ALGORITHM == 0) begin  /* Ripple-Carry Adder */
      logic [WIDTH:0] sum_i;
      logic [WIDTH:0] carry_i;

      for (genvar i = 0; i < WIDTH; i = i + 1) begin
        if (i == 0) begin
          ha ha_inst (
              .a   (in0[i]),
              .b   (in1[i]),
              .sum (sum_i[i]),
              .cout(carry_i[i])
          );
        end else begin
          fa fa_inst (
              .a   (in0[i]),
              .b   (in1[i]),
              .cin (carry_i[i-1]),
              .sum (sum_i[i]),
              .cout(carry_i[i])
          );
        end
      end
      assign sum = sum_i;
    end else if (ALGORITHM == 1) begin  /* Carry-Look-Ahead Adder */
      logic [WIDTH:0] generate_i;
      logic [WIDTH:0] propagate_i;
      logic [WIDTH:0] carry_i;
      logic [WIDTH:0] sum_i;

      for (genvar i = 0; i < WIDTH; i = i + 1) begin
        assign generate_i[i]  = in0[i] & in1[i];  // G_i
        assign propagate_i[i] = in0[i] ^ in1[i];  // P_i
      end

      for (genvar i = 0; i < WIDTH; i = i + 1) begin
        if (i == 0) begin
          assign carry_i[i] = generate_i[i];
          assign sum_i[i]   = propagate_i[i]; 
        end else begin
          assign carry_i[i] = generate_i[i] | (propagate_i[i] & carry_i[i-1]);
          assign sum_i[i]   = propagate_i[i] ^ carry_i[i-1];
        end
      end
      assign sum = sum_i;
    end
  endgenerate
endmodule


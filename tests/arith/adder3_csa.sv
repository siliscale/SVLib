module adder3_csa #(
    parameter integer WIDTH = 32
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    output logic [  WIDTH:0] sum
);

  logic [WIDTH:0] sum_i;
  logic [WIDTH:0] carry_i;

  csa_3_2 #(
      .WIDTH(WIDTH)
  ) csa_3_2_inst (
      .in0  (in0),
      .in1  (in1),
      .in2  (in2),
      .sum  (sum_i),
      .carry(carry_i)
  );

  assign sum = sum_i + carry_i;
endmodule

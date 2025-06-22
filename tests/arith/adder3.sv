module adder3 #(
    parameter integer WIDTH = 32
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    output logic [  WIDTH:0] sum
);

  assign sum = {1'b0, in0} + {1'b0, in1} + {1'b0, in2};

endmodule

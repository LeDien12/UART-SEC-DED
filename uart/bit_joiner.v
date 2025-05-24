module bit_joiner #(
  parameter LOW_WIDTH  = 4,
  parameter HIGH_WIDTH = 4
) (
  input  wire [LOW_WIDTH-1:0]  low_bits,
  input  wire [HIGH_WIDTH-1:0] high_bits,
  input  wire                  low_ok,
  input  wire                  high_ok,
  output wire 						 join_ok,
  output wire [LOW_WIDTH+HIGH_WIDTH-1:0] data_out
);

assign data_out = (low_ok && high_ok) ? {high_bits, low_bits} : {LOW_WIDTH+HIGH_WIDTH{1'b0}};
assign join_ok = low_ok & high_ok;

endmodule

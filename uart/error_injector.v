module error_injector (
  input  wire [8-1:0] data_in_er,
  input  wire         enable,
  input  wire [8-1:0] error_mask, // Ví dụ: 8'b00010000 để lật bit 4
  output wire [8-1:0] data_out
);

  assign data_out = enable ? (data_in_er ^ error_mask) : data_in_er;

endmodule
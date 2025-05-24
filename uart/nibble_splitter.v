module nibble_splitter(
  input  wire [7:0] data_in,     // Byte đầu vào
  output wire [3:0] low_nibble,  // 4 bit thấp
  output wire [3:0] high_nibble  // 4 bit cao
);
  assign low_nibble  = data_in[3:0];
  assign high_nibble = data_in[7:4];
endmodule
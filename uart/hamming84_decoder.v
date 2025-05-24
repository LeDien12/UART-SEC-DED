// Hamming(8,4) decoder: tự động sửa 1 bit lỗi, báo lỗi 2 bit
// Codeword format (bit 7 … bit 0): { p3, d3, d2, d1, p2, d0, p1, p0 }
module hamming84_decoder(
    input  wire [7:0] code_in,        // 8‐bit codeword nhận được
    output reg  [3:0] data_out,       // 4‐bit dữ liệu sau giải mã
    output reg        error_corrected,// =1 nếu đã sửa 1 bit
    output reg        double_error    // =1 nếu phát hiện lỗi 2 bit
);

  // Tính các bit syndrome cho Hamming(7,4)
  // (chỉ dùng p0,p1,p2; p3 là parity tổng)
  wire s0 = code_in[0] ^ code_in[2] ^ code_in[4] ^ code_in[6];  // kiểm nhóm bit 1,3,5,7
  wire s1 = code_in[1] ^ code_in[2] ^ code_in[5] ^ code_in[6];  // kiểm nhóm bit 2,3,6,7
  wire s2 = code_in[3] ^ code_in[4] ^ code_in[5] ^ code_in[6];  // kiểm nhóm bit 4,5,6,7

  wire [2:0] syndrome = {s2, s1, s0};  // vị trí bit lỗi (1..7) nếu ≠0

  // Tính parity tổng p3
  wire overall_parity = ^code_in;      // XOR tất cả 8 bit

  // Nếu syndrome≠0 và overall_parity=1 ⇒ 1 bit dữ liệu/parity p0–p2 lỗi
  // Nếu syndrome=0  và overall_parity=1 ⇒ lỗi ở bit p3
  // Nếu syndrome≠0 và overall_parity=0 ⇒ 2 bit lỗi → phát hiện nhưng không sửa
  wire two_bit_err = (syndrome != 3'b000) && (overall_parity == 1'b0);
  wire single_bit_err = overall_parity == 1'b1;

  reg [7:0] corrected;

  always @* begin
    // Mặc định giữ nguyên codeword, xóa cờ
    corrected       = code_in;
    error_corrected = 1'b0;
    double_error    = 1'b0;

    if (two_bit_err) begin
      // Phát hiện lỗi 2 bit → không sửa, chỉ báo
      double_error = 1'b1;
    end
    else if (single_bit_err) begin
      // Sửa 1 bit lỗi
      if (syndrome != 3'b000) begin
        // Lỗi ở một trong các bit vị trí 1..7
        corrected[syndrome-1] = ~corrected[syndrome-1];
      end else begin
        // syndrome=0 mà parity tổng sai → lỗi ở bit p3 (vị trí 8)
        corrected[7] = ~corrected[7];
      end
      error_corrected = 1'b1;
    end

    // Xuất 4 bit dữ liệu đã được sửa (d3..d0)
    data_out = { corrected[6],  // d3
                 corrected[5],  // d2
                 corrected[4],  // d1
                 corrected[2]   // d0
               };
  end

endmodule

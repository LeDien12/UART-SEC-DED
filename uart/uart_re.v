module uart_re#(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 16,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
            SYS_FREQ        = 50000000,
            BAUD_RATE       = 115200,//921600,
            CLOCK           = SYS_FREQ/BAUD_RATE,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )  (
  input                       clk               ,
  input                       reset_n           ,
  input                       rx                ,
  input								read_en,
  output      [7:0]           out_rx             ,
  output		reg  [7:0]				real_output,
  output      [2:0]           RX_status_register,
  output      [7:0]           rx_data_out,
  output      [3:0]           sub_low_de1,
  output      [3:0]           sub_high_de1,
  output 	  [7:0]           mstate,
  output 	[9:0]				dout,
  output   wire double_error,
  output   wire error_corrected,
  output      h_ok,
  output 	  l_ok,
  output			join_ok,
  output			s_tick,
  output			wait_request,
  output reg wait_req,
	output reg read_latch
);
// Internal signals
////wire [DATA_SIZE-1:0] rx_data_out;
wire [DATA_SIZE-1:0] bus_data_out;
wire                 rx_done;
wire                 rx_full;
wire                 rx_empty;
reg                  fifo_rx_rd;

reg [7:0] real_output_reg;


// Decoder + Bit Joiner
wire double_error_l, double_error_h,  error_corrected_l, error_corrected_h;
reg  [7:0]	         bus_data_out_high;
reg  [7:0]	         bus_data_out_low;
wire  [3:0]           sub_low_de;
wire  [3:0]           sub_high_de;
assign sub_low_de1 = sub_low_de;
assign sub_high_de1 = sub_high_de;
reg  [1:0]           state;
//wire  [7:0]           out_rx;
//wire join_ok;
reg low_ok;
reg high_ok;
assign h_ok = high_ok;
assign l_ok = low_ok;
assign double_error = double_error_h || double_error_l;
assign error_corrected = error_corrected_h||error_corrected_l;
assign outrx = out_rx;
assign RX_status_register = {rx_done, rx_empty, rx_full};
wire [9:0] data_in_fifo;
reg condition;

// Sampling clock
uart_sampling_tick #(
  .SYS_FREQ   (SYS_FREQ),
  .BAUD_RATE  (BAUD_RATE),
  .CLOCK      (CLOCK),
  .SAMPLE     (SAMPLE),
  .BAUD_DVSR  (BAUD_DVSR)
) uart_sampling_tick_inst (
  .clk      (clk),
  .reset_n  (reset_n),
  .s_tick   (s_tick)
);

// UART RX
uart_rx #(
  .DATA_SIZE (DATA_SIZE)
) uart_rx_inst (
  .clk          (clk),
  .s_tick       (s_tick),
  .reset_n      (reset_n),
  .rx_start     (~rx_full),
  .rx           (rx),
  .data_out     (rx_data_out),
  .rx_done_tick (rx_done)
);

// FIFO RX
uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO)
) uart_fifo_rx (
  .clk     (clk),
  .s_tick  (s_tick),
  .reset_n (reset_n),
  .w_data  (rx_data_out),
  .r_data  (bus_data_out),
  .wr      (rx_done),
  .rd      (fifo_rx_rd),
  .full    (rx_full),
  .empty   (rx_empty)
);



// Hamming decoder
hamming84_decoder rx_high (
  .code_in  (bus_data_out_high),
  .data_out (sub_high_de),
  .error_corrected (error_corrected_h),
  .double_error (double_error_h)
  
  
);

hamming84_decoder rx_low (
  .code_in  (bus_data_out_low),
  .data_out (sub_low_de),
  .error_corrected (error_corrected_l),
  .double_error (double_error_l)
  
);


// Bit joiner
bit_joiner join_rx (
  .high_ok	 (high_ok),
  .low_ok	 (low_ok),
  .low_bits  (sub_low_de),
  .high_bits (sub_high_de),
  .data_out  (out_rx),
  .join_ok (join_ok)
);

//fifo_8x8 fifo(
//		 .clk(s_tick),
//		 .rst_n(reset_n),
//		 .din(data_in_fifo),
//		 .wr_en(join_ok),
//		 .full(),  
//		 .dout(dout),
//		 .rd_en(read_en), 
//		 .empty()
//	 );


uart_fifo_out #(
  .DATA_SIZE (10),
  .SIZE_FIFO (SIZE_FIFO)
) uart_fifo_out (
  .clk     (clk),
  .s_tick  (s_tick),
  .reset_n (reset_n),
  .w_data  (data_in_fifo),
  .r_data  (dout),
  .wr      (join_ok),
  .rd      (wait_req),
  .full    (),
  .empty   ()
);

// FSM để đọc từ FIFO và giải mã
always @(posedge clk or negedge reset_n) begin
  if (!reset_n) 
	  begin
		 fifo_rx_rd    <= 0;
		 state         <= 4;
		 wait_req 		<= 0;
		 read_latch <= 0;
	  end 
  else
	  begin
			if (read_en)
				read_latch <= 1;
				wait_req <= read_latch;	
		  if(s_tick)  
			begin
				read_latch <= 0;
				 fifo_rx_rd <= 0;
				 if (join_ok) 
					 begin 
						 low_ok<=0;high_ok<=0; state <= 0; 
						 bus_data_out_low<=0;
						 bus_data_out_high<=0;
					 end
				 case (state)
					0: begin
					  if (!rx_empty) 
						  begin
							 fifo_rx_rd     <= 1;
							 bus_data_out_low <= bus_data_out;
							 low_ok <=1;
							 state          <= 1;
						  end
						end
						
					1: begin
					 // sub_low_de <= sub_highlow_de;  
					 if(rx_done) 
						 begin 
							state      <= 2;
						 end
						end
						
					2: begin
					  if (!rx_empty) 
						  begin
								fifo_rx_rd     <= 1;
								// sub_highlow_en <= bus_data_out;
								bus_data_out_high <= bus_data_out;
								high_ok <=1;
								state          <= 3;
						  end
					end
					
					3: begin
						//low_ok<=0;high_ok<=0;
							state       <= 4; // quay về để xử lý dữ liệu tiếp theo
						end
				 endcase
			  end
		end
end


assign mstate = state;

	assign wait_request = (read_en && wait_req);
	assign data_in_fifo = {double_error,error_corrected,out_rx};

endmodule
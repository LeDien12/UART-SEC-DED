module fifo_8x8 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [9:0] din,
    input  wire       wr_en,  
    output wire       full,   
    output wire [9:0] dout,
    input  wire       rd_en,  
    output wire       empty
);

    reg [9:0] mem [7:0];
    
    reg [4:0] wptr, rptr;
   
    assign full  = (wptr == 8);
    assign empty = (wptr == rptr );


    reg [9:0] dout_reg;
    assign dout = dout_reg;

    always @(posedge clk ) begin
        if(!rst_n) begin
            wptr     <= 0;
            rptr     <= 0;
            dout_reg <= 10'h00;
        end else begin

            if(wr_en && !full) begin
                mem[wptr] <= din;
                wptr <= wptr + 1;
            end

            if(rd_en && !empty) begin
                dout_reg <= mem[rptr];
                rptr <= rptr + 1;
            end
				
				if(full && empty) begin
					 wptr     <= 0;
					 rptr     <= 0;
				end
        end
    end

endmodule

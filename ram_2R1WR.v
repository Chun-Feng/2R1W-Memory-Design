module ram_2R1WR(
clk, rst,
we, addrw, dinw, doutw,
addr1, dout1,
addr2, dout2
);

input clk;
input rst;

input we;

input [10:0] addrw, addr1, addr2;
input [31:0] dinw;
output reg [31:0] dout1, dout2, doutw;
//////////////////////////////

reg b1_wea, b2_wea, bx_wea;

reg [9:0] b1_addra, b1_addrb, b2_addra, b2_addrb, bx_addra, bx_addrb;
reg [31:0] b1_dina, b2_dina, bx_dina;
wire [31:0] b1_douta, b1_doutb, b2_douta, b2_doutb, bx_douta, bxor_doutb;

reg [1:0] mode_2R1W_w, mode_2R1W;
reg [10:0] current_addr, forward_xor_addr;
reg [10:0] forward_addr2;
reg [31:0] dinw_delay;
reg [31:0] forward_xor;
reg forward_xor_we;

blk_mem_gen_v7_2 bank1(
  .clka(clk),
  .wea(b1_wea),
  .addra(b1_addra),
  .dina(b1_dina),
  .douta(b1_douta),
  .clkb(clk),
  .web(1'b0),
  .addrb(b1_addrb),
  .dinb(),
  .doutb(b1_doutb)
);

blk_mem_gen_v7_2 bank2(
  .clka(clk),
  .wea(b2_wea),
  .addra(b2_addra),
  .dina(b2_dina),
  .douta(b2_douta),
  .clkb(clk),
  .web(1'b0),
  .addrb(b2_addrb),
  .dinb(),
  .doutb(b2_doutb)
);


blk_mem_gen_v7_2 bankxor(
  .clka(clk),
  .wea(bx_wea),
  .addra(bx_addra),
  .dina(bx_dina),
  .douta(bx_douta),
  .clkb(clk),
  .web(1'b0),
  .addrb(bx_addrb),
  .dinb(),
  .doutb(bxor_doutb)
);

always@(*)
begin
	/////////1WR PORT/////////
	b1_dina = dinw;
	b2_dina = dinw;
	b1_addra = addrw[9:0];
	b2_addra = addrw[9:0];
	b1_wea = (~addrw[10]) & we;
	b2_wea = addrw[10] & we;
	doutw = current_addr[10]? b2_douta : b1_douta;
	bx_dina = dinw_delay ^ (current_addr[10]?b1_douta:b2_douta);
	bx_addra = current_addr[9:0];

	/////////INPUT/////////
	if ( addr1[10] == 0 && addr2[10] == 0)
	begin
		b1_addrb = addr1[9:0];
		b2_addrb = addr2[9:0];
		bx_addrb = addr2[9:0];
		mode_2R1W_w = 2'b00;
	end
	else if ( addr1[10] == 0 && addr2[10] == 1)
	begin
		b1_addrb = addr1[9:0];
		b2_addrb = addr2[9:0];
		bx_addrb = addr2[9:0];//NONE
		mode_2R1W_w = 2'b01;
	end
	else if ( addr1[10] == 1 && addr2[10] == 0)
	begin
		b1_addrb = addr2[9:0];
		b2_addrb = addr1[9:0];
		bx_addrb = addr2[9:0];//NONE
		mode_2R1W_w = 2'b10;
	end
	else if ( addr1[10] == 1 && addr2[10] == 1)
	begin
		b1_addrb = addr2[9:0];
		b2_addrb = addr1[9:0];
		bx_addrb = addr2[9:0];
		mode_2R1W_w = 2'b11;
	end
	/////////OUTPUT/////////
	if (mode_2R1W == 2'b00)
	begin
		dout1 = b1_doutb;
		dout2 = (forward_xor_addr[9:0] == forward_addr2[9:0] && forward_xor_we)?
					b2_doutb ^ forward_xor : b2_doutb ^  bxor_doutb;
	end
	else if (mode_2R1W == 2'b01)
	begin
		dout1 = b1_doutb;
		dout2 = b2_doutb;
	end
	else if (mode_2R1W == 2'b10)
	begin
		dout1 = b2_doutb;
		dout2 = b1_doutb;
	end
	else if (mode_2R1W == 2'b11)
	begin
		dout1 = b2_doutb;
		dout2 = (forward_xor_addr[9:0] == forward_addr2[9:0] && forward_xor_we)?
					b1_doutb ^ forward_xor : b1_doutb ^ bxor_doutb;
	end
end

always@(posedge clk or negedge rst) begin

    if(!rst)
	begin
		mode_2R1W <= 0;
		dinw_delay <= 0;
		current_addr <= 0;
		bx_wea <= 0;
		forward_xor <= 0;
		forward_xor_addr <= 0;
		forward_xor_we <= 0;
    end

    else
	begin
		mode_2R1W <= mode_2R1W_w;
		dinw_delay <= dinw;
		current_addr <= addrw[10:0];
		bx_wea <= we;
		forward_addr2 <= addr2;
		forward_xor <= bx_dina;
		forward_xor_addr <= current_addr;
		forward_xor_we <= bx_wea;
	end

end

endmodule

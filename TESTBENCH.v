
`include "PATTERN.v"
`include "ram_2R1WR.v"


module TESTBENCH();
initial begin

//    $fsdbDumpfile("core.fsdb");
//    $fsdbDumpvars;

//    $dumpfile("core.vcd");
//    $dumpvars;
end

wire        clk;
wire        rst;
wire        en_r0, en_r1, en_w0;
wire [10:0] r1_addr, r2_addr, w0_addr; 
wire [31:0] d0,d1,d2,dw;
 
PATTERN u_pattern(
.clk(clk), 
.rst(rst), 
.en_w0(en_w0), 
.w0_addr(w0_addr), 
.dw(dw),
.r1_addr(r1_addr), 
.r2_addr(r2_addr), 
.d0(d0), 
.d1(d1), 
.d2(d2) 
);

ram_2R1W ram(
.clk(clk),
.rst(rst),
.we(en_w0),
.addrw(w0_addr),
.dinw(d0),
.doutw(dw),
.addr1(r1_addr),
.dout1(d1), 
.addr2(r2_addr), 
.dout2(d2)

);

endmodule









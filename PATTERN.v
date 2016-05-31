
`define CLK_PERIOD  10.0

module PATTERN(
clk, 
rst, 
en_w0, 
r1_addr, 
r2_addr, 
w0_addr, 
dw,
d0,
d1,
d2
);




output reg clk;
output reg rst;
output reg en_w0;
output reg [10:0] r1_addr, r2_addr, w0_addr;
output reg [31:0] d0;
input [31:0] d1, d2, dw;

integer mem[0:2047];

integer i,ccc, times;


integer seed;

always #(`CLK_PERIOD/2.0) clk = ~clk;


initial begin
clk=0;
rst=1;
en_w0 = 0;
    r1_addr=0;
    r2_addr= 0;
    w0_addr= 0;
d0=0;
seed=0;
ccc=0;
times=0;


for( i=0 ; i<2048; i=i+1)
    mem[i]=0;


@(negedge clk);
rst = 0;


@(negedge clk);
rst = 1;

@(negedge clk);

while(times<100000000) begin


while(ccc==0) begin

    r1_addr= $random(seed);
    r2_addr= $random(seed);
    w0_addr= $random(seed);



    en_w0 = $random(seed);

//    if( (r0_addr!=r1_addr) &  (r0_addr!=w0_addr) & (r0_addr!=w1_addr)& (r0_addr!=w2_addr)& (r0_addr!=w3_addr)& (r1_addr!=w0_addr) & (r1_addr!=w1_addr)& (r1_addr!=w2_addr)& (r1_addr!=w3_addr) & (w0_addr!=w1_addr) & (w0_addr!=w2_addr)& (w0_addr!=w3_addr)& (w1_addr!=w2_addr)& (w1_addr!=w3_addr)& (w2_addr!=w3_addr))
        ccc=1;

end

ccc=0;
d0[31:8]=0;
d0[7:0]= $random;


@(negedge clk);

$display("%d|w_a=%d,w_d=%d,w_dw=%d,w_en=%d|R1_a=%d,R1_d=%d|R2_a=%d,R2_d=%d",times,w0_addr,d0,dw,en_w0,r1_addr,d1,r2_addr,d2);

    if(d1!==mem[r1_addr]) begin
     
        $display("ERROR:, R1 address = %d, golden answer is %d, your is %d",r1_addr, mem[r1_addr], d1);
        @(negedge clk);
        @(negedge clk);
        $finish;
    end
    
    if(d2!==mem[r2_addr]) begin
     
        $display("ERROR:, R2 address = %d, golden answer is %d, your is %d",r2_addr,mem[r2_addr], d2);
        @(negedge clk);
        @(negedge clk);
        $finish;
        end

    if(dw!==mem[w0_addr]) begin
     
        $display("ERROR:, Wd address = %d, golden answer is %d, your is %d",w0_addr,mem[w0_addr], dw);
        @(negedge clk);
        @(negedge clk);
        $finish;
        end

if(en_w0)
    mem[w0_addr]=d0;
 
times=times+1;

if( times%100000 == 0 ) begin
    $display("%d",times);
    //seed = $random;        
end

end






    $display("************ PASS ALL *************");
    $finish;

end

endmodule

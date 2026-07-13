`timescale 1ns/1ps
module tb_opt;

reg clk;
reg rst;

reg signed [15:0] x1, x2, x3;
wire signed [31:0] y1, y2, y3;

reg signed [15:0] sig950 [0:999];
reg signed [15:0] sig1100 [0:999];
reg signed [15:0] sig2000 [0:999];

integer i;
real y1_real, y2_real, y3_real;
integer f1, f2, f3;

// Instantiate DUTs
fir_optimized #(100) dut1(.clk(clk), .rst(rst), .x(x1), .y(y1));
fir_optimized #(100) dut2(.clk(clk), .rst(rst), .x(x2), .y(y2));
fir_optimized #(100) dut3(.clk(clk), .rst(rst), .x(x3), .y(y3));

// Read input signals
initial
begin
    $readmemh("sine950_Q214.txt", sig950);
    $readmemh("sine1100_Q214.txt", sig1100);
    $readmemh("sine2000_Q214.txt", sig2000);
end

// Clock generation (period = 2ns)
initial
begin
    clk = 0;
    forever #1 clk = ~clk;
end

// Reset
initial
begin
    rst = 1;
    x1 = 0; x2 = 0; x3 = 0;
    #5;
    rst = 0;
end

// Main stimulus + logging
initial
begin
    f1 = $fopen("direct_out_950.txt","w");
    f2 = $fopen("direct_out_1100.txt","w");
    f3 = $fopen("direct_out_2000.txt","w");

    for(i = 0; i < 1000; i = i + 1)
    begin
        @(posedge clk);

        // Apply inputs
        
        begin
            x1 = sig950[i];
            x2 = sig1100[i];
            x3 = sig2000[i];
        end
        
        // Convert and log output (includes transient + steady-state)
        y1_real = $itor(y1) / (1<<28);
        y2_real = $itor(y2) / (1<<28);
        y3_real = $itor(y3) / (1<<28);

        $fdisplay(f1,"%f",y1_real);
        $fdisplay(f2,"%f",y2_real);
        $fdisplay(f3,"%f",y3_real);
    end

    $fclose(f1);
    $fclose(f2);
    $fclose(f3);

    $finish;
end
endmodule
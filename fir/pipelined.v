module fir_direct #(parameter N=100)(
    input clk,
    input rst,
    input signed [15:0] x,
    output reg signed [31:0] y
);

reg signed [15:0] h [0:N-1];
reg signed [15:0] delay [0:N-1];

integer i;
reg signed [15:0] pipelinex [0:N-1];
reg signed [47:0] pipelines [0:N-1];
reg signed [47:0] acc;   // wide accumulator
integer k;

initial
begin
    for(k=1;k<N;k=k+1)
        delay[k] = 0;

end
initial
    $readmemh("fir_coeff_q214.txt",h);

always @(posedge clk)
begin
if (rst == 1) begin
        for (i = 0; i < N; i = i + 1) begin
            delay[i] <= 0;
            pipelines[i]<=0;
            pipelinex[i]<=0;

        end
    end

else begin
        delay[0]<= x;
        pipelines[1]<=delay[0]*h[0];
        delay[1]<=delay[0];

    for(i=2;i<N;i=i+1)begin
       pipelinex[i-1]<=delay[i-1];
       delay[i]<=pipelinex[i-1];
       pipelines[i]<=pipelinex[i-1]*h[i-1] + pipelines[i-1];
    end

end
             
  pipelinex[N-1]<=delay[N-1];
    y <= pipelinex[N-1]*h[N-1] + pipelines[N-1];   
end
endmodule
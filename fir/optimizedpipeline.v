module fir_optimized #(parameter N = 100)(
    input clk,
    input rst,
    input signed [15:0] x,
    output reg signed [47:0] y
);


reg signed [15:0] h [0:N-1];
reg signed [15:0] delay [0:N-1];

integer i;


wire signed [16:0] preadd [0:N/2-1];
wire signed [33:0] mult   [0:N/2-1];

generate
    genvar k;
    for(k = 0; k < N/2; k = k + 1) begin : PREMULT
        assign preadd[k] = delay[k] + delay[N-1-k];
        assign mult[k]   = preadd[k] * h[k];
    end
endgenerate

reg signed [33:0] mult_pipe [0:N/2-1][0:N/2-1];

integer j;

always @(posedge clk) begin
    if (rst) begin
        for(i=0;i<N/2;i=i+1)
            for(j=0;j<N/2;j=j+1)
                mult_pipe[i][j] <= 0;
    end
    else begin
        for(i=0;i<N/2;i=i+1) begin
            mult_pipe[i][0] <= mult[i];
            for(j=1;j<=i;j=j+1)
                mult_pipe[i][j] <= mult_pipe[i][j-1];
        end
    end
end


reg signed [47:0] stage [0:N/2-1];

always @(posedge clk) begin
    if (rst) begin
        for(i=0;i<N/2;i=i+1)
            stage[i] <= 0;
    end
    else begin
        stage[0] <= mult_pipe[0][0];

        for(i=1;i<N/2;i=i+1)
            stage[i] <= stage[i-1] + mult_pipe[i][i];
    end
end


always @(posedge clk) begin
    if (rst)
        y <= 0;
    else
        y <= stage[N/2-1];
end


always @(posedge clk) begin
    if (rst) begin
        for(i=0;i<N;i=i+1)
            delay[i] <= 0;
    end
    else begin
        delay[0] <= x;
        for(i=1;i<N;i=i+1)
            delay[i] <= delay[i-1];
    end
end

initial
    $readmemh("fir_coeff_q214.txt", h);

endmodule
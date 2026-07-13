clc
clear
close all

scale = 2^14;


x950_q  = hex2dec(readlines('sine950_Q214.txt'));
x1100_q = hex2dec(readlines('sine1100_Q214.txt'));
x2000_q = hex2dec(readlines('sine2000_Q214.txt'));

x950_q  = typecast(uint16(x950_q),'int16');
x1100_q = typecast(uint16(x1100_q),'int16');
x2000_q = typecast(uint16(x2000_q),'int16');

x950  = double(x950_q)/scale;
x1100 = double(x1100_q)/scale;
x2000 = double(x2000_q)/scale;


b_q = hex2dec(readlines('fir_coeff_q214.txt'));
b_q = typecast(uint16(b_q),'int16');

b = double(b_q)/scale;


y950_m  = filter(b,1,x950);
y1100_m = filter(b,1,x1100);
y2000_m = filter(b,1,x2000);


y950_q  = readmatrix('genvar_out_950.txt');
y1100_q = readmatrix('genvar_out_1100.txt');
y2000_q = readmatrix('genvar_out_2000.txt');

y950_v  = y950_q;
y1100_v = y1100_q;
y2000_v = y2000_q;


figure
subplot(3,1,1)
plot(y950_m,  'y-', 'LineWidth', 3)
hold on
plot(y950_v,  'r--', 'LineWidth', 1.5) 
title('950 Hz')
legend('MATLAB Output','Verilog Direct Output')
grid on

subplot(3,1,2)
plot(y1100_m, 'y-', 'LineWidth', 3)
hold on
plot(y1100_v, 'r--', 'LineWidth', 1.5)
title('1100 Hz')
legend('MATLAB Output','Verilog Direct Output')
grid on

subplot(3,1,3)
plot(y2000_m, 'y-', 'LineWidth', 3)
hold on
plot(y2000_v, 'r--', 'LineWidth', 1.5)
title('2000 Hz')
legend('MATLAB Output','Verilog Direct Output')
grid on
clc
clear
close all

%% Parameters
Fs = 10000;
Fc = 1000;
N  = 99;
scale = 2^14;

%% FIR Filter Design
Wn = Fc/(Fs/2);
b = fir1(N,Wn);

coeff_q = round(b*scale);

fid = fopen('fir_coeff_q214.txt','w');

for i=1:length(coeff_q)
    hex_val = typecast(int16(coeff_q(i)),'uint16');
    fprintf(fid,'%04X\n',hex_val);
end

fclose(fid);



N = 1000;
t = (0:N-1)/Fs;

f1 = 950;
f2 = 1100;
f3 = 2000;

x1 = sin(2*pi*f1*t);
x2 = sin(2*pi*f2*t);
x3 = sin(2*pi*f3*t);

x1_q = round(x1*scale);
x2_q = round(x2*scale);
x3_q = round(x3*scale);

write_hex('sine950_Q214.txt',x1_q)
write_hex('sine1100_Q214.txt',x2_q)
write_hex('sine2000_Q214.txt',x3_q)

x1 = x1_q/scale;
x2 = x2_q/scale;
x3 = x3_q/scale;

b = coeff_q/scale;

y1 = filter(b,1,x1);
y2 = filter(b,1,x2);
y3 = filter(b,1,x3);


figure

subplot(3,1,1)
plot(y1)
title('Filtered Output - 950 Hz')
grid on

subplot(3,1,2)
plot(y2)
title('Filtered Output - 1100 Hz')
grid on

subplot(3,1,3)
plot(y3)
title('Filtered Output - 2000 Hz')
grid on


function write_hex(filename,data)

fid = fopen(filename,'w');

for i=1:length(data)
    hex_val = typecast(int16(data(i)),'uint16');
    fprintf(fid,'%04X\n',hex_val);
end

fclose(fid);

end

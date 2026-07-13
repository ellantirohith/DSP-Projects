% verify_fft_outputs.m
% Compares Verilog FFT output with MATLAB's built-in FFT function

% 1. Read Original Input Data
fileID = fopen('fft_input.txt', 'r');
in_raw = fscanf(fileID, '%d %d', [2, inf])';
fclose(fileID);
complex_in = in_raw(:,1) + 1i * in_raw(:,2);

% 2. Read Verilog Hardware Output Data
fileID = fopen('fft_output.txt', 'r');
out_raw = fscanf(fileID, '%d %d', [2, inf])';
fclose(fileID);
hardware_out = out_raw(:,1) + 1i * out_raw(:,2);

% 3. Calculate Golden FFT Using MATLAB
golden_fft = fft(complex_in);

% 4. Display the Comparison
disp('---------------------------------------------------------');
disp('   MATLAB Golden FFT (Ideal)  |  Verilog Hardware Output');
disp('---------------------------------------------------------');
for i = 1:8
    % Formatting to display nicely aligned real and imaginary parts
    str_golden = sprintf('%8.2f + %8.2fi', real(golden_fft(i)), imag(golden_fft(i)));
    str_hw     = sprintf('%8d + %8di', real(hardware_out(i)), imag(hardware_out(i)));
    
    fprintf('%-30s | %s\n', str_golden, str_hw);
end
disp('---------------------------------------------------------');
disp('Note: Hardware values may differ slightly in magnitude ');
disp('due to the right-shifts (>> DWIDTH-1) during twiddle ');
disp('multiplication and truncation of fractional bits.');

% 5. Plot the Comparison
figure('Name', 'FFT Output Comparison', 'Position', [100, 100, 800, 600]);

% --- Plot Real Part ---
subplot(2, 1, 1);
plot(real(golden_fft), '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
plot(real(hardware_out), '-x', 'LineWidth', 1.5, 'MarkerSize', 6);
hold off;
title('FFT Output Comparison: Real Part');
xlabel('Frequency Bin (Index)');
ylabel('Amplitude');
legend('MATLAB Golden (Ideal)', 'Verilog Hardware', 'Location', 'best');
grid on;

% --- Plot Imaginary Part ---
subplot(2, 1, 2);
plot(imag(golden_fft), '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
plot(imag(hardware_out), '-x', 'LineWidth', 1.5, 'MarkerSize', 6);
hold off;
title('FFT Output Comparison: Imaginary Part');
xlabel('Frequency Bin (Index)');
ylabel('Amplitude');
legend('MATLAB Golden (Ideal)', 'Verilog Hardware', 'Location', 'best');
grid on;
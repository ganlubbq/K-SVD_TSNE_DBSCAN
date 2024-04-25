% LFM Signal Simulation in MATLAB

% Clear previous data and close all figures
clear all;
close all;
for SNR_dB=-14:2:4
    for num=1:150
        % Parameters
        Fs = 2e9;        % Sampling frequency
        T = 2e-6;              % Total duration of the signal
        Bt = 40e6;         % Time bandwidth product
        K = Bt/T;          % Chirp rate
        t = 0:1/Fs:T-1/Fs; % Time vector
        f0 = 80e6;         % Initial frequency

        % Generate LFM signal
        phi = pi * K * t.^2 + 2*pi*f0*t; % Phase function
        lfm_signal = cos(phi);

        % Plot the signal
        % figure;
        %   plot(t, lfm_signal);
        % title('LFM Signal');
        % xlabel('Time (s)');
        % ylabel('Amplitude');
        % grid on;

        % Plot the instantaneous frequency
        instant_freq = (diff(unwrap(angle(lfm_signal(1:end-1).*conj(lfm_signal(2:end))))))/(2*pi)*Fs;
        instant_freq = [instant_freq, instant_freq(end),instant_freq(end)]; % Append the last value to the vector
        % figure
        % plot(t, instant_freq);
        % title('Instantaneous Frequency');
        % xlabel('Time (s)');
        % ylabel('Frequency (Hz)');
        % grid on;

        % Add noise (optional)
        % SNR_dB = 10;  % Signal-to-noise ratio in dB
        SNR_linear = 10^(SNR_dB/10);
        noise_power = var(lfm_signal)/SNR_linear;
        noise = sqrt(noise_power/2)*(randn(size(lfm_signal)) + 1i*randn(size(lfm_signal)));
        noisy_lfm_signal = lfm_signal + noise;

        % Pulse compression (optional)
        % Assume a matched filter for simplicity
        matched_filter = conj(flipud(lfm_signal));
        compressed_signal = ifft(fft(noisy_lfm_signal).*fft(matched_filter));
        filename = sprintf('LFM%s_num%d.txt', num2str(SNR_dB), num);
        dlmwrite(filename, real(noisy_lfm_signal'), 'delimiter', '\n'); % 使用制表符作为分隔符
    end
end

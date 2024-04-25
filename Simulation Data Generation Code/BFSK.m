% BFSK Signal Simulation in MATLAB

% Clear previous data and close all figures
clear all;
close all;
for SNR_dB=-14:2:4
    for num=1:150
        % Parameters
        Fs = 2e9;          % Sampling frequency
        Tb = 2e-7;           % Bit duration
        N = Fs*Tb;           % Number of samples per bit
        f1 = 100e6;             % Frequency for bit '0'
        f2 = 200e6;             % Frequency for bit '1'

        % dataBits = randi([0 1], 1, 11); % Random binary data
        data = [1;1;1;0;0;0;1;0;0;1;0]; % Convert bits to decimal symbols


        % Modulation
        t = 0:1/Fs:Tb*(length(data));
        modSignal = zeros(1, length(t));

        for i = 1:length(data)
            if data(i) == 0
                modSignal((i-1)*N+1:i*N) = cos(2*pi*f1*t((i-1)*N+1:i*N));
            else
                modSignal((i-1)*N+1:i*N) = cos(2*pi*f2*t((i-1)*N+1:i*N));
            end
        end

        % Add noise
        % SNR_dB = 0;  % Signal-to-noise ratio in dB
        SNR_linear = 10^(SNR_dB/10);
        noise_power = var(modSignal)/SNR_linear;
        noise = sqrt(noise_power/2)*(randn(size(modSignal)) + 1i*randn(size(modSignal)));
        receivedSignal = modSignal + noise;

        % Demodulation
        receivedBits = zeros(1, length(data));
        for i = 1:length(data)
            if mean(abs(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f1*t((i-1)*N+1:i*N))) > ...
                    mean(abs(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f2*t((i-1)*N+1:i*N)))))
                receivedBits(i) = 0;
            else
                receivedBits(i) = 1;
            end
        end

        filename = sprintf('BFSK%s_num%d.txt', num2str(SNR_dB), num);
        dlmwrite(filename, real(receivedSignal'), 'delimiter', '\n'); % 使用制表符作为分隔符
    end
end


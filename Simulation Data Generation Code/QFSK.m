% QFSK Signal Simulation in MATLAB

% Clear previous data and close all figures
clear all;
close all;
for SNR_dB=-14:2:4
    for num=1:150
        % Parameters
        Fs = 2e9;          % Sampling frequency
        Tb = 2e-7;           % Symbol duration (each symbol represents 2 bits)
        N = Fs*Tb;           % Number of samples per symbol
        f1 = 50e6;             % Frequency for symbol '00'
        f2 = 100e6;             % Frequency for symbol '01'
        f3 = 150e6;             % Frequency for symbol '10'
        f4 = 200e6;             % Frequency for symbol '11'
        % dataBits = [0,1,0,1,0,1,1,0,1,0,0,0,1,0,0,1]; % Random binary data  e
        % dataSymbols = bi2de(reshape(dataBits, 2, []).'); % Convert bits to decimal symbols
        dataSymbols =[0;2;1;3;0;3;0;3;0;3;1;2;0;3;1;3];

        % Modulation
        t = 0:1/Fs:Tb*(length(dataSymbols));
        modSignal = zeros(1, length(t));

        for i = 1:length(dataSymbols)
            switch dataSymbols(i)
                case 0
                    modSignal((i-1)*N+1:i*N) = cos(2*pi*f1*t((i-1)*N+1:i*N));
                case 1
                    modSignal((i-1)*N+1:i*N) = cos(2*pi*f2*t((i-1)*N+1:i*N));
                case 2
                    modSignal((i-1)*N+1:i*N) = cos(2*pi*f3*t((i-1)*N+1:i*N));
                case 3
                    modSignal((i-1)*N+1:i*N) = cos(2*pi*f4*t((i-1)*N+1:i*N));
            end
        end

        % Add noise
        % SNR_dB = 10;  % Signal-to-noise ratio in dB
        SNR_linear = 10^(SNR_dB/10);
        noise_power = var(modSignal)/SNR_linear;
        noise = sqrt(noise_power/2)*(randn(size(modSignal)) + 1i*randn(size(modSignal)));
        receivedSignal = modSignal + noise;

        % Demodulation
        receivedSymbols = zeros(1, length(dataSymbols));
        for i = 1:length(dataSymbols)
            correlation1 = abs(sum(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f1*t((i-1)*N+1:i*N))));
            correlation2 = abs(sum(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f2*t((i-1)*N+1:i*N))));
            correlation3 = abs(sum(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f3*t((i-1)*N+1:i*N))));
            correlation4 = abs(sum(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f4*t((i-1)*N+1:i*N))));

            [~, maxIndex] = max([correlation1, correlation2, correlation3, correlation4]);
            receivedSymbols(i) = maxIndex-1; % Subtract 1 because MATLAB indices start at 1
        end

        % Convert symbols back to bits
        receivedBits = de2bi(receivedSymbols, 2, 'left-msb');
        receivedBits = receivedBits(:); % Convert to column vector
        filename = sprintf('QFSK%s_num%d.txt', num2str(SNR_dB), num);
        dlmwrite(filename, real(receivedSignal'), 'delimiter', '\n'); % 使用制表符作为分隔符
    end
end


% 清除之前的数据和关闭所有图形窗口
clear all;
close all;
for SNR_dB=-14:2:4
    for num=1:150
        % 参数设置
        Fs = 2e9;        % 采样频率
        Tb = 2e-7;       % 比特持续时间
        N = Fs*Tb;       % 每个比特的样本数
        f_carrier = 100e6; % 载波频率
        % dataBits = randi([0 1], 1, 100); % Random binary data
        data =  [1;1;1;0;0;0;1;0;0;1;0]; % Convert bits to decimal symbols
        % 调制
        t = 0:1/Fs:Tb*(length(data))+1/Fs; % 时间向量
        modSignal = zeros(1, length(t));

        for i = 1:length(data)
            if data(i) == 0
                % 对于'0'，使用相位为0的载波
                modSignal((i-1)*N+1:i*N) = cos(2*pi*f_carrier*t((i-1)*N+1:i*N));
            else
                % 对于'1'，使用相位为π的载波（即负余弦波）
                modSignal((i-1)*N+1:i*N) = -cos(2*pi*f_carrier*t((i-1)*N+1:i*N));
            end
        end

        % 添加噪声
        % SNR_dB = 0; % 信噪比（dB）
        SNR_linear = 10^(SNR_dB/10);
        noise_power = var(real(modSignal))/SNR_linear; % 假设信号是实数的
        noise = sqrt(noise_power/2)*(randn(size(modSignal)) + 1i*randn(size(modSignal)));
        receivedSignal = modSignal + noise;

        % 解调
        receivedBits = zeros(1, length(data));
        for i = 1:length(data)
            % 计算接收信号与原始载波信号的点积，并判断比特是'0'还是'1'
            if real(sum(receivedSignal((i-1)*N+1:i*N) .* cos(2*pi*f_carrier*t((i-1)*N+1:i*N)))) > 0
                receivedBits(i) = 0;
            else
                receivedBits(i) = 1;
            end
        end
        filename = sprintf('BPSK%s_num%d.txt', num2str(SNR_dB), num);
        dlmwrite(filename, real(receivedSignal'), 'delimiter', '\n'); % 使用制表符作为分隔符
    end
end

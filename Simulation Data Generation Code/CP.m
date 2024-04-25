% 常规脉冲调制正弦波信号仿真MATLAB代码

% 清除工作空间并关闭所有图形窗口
clear all;
close all;
for SNR_dB=-14:2:4
    for num=1:150
        % 定义信号参数
        Fs = 2e9;          % 采样频率（Hz）
        T = 2e-6;               % 信号总时长（s）
        PW = 5e-7;           % 脉冲宽度（s）
        PRF = 2e6;            % 脉冲重复频率（Hz）
        Amplitude = 1;      % 正弦波振幅
        CarrierFreq = 100e6;   % 载波频率（Hz）

        % 计算脉冲个数和脉冲间隔
        NumPulses = round(T * PRF);
        PulseInterval = 1/PRF;

        % 初始化时间向量
        t = 0:1/Fs:T-1/Fs;

        % 初始化调制后的信号
        modulated_signal = zeros(size(t));

        % 生成常规脉冲信号并调制正弦波
        for i = 1:NumPulses
            % 计算当前脉冲的起始和结束时间
            StartTime = (i-1)*PulseInterval;
            EndTime = StartTime + PW;

            % 确保脉冲在时间范围内
            if EndTime <= T
                % 生成当前脉冲时间内的正弦波
                sinusoid = Amplitude * sin(2*pi*CarrierFreq*(t(t>=StartTime & t<=EndTime)));

                % 将调制后的正弦波叠加到最终信号中
                modulated_signal(t>=StartTime & t<=EndTime) = sinusoid;
            end
        end

        SNR_linear = 10^(SNR_dB/10);
        noise = sqrt(var(modulated_signal)/SNR_linear) * randn(size(t));
        noisy_modulated_signal = modulated_signal + noise;
        filename = sprintf('CP%s_num%d.txt', num2str(SNR_dB), num);
        dlmwrite(filename, real(noisy_modulated_signal), 'delimiter', '\n'); % 使用制表符作为分隔符
    end
end

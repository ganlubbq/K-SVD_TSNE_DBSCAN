clear all;                  % 清除所有变量
close all;                  % 关闭所有窗口
clc;                        % 清屏
for SNR_dB=-14:2:4
    for num=1:150
        %% 基本参数
        M=32;                       % 产生码元数
        L=400;                      % 每码元复制L次,每个码元采样次数
        Ts=2e-7;                   % 每个码元的宽度,即码元的持续时间
        Rb=1/Ts;                    % 码元速率1K
        dt=Ts/L;                    % 采样间隔
        TotalT=M*Ts;                % 总时间
        t=0:dt:TotalT-dt;           % 时间
        TotalT2=(M/2)*Ts;           % 总时间2
        t2=0:dt:TotalT2-dt;         % 时间2
        Fs=1/dt;                    % 采样间隔的倒数即采样频率

        %% 产生双极性波形
        wave=[0;0;1;0;0;1;1;1;0;0;1;1;0;0;1;1; ...
            0;0;1;1;0;1;1;0;0;0;1;1;0;1;1;1];      % 产生二进制随机码,M为码元个数
        wave=2*wave'-1;              % 单极性变双极性
        fz=ones(1,L);               % 定义复制的次数L,L为每码元的采样点数
        x1=wave(fz,:);              % 将原来wave的第一行复制L次，称为L*M的矩阵
        jidai=reshape(x1,1,L*M);    % 产生双极性不归零矩形脉冲波形，将刚得到的L*M矩阵，按列重新排列形成1*(L*M)的矩阵

        %% I、Q路码元
        % I路码元是基带码元的奇数位置码元，Q路码元是基带码元的偶数位置码元
        I=[]; Q=[];
        for i=1:M
            if mod(i, 2)~=0
                I = [I, wave(i)];
            else
                Q = [Q, wave(i)];
            end
        end
        x2 = I(fz,:);               % 将原来I的第一行复制L次，称为L*(M/2)的矩阵
        I_lu = reshape(x2,1,L*(M/2));% 将刚得到的L*(M/2)矩阵，按列重新排列形成1*(L*(M/2))的矩阵
        x3 = Q(fz,:);               % 将原来Q的第一行复制L次，称为L*(M/2)的矩阵
        Q_lu = reshape(x3,1,L*(M/2));% 将刚得到的L*(M/2)矩阵，按列重新排列形成1*(L*(M/2))的矩阵

        %% QPSK调制
        fc=100e6;                    % 载波频率2kHz
        zb1=cos(2*pi*fc*t2);        % 载波1
        psk1=I_lu.*zb1;             % PSK1的调制
        zb2=sin(2*pi*fc*t2);        % 载波2
        psk2=Q_lu.*zb2;             % PSK2的调制
        qpsk=psk1+psk2;             % QPSK的实现



        %% 信号经过高斯白噪声信道
        tz=awgn(qpsk,SNR_dB);           % 信号qpsk中加入白噪声，信噪比为SNR=20dB
        filename = sprintf('QPSK%s_num%d.txt', num2str(SNR_dB), num);
        dlmwrite(filename, tz, 'delimiter', '\n'); % 使用制表符作为分隔符
    end
end

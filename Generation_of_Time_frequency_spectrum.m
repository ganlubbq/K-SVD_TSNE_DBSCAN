
clc,clear;
pwd="C:\Users\25891\Desktop\代码测试\时频图";%输出图像的位置

%=========制造信号列表路径=========
folderPath = "C:\Users\25891\Desktop\代码测试\测试数据"; % 信号样本数据的存储位置
% 获取文件夹中所有文件的列表  
files = dir(fullfile(folderPath, '*.*'));  
% 遍历文件列表，构建每个文件的完整路径  
str = {};  
for k = 1:length(files)  
    if files(k).isdir == 0 % 只处理文件，不处理子目录  
        filePath = fullfile(folderPath, files(k).name);  
        str{end+1} = filePath;  
    end  
end
%===============================


for i=1:length(str)

     %=========读取信号==============
     Sf=load(str{i});
     x=Sf;

     %=========自适应奇异值滤波======
     
     %构建信号的Hankel矩阵
     slength = length(x);
     M=slength;
     N=slength/2;

     if (mod(N,1)~=0)
         N=N-0.5;
     end
     Signal=zeros(N,M-N+1);
     for q=1:N
         Signal(q,:)=x(q:M+q-N);
     end


     %对矩阵进行奇异值分解
     [U,S,V]=svd(Signal);
     d=diag(S(1:N,1:N));

     %计算奇异值累积量差值
     s=zeros(1,length(d));
     for q=1:length(d)
         d0=(d(1)-d(length(d)))/(length(d)-1)*(q-1);
         dq=d(1)-d(q);
         s(q)=dq-d0;
     end

     %寻找降噪阶次
     for q=1:length(s)
         if (s(q)==max(s))
             break;
         end
     end

     %对信号进行滤波
     yu=q;
     for q=1:N
         if d(q)<d(yu)%修改滤波阈值
             d(q)=0;
         end
     end
     stemp=S;
     stemp(1:N,1:N)=diag(d);
     Sf=U*stemp*V';
     x=[Sf(1,:) Sf(2:N,length(Sf(1,:)))'];

     %=====================================
     
     %====时频图绘画====================
     fs = 640e3;  % 采样率，单位Hz
     T = 1/fs;   % 采样时间间隔，单位s
     duration = T*length(x); % 信号持续时间，单位s

     % 创建时间向量
     t = T:T:duration;
     Fs=fs;
     dt=T;    %时间精度
     timestart=-8;
     timeend=8;
     fig=figure();
     [sst,f] = wsst(x,fs);
     pcolor(t,f,abs(sst));
     shading interp;

     %=========针对不同类型的信号，截取的片段不一样，按照带宽与中心载频来截取=====
     if 1<=i && i<=1500
         ylim([90e6 210e6]);
     elseif 1501<=i && i<=3000
         ylim([60e6 140e6]);
     elseif 3001<=i && i<=4500
         ylim([90e6 110e6]);
     elseif 4501<=i && i<=6000
         ylim([75e6 125e6]);
     elseif 6001<=i && i<=7500
         ylim([40e6 210e6]);
     elseif 7501<=i && i<=9000
         ylim([60e6 140e6]);
     end
     axis off;
     set(gca,'Position',[0 0 1 1]);
     %===============================

     %====图片输出=============
     filename =fullfile(pwd, sprintf('figure%d.png', i));
     print(fig,filename,'-r100','-dpng');
     close (fig);
     %=========================
end


%========将图片转化为灰度图===========================
m=length(str);%总共图片的编号
for i=1:m
     filename =fullfile(pwd, sprintf('figure%d.png', i));
     I = imread(filename);   %读取到一张图片
     Ih = rgb2gray(I); % RGB图像转化成灰度图像
     imwrite(mat2gray(Ih), filename);
end

%==========二维中值滤波====================
filterSize=[3 3];
for i=1:m
     filename =fullfile(pwd, sprintf('figure%d.png', i));
     img = imread(filename);   %读取到一张图片
     img=medfilt2(img, filterSize);
     imwrite(mat2gray(Ih), filename);
end














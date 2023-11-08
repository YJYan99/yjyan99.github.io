clc;close all;clear all;
fid = fopen('F:\群目标数据\Line_Formation.dat','r');  %文件路径
k = 0;
Endflag = 0;%数据处理结束标志位
while(1)
    k = k+1;
    HrrpSum = zeros(2,12783);%存储矩阵初始化
    HrrpAzi = zeros(2,12783);
    HrrpEle = zeros(2,12783);
    HrrpSLB = zeros(2,12783);
        for j = 1 : 4 %四个通道
            FrameIni = []; % 协议包起始码
            for i1 = 1:2   %读帧头
                a = fread(fid,1,'uint32');
                FrameIni = [FrameIni,dec2hex(a)];
            end
            Flag = strcmp(FrameIni,'A5A5151CA5A5151C');
            if Flag==0
                if isempty(FrameIni)
                    Endflag = 1;
                else
                    disp('帧头出错');
                end
            else
            %读入系统参数
            Para.Radartype = fread(fid,1,'int16'); %0-相控阵
            Para.Channeltype = fread(fid,1,'int16');%通道类型 0-Sum 1-Azi；2-Ele 3-SLB
            Para.Wavaform = fread(fid,1,'int16'); %波形 0-单点频 1-线性调频 2-线性调频步进频
            Para.Pulsenum = fread(fid,1,'int64'); %雷控单包脉冲数目
            Para.Bandwidth = fread(fid,1,'double'); %子脉冲信号带宽 单位：MHz
            Para.Pulsetime = fread(fid,1,'double'); %子脉冲脉宽 单位：μs
            Para.DeltaF = fread(fid,1,'double'); %子脉冲跳频间隔 单位：MHz
            Para.Deltafnum = fread(fid,1,'double');%子脉冲跳频个数
            Para.PRT = fread(fid,1,'double'); %脉冲重复时间 单位：μs
            Para.DeltaRange = fread(fid,1,'double');%距离单元宽度 单位：m
            Para.RangeMin = fread(fid,1,'double'); %起始采样距离 单位：m
            Para.Hrrpdatasize = fread(fid,1,'double'); %单Hrrp点数的个数
            Para.f0 = fread(fid,1,'double');  %信号中心频率 单位：MHz
            

            %Hrrp信息写入
            for i = 1:2 %N为当前帧需要写入数据里的总Hrrp个数
                Hrrpindex = fread(fid,1,'double');%Hrrp序号
                Year = fread(fid,1,'uint16');%年
                Month =fread(fid,1,'uint8');%月
                Day = fread(fid,1,'uint8');%日
                Hour = fread(fid,1,'uint8');%时
                Minute = fread(fid,1,'uint8');%分
                Second = fread(fid,1,'uint8');%秒
                Millisecond = fread(fid,1,'uint16');%毫秒(秒以下)
                AziDirection = fread(fid,1,'double');%方位角
                EleDirection = fread(fid,1,'double');%俯仰角
                switch Para.Channeltype
                    case 0
                        for j = 1 : Para.Hrrpdatasize
                            Hrrp_Real = fread(fid,1,'double');  %第j个数据点I路
                            Hrrp_Imag = fread(fid,1,'double');   %第j个数据点Q路
                            HrrpSum(i,j) = Hrrp_Real + 1j*Hrrp_Imag;
                        end
                        
                    case 1
                        for j = 1 : Para.Hrrpdatasize
                            Hrrp_Real = fread(fid,1,'double');  %第j个数据点I路
                            Hrrp_Imag = fread(fid,1,'double');   %第j个数据点Q路
                            HrrpAzi(i,j) = Hrrp_Real + 1j*Hrrp_Imag;
                        end
                        
                    case 2
                        for j = 1 : Para.Hrrpdatasize
                            Hrrp_Real = fread(fid,1,'double');  %第j个数据点I路
                            Hrrp_Imag = fread(fid,1,'double');   %第j个数据点Q路
                            HrrpEle(i,j) = Hrrp_Real + 1j*Hrrp_Imag;
                        end
                        
                    case 3
                        for j = 1 : Para.Hrrpdatasize
                            Hrrp_Real = fread(fid,1,'double');  %第j个数据点I路
                            Hrrp_Imag = fread(fid,1,'double');   %第j个数据点Q路
                            HrrpSLB(i,j) = Hrrp_Real + 1j*Hrrp_Imag;
                        end
                                               
                end

            end 
            FrameEnd = []; % 读帧尾
            for i1 = 1:2
                a = fread(fid,1,'uint32'); FrameEnd = [FrameEnd,dec2hex(a)];
            end
            Flag = strcmp(FrameEnd,'A5A5551CA5A5551C');
            if Flag==0
                disp('帧尾出错或数据处理完毕');
            end
        end

        end
        if Endflag == 1
            disp('数据处理完毕');
            break;
        end

    end
clc;close all;clear all;
fid=fopen('Y:\ZRC\数据共享实验数据处理\3-HRRP存储结果\精灵4无人机\HRRP_302104759-1.dat','r');  %文件路径
k = 0;
Endflag = 0;%数据处理结束标志位
        while(1)%二十二个通道
            Hrrp=[];
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
            Para.Radartype = fread(fid,1,'int16'); %%1-全极化1套；2-全极化2套；3-全极化3套 
            Para.Channeltype = fread(fid,1,'int16');%通道类型 
            Para.Wavaform1 = fread(fid,1,'int16'); %波形 0-线性调频 1-线性调频步进频
            Para.Pulsetime = fread(fid,1,'uint16'); 
            Para.Pulsetime=Para.Pulsetime*10;%子脉冲脉宽 单位：μs
            Para.Wavaform2=fread(fid,1,'int16'); %波形参数2 0-近距 1-中距 2-远距
            Para.Pulsenum = fread(fid,1,'int64'); %%一个CPI发射的脉冲数，近距2000，中距1000
            Para.Hrrpnum = fread(fid,1,'int64'); %一个CPI包含的Hrrp数目
            Para.Bandwidth = fread(fid,1,'double'); %子脉冲信号带宽 单位：MHz
            Para.DeltaF = fread(fid,1,'double'); %子脉冲跳频间隔 单位：MHz
            Para.Deltafnum = fread(fid,1,'double');%子脉冲跳频个数
            Para.PRT = fread(fid,1,'double'); %脉冲重复时间 单位：μs
            Para.DeltaRange = fread(fid,1,'double');%距离单元宽度 单位：m
            Para.RangeMin = fread(fid,1,'double'); %起始采样距离 单位：m
            Para.Hrrpdatasize = fread(fid,1,'double'); %单Hrrp点数的个数
            Para.f0 = fread(fid,1,'double');  %信号中心频率 单位：MHz
            Hour = fread(fid,1,'uint8');%时
            Minute = fread(fid,1,'uint8');%分
            Second = fread(fid,1,'uint8');%秒
            Millisecond = fread(fid,1,'uint16');%毫秒(秒以下)
            AziDirection = fread(fid,1,'double');%方位角
            EleDirection = fread(fid,1,'double');%俯仰角    
   
            %Hrrp信息写入
            for i = 1: Para.Hrrpnum
            k=k+1
            Hrrpindex = fread(fid,1,'double');%Hrrp序号
            for j = 1 : Para.Hrrpdatasize
                    Hrrp_Real = fread(fid,1,'double');  %第j个数据点I路
                    Hrrp_Imag = fread(fid,1,'double');   %第j个数据点Q路
                    Hrrp(i,j) = Hrrp_Real + 1j*Hrrp_Imag;
            end
            end
            switch Para.Channeltype
                case 0 
                    HrrpKaHHSum=Hrrp ;
                case 1
                    HrrpKaVVSum=Hrrp ;
                case 2
                    HrrpKaHVSum =Hrrp;
                case 3
                    HrrpKaVHSum =Hrrp;      
                case 4 
                    HrrpKuHH1 =Hrrp;
                case 5 
                    HrrpKuHV1 =Hrrp;
                case 6
                    HrrpKuVH1 =Hrrp;
                case 7
                    HrrpKuVV1 =Hrrp;
                case 8 
                    HrrpXHH1 =Hrrp;
                case 9
                    HrrpXHV1 =Hrrp;
                case 10
                    HrrpXVH1 =Hrrp;
                case 11
                    HrrpXVV1 =Hrrp;
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
        if Endflag == 1
            disp('数据处理完毕');
            break;
        end


        end
% 
%     end
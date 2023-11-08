clc;
clear all;
close all;
%% 更改数据名称
DataName='Y:\1-相控阵数据集\数据库建库\数据集\1-转存版\生物数据\8月2日晚_AREA_1_28_20230802201335\8月2日生物数据';
%%
SaveName_Sum=' DataSum.dat';
DataSum_name=strcat(DataName,SaveName_Sum);
SaveName_Azi=' DataAzi.dat';
DataAzi_name=strcat(DataName,SaveName_Azi);
SaveName_Ele=' DataEle.dat';
DataEle_name=strcat(DataName,SaveName_Ele);
SaveName_SLB=' DataSLB.dat';
DataSLB_name=strcat(DataName,SaveName_SLB);
%%  获取文件总字节数，便于读文件跳出循环 共四个fid
DataSumfid = fopen(DataSum_name,'r');
DataAzifid = fopen(DataAzi_name,'r');
DataElefid = fopen(DataEle_name,'r');
DataSLBfid = fopen(DataSLB_name,'r');
fid1ByteNow = ftell(DataSumfid);                 %起始指向字节=0                
%总字节数
fseek(DataSumfid,0,1);
fid1ByteNum = ftell(DataSumfid);
fseek(DataSumfid,0,-1);                           %%文件指针退回文件开头
%% 读取帧头、雷达类型、通道参数
% 帧头
Flag1 = 0;Flag2 = 0;Flag3 = 0;Flag4 = 0;
FrameIni1 = []; % 协议包起始码
FrameIni2 = [];FrameIni3 = [];FrameIni4= [];
for i1 = 1:2
%     a = fread(fid,1,'uint32');
    [a1,a2,a3,a4]=func_freadFourSame_Value(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint32');
    FrameIni1 = [FrameIni1,dec2hex(a1)];
    FrameIni2 = [FrameIni2,dec2hex(a2)];
    FrameIni3 = [FrameIni3,dec2hex(a3)];
    FrameIni4 = [FrameIni4,dec2hex(a4)];
end
Flag1 = strcmp(FrameIni1,'A5A5151CA5A5151C');
Flag2 = strcmp(FrameIni2,'A5A5151CA5A5151C');
Flag3 = strcmp(FrameIni3,'A5A5151CA5A5151C');
Flag4 = strcmp(FrameIni4,'A5A5151CA5A5151C');
Flag=Flag1&Flag2&Flag3&Flag4;
if Flag==0 
    disp('帧头出错或数据处理完毕');
    error('帧头出错或数据处理完毕');
end
%雷达类型、通道参数
RadarType=[];ChannelType=[];
[RadarType]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'int16',RadarType);
[ChannelType]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'int16',ChannelType);

%% 参数定义
% OneBeamNum =  450080;      %%##2021-6-20 130080 258080 514080 ###2021-6-19 130080 210080 146080 ######162080 210080  450080  562080 %%594080 %578080
% OneHrrpNum=225584;           %加上帧头帧尾 一个数据包对应的字节 头1080 尾8
OneHrrpNum=206083;           
%% 参数初始化
HrrpSubcase=[];S1PRTTotal=[];S1BandWidth=[];S1PulseWidth=[];
FrequencyStep=[];FrequencyStepNum=[];
S1PRT=[];ro=[];dR=[];
HrrpSampleNum=[];
f0=[];HrrpId=[];
Year=[];Month=[];Day=[];Hour=[];Minute=[];Second=[];UnderSecond=[];
AziDir=[];EleDir=[];
HrrpSumALL=[];HrrpAziALL=[];HrrpEleALL=[];HrrpSLBALL=[];
%% 正式读取
while(fid1ByteNow<fid1ByteNum-OneHrrpNum)         % 波位循环,达到末尾10个波位，跳出循环
    aaaa=fid1ByteNum-OneHrrpNum-fid1ByteNow
    %% 读取波形参数
    [HrrpSubcase]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'int16',HrrpSubcase);
    [S1PRTTotal]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'int64',S1PRTTotal);
    [S1BandWidth]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',S1BandWidth);
    [S1PulseWidth]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',S1PulseWidth);
    [FrequencyStep]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',FrequencyStep);
    [FrequencyStepNum]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',FrequencyStepNum);
    [S1PRT]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',S1PRT);
    %% 读取  计算补偿后的起始采样距离   
    [dR]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',dR);
    [ro]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',ro);
    %% 读取 Hrrp的点数
    [HrrpSampleNum1,HrrpSampleNum2,HrrpSampleNum3,HrrpSampleNum4]=func_freadFourSame_Value(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double');
    HrrpSampleNum=[HrrpSampleNum;HrrpSampleNum1,HrrpSampleNum2,HrrpSampleNum3,HrrpSampleNum4];
    %% 读取 信号中心频率
    [f0]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',f0);
    %% 读取 信号单个Hrrp的前置信息
    [HrrpId]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',HrrpId);
    [Year]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint16',Year);
    [Month]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint8',Month);
    [Day]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint8',Day);
    [Hour]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint8',Hour);
    [Minute]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint8',Minute);
    [Second]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint8',Second);
    [UnderSecond]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint16',UnderSecond);
    %% 读取 方位俯仰
    [AziDir]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',AziDir);
    [EleDir]=func_freadFourSame(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'double',EleDir);
    %% 读取  四通道Hrrp
    
    Data1 = zeros(1,2*HrrpSampleNum1);
    Data1=fread(DataSumfid,2*HrrpSampleNum1,'double');
    Data1=Data1.';
    HrrpSum=[];
    HrrpSum=Data1(1:2:end)+j.*Data1(2:2:end);
    HrrpSumALL=[HrrpSumALL;HrrpSum];
    
    Data2 = zeros(1,2*HrrpSampleNum2);
    Data2=fread(DataAzifid,2*HrrpSampleNum2,'double');
    Data2=Data2.';
    HrrpAzi=[];
    HrrpAzi=Data2(1:2:end)+j.*Data2(2:2:end);
    HrrpAziALL=[HrrpAziALL;HrrpAzi];
    
    Data3 = zeros(1,2*HrrpSampleNum3);
    Data3=fread(DataElefid,2*HrrpSampleNum3,'double');
    Data3=Data3.';
    HrrpEle=[];
    HrrpEle=Data3(1:2:end)+j.*Data3(2:2:end);
    HrrpEleALL=[HrrpEleALL;HrrpEle];
    
    Data4 = zeros(1,2*HrrpSampleNum4);
    Data4=fread(DataSLBfid,2*HrrpSampleNum4,'double');
    Data4=Data4.';
    HrrpSLB=[];
    HrrpSLB=Data4(1:2:end)+j.*Data4(2:2:end);
    HrrpSLBALL=[HrrpSLBALL;HrrpSLB];
    
    fid1ByteNow = ftell(DataSumfid);
    
end
%% 读取 文件帧尾
Flag1 = 0;Flag2 = 0;Flag3 = 0;Flag4 = 0;
FrameEnd1 = []; 
FrameEnd2 = [];FrameEnd3 = [];FrameEnd4= [];
for i1 = 1:2
%     a = fread(fid,1,'uint32');
    [a1,a2,a3,a4]=func_freadFourSame_Value(DataSumfid,DataAzifid,DataElefid,DataSLBfid,1,'uint32');
    FrameEnd1 = [FrameEnd1,dec2hex(a1)];
    FrameEnd2 = [FrameEnd2,dec2hex(a2)];
    FrameEnd3 = [FrameEnd3,dec2hex(a3)];
    FrameEnd4 = [FrameEnd4,dec2hex(a4)];
end
Flag1 = strcmp(FrameEnd1,'A5A5551CA5A5551C');
Flag2 = strcmp(FrameEnd2,'A5A5551CA5A5551C');
Flag3 = strcmp(FrameEnd3,'A5A5551CA5A5551C');
Flag4 = strcmp(FrameEnd4,'A5A5551CA5A5551C');
Flag=Flag1&Flag2&Flag3&Flag4;
if Flag==0 
    disp('帧尾出错');
    error('帧尾出错');
end
%% 关闭文件
sta1=fclose(DataSumfid);
sta2=fclose(DataAzifid);
sta3=fclose(DataElefid);
sta4=fclose(DataSLBfid);
disp('读取结束');


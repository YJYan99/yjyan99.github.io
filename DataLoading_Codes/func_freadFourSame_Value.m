function [context1,context2,context3,context4] = func_freadFourSame_Value(fid1,fid2,fid3,fid4,size,str)
%$FUNC_FWRITEFOUR 此处显示有关此函数的摘要
%   此处显示详细说明
context1=fread(fid1,size,str);
context2=fread(fid2,size,str);
context3=fread(fid3,size,str);
context4=fread(fid4,size,str);
end


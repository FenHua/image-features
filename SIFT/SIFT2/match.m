function [ matched ] = match( des1, des2 )
% 从第一个描述子到第二个描述子进行匹配
distRatio = 0.6; % 前后两点相似度阈值
des2t = des2';
n = size(des1,1);
matched = zeros(1,n);
for i = 1 : n
   dotprods = des1(i,:) * des2t; 
   [values,index] = sort(acos(dotprods)); % cos相似度函数
   if (values(1) < distRatio * values(2))
      matched(i) = index(1);
   else
      matched(i) = 0;
   end
end
end
clc
clear
% 测试haar特征
stdSize=[24 24]; %固定特征提取窗口的大小
% 采用了5种haar模板
HarrLike{1}=[1 -1];
HarrLike{2}=[1 -1].';
HarrLike{3}=[1 -1 1];
HarrLike{4}=[1 -1 1].';
HarrLike{5}=[0 1;-1 0];

%计时
tic; 
% 提取负样本系列特征
picName='test.png';
Picture=imread(picName);
Picture=rgb2gray(Picture);%灰度化
Picture=imresize(Picture,stdSize);%更改大小
[II]=IntegralImage(Picture); %计算积分图
[fea]=extHarrLikeFeature(II,HarrLike); %特征提取

Costtime=toc;
fea
fprintf('One pcture may cost %8.5f',Costtime);
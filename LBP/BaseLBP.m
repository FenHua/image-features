function F=BaseLBP(image)
% 基本的LBP特征提取
I=imresize(image,[256,256]);
[m,n,h]=size(I);
if h==3
    I=rgb2gray(I);
end
F=uint8(zeros([m,n]));% 记录特征
for i =2:m-1
    for j=2:n-1
        % 得到领域比较信息
        neighbor = [I(i-1,j-1) I(i-1,j) I(i-1,j+1) I(i,j+1) I(i+1,j+1) I(i+1,j) I(i+1,j-1) I(i,j-1)] > I(i,j);
        pixel=0;
        for k=1:8
            pixel=pixel+neighbor(1,k)*bitshift(1,8-k);
        end
        F(i,j)=uint8(pixel);
    end
end
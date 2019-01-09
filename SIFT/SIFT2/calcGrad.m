function [mag_ori] = calcGrad(img,x,y)
% 计算像素梯度和大小
[height,width] = size(img);
mag_ori = [0 0];
if (x > 1 && x < height && y > 1 && y < width)
    dx = img(x-1,y) - img(x+1,y);
    dy = img(x,y+1) - img(x,y-1);
    mag_ori(1) = sqrt(dx*dx + dy*dy);
    mag_ori(2) = atan2(dx,dy);
else
    mag_ori = -1;
end
end
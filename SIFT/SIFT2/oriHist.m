function [ hist ] = oriHist( img, x, y, n, rad, sigma )
% 计算方向直方图
hist = zeros(n,1);
exp_factor = 2*sigma*sigma;
for i = -rad:rad
    for j = -rad:rad
        [mag_ori] = calcGrad(img,x+i,y+j);
        if(mag_ori(1) ~= -1)
            w = exp( -(i*i+j*j)/exp_factor );
            bin = 1 + round( n*(mag_ori(2) + pi)/(2*pi) );
            if(bin == n +1)
                bin = 1;
            end
            hist(bin) = hist(bin) + w*mag_ori(1);
        end
    end
end
end
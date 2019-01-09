function [] = drawFeatures( img, loc )
% 画出sift特征点位置
figure;
imshow(img);
hold on;
plot(loc(:,2),loc(:,1),'+g');
end
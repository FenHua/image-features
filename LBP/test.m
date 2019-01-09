clc
clear
image=imread('test.png');
% F=BaseLBP(image);
% F=LBP_Rotation(image);
F=LBP_Equivalent(image);
imshow(F);
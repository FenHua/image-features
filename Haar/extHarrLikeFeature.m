function FeatureVector=extHarrLikeFeature(II,HarrLike)
% II           积分图像
% HarrLike     Harr模板
imgWidth=size(II,2);     % 窗口宽度
imgHeight=size(II,1);    % 窗口高度
wdiv=1;   % 横向间隔 一个像素点为一步
hdiv=1;   % 纵向间隔 一个像素点为一步
FeatureVector=[];
for harrCnt=1:length(HarrLike)% 当前采取的Harr-like形式
    s=size(HarrLike{harrCnt},1);
    t=size(HarrLike{harrCnt},2);
    R = s:s:floor(imgHeight/s)*s;  % Haar窗口高
    C = t:t:floor(imgWidth/t)*t;   % Haar窗口宽
    NUM = 0;  % Haar特征总数
    for I = 1:length(R)
        for J = 1:length(C)
            r = R(I)*hdiv;  % Haar窗口高
            c = C(J)*wdiv;  % Haar窗口宽
            nr = imgHeight-r;  % 行方向移动个数
            nc = imgWidth-c;   % 列方向移动个数
            for x=1:nc       % 第几列
                for  y=1:nr  % 第几行
                    if (harrCnt==1)
                        white = II(y,x)+II(y+r,x+c/2)-II(y+r,x)-II(y,x+c/2);
                        black = II(y,x+c/2)+II(y+r,x+c)-II(y+r,x+c/2)-II(y,x+c);
                    end   
                    if (harrCnt==2)
                        white = II(y,x)+II(y+r/2,x+c)-II(y,x+c)-II(y+r/2,x);
                        black = II(y+r/2,x)+II(y+r,x+c)-II(y+r/2,x+c)-II(y+r,x);
                    end  
                    if (harrCnt==3)
                        white = II(y+r,x+c/3)+II(y,x)-II(y,x+c/3)-II(y+r,x)+...
                            II(y+r,x+c)+II(y,x+2*c/3)-II(y,x+c)-II(y+r,x+2*c/3);
                        black =2*(II(y+r,x+2*c/3)+II(y,x+c/3)-II(y,x+2*c/3)-II(y+r,x+c/3));
                    end  
                    if (harrCnt==4)
                        white = II(y+r/3,x+c)+II(y,x)-II(y+r/3,x)-II(y,x+c)+...
                            II(y+r,x+c)+II(y+2*r/3,x)-II(y+2*r/3,x+c)-II(y+r,x);
                        black = 2*(II(y+2*r/3,x+c)+II(y+r/3,x)-II(y+r/3,x+c)-II(y+2*r/3,x));
                    end 
                    if (harrCnt==5)
                        white = II(y+r/2,x+c/2)+II(y,x)-II(y+r/2,x)-II(y,x+c/2)...
                            +II(y+r,x+c)+II(y+r/2,x+c/2)-II(y+r/2,x+c)-II(y+r,x+c/2);
                        black = II(y+r,x+c/2)+II(y+r/2,x)-II(y+r/2,x+c/2)-II(y+r,x)...
                            +II(y+r/2,x+c)+II(y,x+c/2)-II(y,x+c)-II(y+r/2,x+c/2);
                    end 
                    Feature=white-black;
                    FeatureVector=[FeatureVector;Feature];
                    NUM = NUM+1;   
                end
            end
        end 
    end 
end 
end 
function Descriptors = SIFT(inputImage, Octaves, Scales, Sigma)
    Sigmas = sigmas(Octaves,Scales,Sigma); %获取不同的sigma值
    ContrastThreshhold = 7.68;
    rCurvature = 10;
    G = cell(1,Octaves);     % 存储高斯金字塔
    D = cell(1,Octaves);     % 高斯差分
    GO = cell(1,Octaves);  % 梯度方向
    GM = cell(1,Octaves);  % 梯度大小
    P = [];
    Descriptors = {};        % 关键点
    % 高斯金字塔
    for o = 1:Octaves
        % 层
        [row,col] = size(inputImage);
        temp = zeros(row,col,Scales);
        for s=1:Scales
            % 组
            temp(:,:,s) = imgaussfilt(inputImage,Sigmas(o,s));
        end
        G(o) = {temp};
        inputImage = inputImage(2:2:end,2:2:end);
    end
    % DOG金字塔
    for o=1:Octaves
        images = cell2mat(G(o));
        [row,col,Scales] = size(images);
        temp = zeros([row,col,Scales-1]);
        for s=1:Scales-1
            temp(:,:,s) = images(:,:,s+1) - images(:,:,s);
        end
        D(o) = {temp}; % DOG
    end
    % 获取不同尺度下的梯度信息
    % 此步骤最好在关键点检测之后进行，避免冗余计算
    for o = 1:Octaves
        images = cell2mat(G(o));
        [row,col,Scales] = size(images);
        tempO = zeros([row,col,Scales]); %记录方向信息
        tempM = zeros([row,col,Scales]); %记录梯度的大小
        for s = 1:Scales
            [tempM(:,:,s),tempO(:,:,s)] = imgradient(images(:,:,s)); % 计算梯度方向和梯度大小
        end
        GO(o) = {tempO};
        GM(o) = {tempM};
    end
   %% ------------------------------提取极值点-------------------------------
    for o=1:Octaves
        images = cell2mat(D(o));
        GradientOrientations = cell2mat(GO(o));
        GradientMagnitudes = cell2mat(GM(o));
        [row,col,Scales] = size(images);
        for s=2:Scales-1
            weights = gaussianKernel(Sigmas(o,s)); % 产生一个高斯核模板
            radius = (length(weights)-1)/2; %模板半径(正方形)
            for y=14:col-12
                for x=14:row-12
                    sub = images(x-1:x+1,y-1:y+1,s-1:s+1); % 获取上下两层子图像3*3大小
                    % 中间点与周围26个点比较
                    if sub(2,2,2) > max([sub(1:13),sub(15:end)]) || sub(2,2,2) < min([sub(1:13),sub(15:end)])
                        if abs(sub(2,2,2)) < ContrastThreshhold
                            % 极值点较弱，舍弃
                            continue
                        else
                            % 剔除不稳定的边缘响应点
                            Dxx = sub(1,2,2)+sub(3,2,2)-2*sub(2,2,2); % 海森矩阵
                            Dyy = sub(2,1,2)+sub(2,3,2)-2*sub(2,2,2);
                            Dxy = sub(1,1,2)+sub(3,3,2)-2*sub(1,3,2)-2*sub(3,1,2);
                            trace = Dxx+Dyy;% 计算迹
                            determinant = Dxx*Dyy-Dxy*Dxy;
                            curvature = trace*trace/determinant;
                            if curvature > (rCurvature+1)^2/rCurvature
                                continue % 保留部分稳定的边缘点
                            end
                        end
                        % 直方图统计邻域内像素的梯度和方向
                        a=0;b=0;c=0;d=0;
                        if x-1-radius < 0
                            a = -(x-1-radius);
                        end
                        if y-1-radius < 0
                            b = -(y-1-radius);
                        end
                        if row-x-radius < 0
                            c = -(row-x-radius);
                        end
                        if col-y-radius < 0
                            d = -(col-y-radius);
                        end
                        tempMagnitude = GradientMagnitudes(x-radius+a:x+radius-c,y-radius+b:y+radius-d,s).*weights(1+a:end-c,1+b:end-d); %计算极值点附近的梯度大小
                        tempOrientation = GradientOrientations(x-radius+a:x+radius-c,y-radius+b:y+radius-d,s);
                        [wRows, wCols] = size(tempMagnitude);
                        % 直方图统计(36个方向)
                        gHist = zeros(1,36);
                        for i = 1:wRows
                            for j = 1:wCols
                                temp = tempOrientation(i,j);
                                if temp < 0
                                    temp = 360 + temp;
                                end
                                % 以方向大小划分36个bin，并统计不同bin的梯度大小
                                bin = floor(temp/10)+1;
                                gHist(bin) = gHist(bin) + tempMagnitude(i,j); 
                            end
                        end
                        % 获取关键点的坐标信息
                        % TODO: 关键点的精确定位
                        % 获取最大值方向为关键点的方向
                        orientationThreshold = max(gHist(:))*4/5; % 主方向的80%
                        tempP = [];
                        for i=1:length(gHist)
                            if gHist(i) > orientationThreshold
                                % 离散的梯度方向直方图进行插值拟合处理，来求得更精确的方向角度值
                                if i-1 <= 0
                                    X = 0:2;
                                    Y = gHist([36,1,2]);
                                elseif i+1 > 36
                                    X = 35:37;
                                    Y = gHist([35,36,1]);
                                else
                                    X = i-1:i+1;
                                    Y = gHist(i-1:i+1);
                                end
                                % 方向插值
                                dir = interpolateExterma([X(1),Y(1)],[X(2),Y(2)],[X(3),Y(3)])*10;
                                mag = gHist(i); 
                                % 去重复
                                if ismember(dir,tempP(5:6:end)) == false
                                    tempP = [tempP,x,y,o,s,dir,mag];
                                end
                            end
                        end
                        P = [P,tempP];
                    end
                end
            end
        end
    end
   %% -------------------------------提取特征---------------------------------
    weights = gaussianKernel(Sigmas(o,s),13);
    weights = weights(1:end-1,1:end-1); % 26*26
    for i = 1:6:length(P)
        x = P(i);
        y = P(i+1);
        oct = P(i+2); % 组
        scl = P(i+3);  % 层
        dir = P(i+4);  % 方向
        mag = P(i+5); % 大小
        directions = cell2mat(GO(oct));    % 当前组的梯度方向
        directions = directions(x-13:x+12,y-13:y+12,scl); % 当前像素点周围点梯度方向
        magnitudes = cell2mat(GM(oct)); % 当前组的梯度大小
        magnitudes = magnitudes(x-13:x+12,y-13:y+12,scl).*weights; % 当前像素点周围点梯度大小
        descriptor = [];
        for m = 5:4:20
            for n = 5:4:20
                hist = zeros(1,8);
                for o = 0:3
                    for p = 0:3
                        [newx,newy] = rotateCoordinates(m+o,n+p,13,13,-dir);
                        % 创建8个bin的直方图
                        hist(categorizeDirection8(directions(newx,newy))) = magnitudes(newx,newy);
                    end
                end
                descriptor = [descriptor, hist];
            end
        end
        descriptor = descriptor ./ norm(descriptor,2);
        for j =1:128
            if descriptor(j) > 0.2
                descriptor(j) = 0.2;
            end
        end
        descriptor = descriptor ./ norm(descriptor,2);
        % 创建一个关键点对象
        kp = KeyPoint;
        kp.Coordinates = [x*2^(oct-1),y*2^(oct-1)];
        kp.Magnitude = mag;
        kp.Direction = dir;
        kp.Descriptor = descriptor;
        kp.Octave = oct;
        kp.Scale = scl;
        Descriptors(end+1) = {kp};
    end
end

%% -----------计算不同的sigma值-------------
function matrix = sigmas(octave,scale,sigma)
    % octave缩放不同尺度的个数，
    matrix = zeros(octave,scale); % octave层scare组所对应的sigma
    k = sqrt(2);
    for i=1:octave
        for j=1:scale
            matrix(i,j) = i*k^(j-1)*sigma;
        end
    end
end

%% 根据sigma大小，产生一个高斯核(模板)
function result = gaussianKernel(SD, Radius)
    % 模板半径为3×sigma，囊括99.7%的主要点
    if nargin < 2
        Radius = ceil(3*SD);
    end
    side = 2*Radius+1;
    result = zeros(side);
    for i = 1:side
        for j = 1:side
            x = i-(Radius+1);
            y = j-(Radius+1);
            result(i,j)=(x^2+y^2)^0.5;
        end
    end
    result = exp(-(result .^ 2) / (2 * SD * SD));
    result = result / sum(result(:));
end

%% 拟合出抛物线，获取精确的极值
function exterma = interpolateExterma(X, Y, Z)
    % 对三组数据进行插值返回一个精确值，参数均为2维
    exterma = Y(1)+...
        ((X(2)-Y(2))*(Z(1)-Y(1))^2 - (Z(2)-Y(2))*(Y(1)-X(1))^2)...
        /(2*(X(2)-Y(2))*(Z(1)-Y(1)) + (Z(2)-Y(2))*(Y(1)-X(1)));
end

%% 将方向归一化到8个方向
function bin = categorizeDirection8(Direction)
    if Direction <= 22.5 && Direction > -22.5
        bin = 1;
    elseif Direction <= 67.5 && Direction > 22.5
        bin = 2;
    elseif Direction <= 112.5 && Direction > 67.5
        bin = 3;
    elseif Direction <= 157.5 && Direction > 112.5
        bin = 4;
    elseif Direction <= -157.5 || Direction > 157.5
        bin = 5;
    elseif Direction <= -112.5 && Direction > -157.5
        bin = 6;
    elseif Direction <= -67.5 && Direction > -112.5
        bin = 7;
    elseif Direction <= -22.5 && Direction > -67.5
        bin = 8;
    end
end

%% 旋转坐标系
function [x,y] =  rotateCoordinates(x, y, originx, originy, dir)
    % 将像素点旋转值dir方向
    p = [x,y,1]';
    translate = [1,0,-originx;0,1,-originy;0,0,1];  % 边界
    rotate = [cosd(dir),-sind(dir),0;sind(dir),cosd(dir),0;0,0,1];
    translateBack = [1,0,originx;0,1,originy;0,0,1]; % 边界
    p = translateBack*rotate*translate*p;
    x = floor(p(1));
    y = floor(p(2));
end
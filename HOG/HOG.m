classdef HOG < handle
    % 方向梯度直方图的计算，要求输入图像是RGB图像，大小为128 x 64，使用案例 obj = HOG('image.jpg')。
    properties (Hidden)
        % 可视化参数(可选项)
        visualize = 1;
        % HOG 参数
        cellSize = 8;
        blockSize = 16;
        binSize = 9;
        dX;             % X的偏导数
        dY;             % Y的偏导数
        % 高斯滤波器参数(可选项)
        hSize          % 高斯滤波器的大小
        hSigma       % 滤波器的标准差
        hGaussFilter; % 高斯滤波器
        % 其它参数
        negVals;        % 临时变量，划分梯度方向时使用
        addMat;         % 临时变量，划分梯度方向时使用
        hist                % 临时梯度直方图
        gradDirOrig;  % 原始梯度方向
        % 可视化参数
        bs = 10; % 临时变量，可视化函数使用
        bim; % 过渡变量 可视化函数使用
    end
    properties
        % 类public属性
        % HOG 参数
        orig;
        I;                  % 准备读入的图片
        gradMag;     % 梯度等级
        gradDir;       % 梯度方向
        blocksMag;  % 块量级
        blocksDir;    % 块方向
        gradDirBin;  % 每个bin量化的梯度方向
        % 内部参数
        cellGradDir;       % 每个cell的梯度
        cellGradMag;     % 每个cell的梯度等级
        cellHOG;           % 每个cell存储一个9*9的直方图
        % 可视化部分的参数
        tempLongHist;  % 所有的cell的直方图
        tempVisl;          % 中间结果，用于可视化
        vis;
        % 用于返回的HOG
        histOfOrientedGradients 
    end
    methods
        function hog = HOG(image)
            % 图像数据的输入
            if(ischar(image))
                hog.orig = imread(image);
                hog.I = im2double(rgb2gray(hog.orig));
            elseif (length(size(image)) == 3)
                hog.orig = image;
                hog.I = im2double(rgb2gray(hog.orig));
            else
                hog.orig = image;
                hog.I = hog.orig;
            end
            % hog.I = medfilt2(hog.I); % 预处理消除噪声(可选项)
            takeDerivative(hog); % 计算偏导数
            initializeGaussianFilter(hog); % Calculate the Gaussian mask for weighting the histograms
            getBlocksAndCells(hog); % 计算HOG特征(块，cell，直方图等组成)
            visualizeHOG(hog); %直方图的可视化
        end
        function takeDerivative (hog)
            [hog.dX , hog.dY] = imgradientxy(hog.I, 'CentralDifference'); %中心插分计算偏导
            [hog.gradMag, hog.gradDirOrig] = imgradient(hog.dX , hog.dY);  % 返回梯度大小和方向
            %figure(1), imshow(hog.gradDir ./ 360);
            hog.negVals = hog.gradDirOrig < 0;
            hog.addMat = 180.* double(hog.negVals);
            hog.gradDir = hog.addMat + hog.gradDirOrig;
            %figure(2), imshow(hog.gradDir ./360);
            hog.gradDirBin = ones(size(hog.gradDir))+ floor(hog.gradDir./20); %取整，方向归一化到1-9
            hog.gradDir = hog.gradDirBin;   
        end
        function initializeGaussianFilter(hog)
            % 初始高斯滤波器参数，函数主要用于处理梯度大小，为了得到一个更好的HOG特征 
            hog.hSize = [16, 16];
            hog.hSigma = 5;
            hog.hGaussFilter = fspecial('gaussian', hog.hSize, hog.hSigma);
        end
        function getBlocksAndCells(hog)
            % 将梯度图像划分为16 x 16的块(含50%重叠) 
            %第一步，划块(图像梯度大小和方向均含50%重叠)
            %第二步，将每个块划分为 4 cells。
            hog.blocksDir = cell(15,7); %对应图片是128*64
            hog.blocksMag = cell(15,7);
            k = 1;
            for row = 1: 15
                for col = 1: 7
                    % 得到cell
                    hog.blocksDir{row, col} = hog.gradDir(8*(row-1)+1: 8*(row-1)+16, 8*(col-1)+1: 8*(col-1)+16);
                    hog.blocksMag{row, col} = hog.gradMag(8*(row-1)+1: 8*(row-1)+16, 8*(col-1)+1: 8*(col-1)+16);
                    hog.blocksMag{row, col} = imfilter(hog.blocksMag{row, col}, hog.hGaussFilter);
                    for m = 1:2
                        for n = 1:2
                            hog.cellGradDir{row, col}{m,n} = hog.blocksDir{row, col}(8* (m-1) +1:8* (m-1)+8, 8* (n-1) +1:8* (n-1)+8  );
                            hog.cellGradMag{row, col}{m,n} = hog.blocksMag{row, col}(8* (m-1) +1:8* (m-1)+8, 8* (n-1) +1:8* (n-1)+8  );
                            currHist = zeros(1, hog.binSize);
                            currCellDir = hog.cellGradDir{row, col}{m,n}; 
                            currCellMag = hog.cellGradMag{row, col}{m,n};
                            for cRow = 1: hog.cellSize
                                for cCol = 1:hog.cellSize
                                    currHist(currCellDir(cRow, cCol)) = currHist(currCellDir(cRow, cCol)) + currCellMag(cRow, cCol); % 9个梯度方向进行相应梯度大小的统计
                                    % 8*8大小的cell转换为1*9的向量
                                end
                            end
                            hog.cellHOG{row, col}{m,n} = currHist;
                            k = k+1;
                        end
                    end
                end
            end
        end
        function visualizeHOG(hog)
            % 直方图的可视化
            % 第一步，创建 "glyph"
            getGlyph(hog);
            k = 1;
            for row = 1: 15
                for col = 1: 7
                    for m = 1: 2
                        for n =1:2
                            hog.tempLongHist{1, k} = hog.cellHOG{row, col}{m,n};
                            k = k +1;
                            hog.vis{row,col}{m,n} = zeros(hog.bs, hog.bs);
                            for j = 1:hog.binSize
                                hog.vis{row,col}{m,n} = hog.vis{row,col}{m,n} + hog.cellHOG{row,col}{m,n}(j).*hog.bim(:,:,j); % 9个方向下梯度大小
                            end
                            hog.tempVisl{2*(row-1) + m, 2*(col-1) + n} = hog.vis{row,col}{m,n};
                        end
                    end
                end
            end
            hog.histOfOrientedGradients =cell2mat(hog.tempLongHist); %求得所有cell的梯度，每个cell含9个方向的梯度大小
            figure(1), imshow(hog.orig);
            figure(2), bar(hog.histOfOrientedGradients);
            figure(3), imshow(cell2mat(hog.tempVisl));
        end
        function getGlyph(hog)
            % 此函数用于获取一个cell中相应方向下的梯度大小和，0-1矩阵
            bim1 = zeros(hog.bs,hog.bs);
            bim1(round(hog.bs/2):round(hog.bs/2)+1,:) = 1;
            hog.bim = zeros([size(bim1) hog.binSize]);
            hog.bim(:,:,1) = bim1;
            for i = 2:hog.binSize
                hog.bim(:,:,i) = imrotate(bim1, -(i-1)*20, 'crop');
            end
        end
    end
end
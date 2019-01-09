function [ descrs, locs ] = getFeatures( input_img )
% ---------------------------SIFT特征提取-------------------
global gauss_pyr;
global dog_pyr;
global init_sigma;
global octvs;
global intvls;
global ddata_array;
global features;
if(size(input_img,3)==3)
    input_img = rgb2gray(input_img);
end
input_img = im2double(input_img);
%基本参数初始化
init_sigma = 1.6; % 初始sigma
intvls = 3; %层数
s = intvls;
k = 2^(1/s);
sigma = ones(1,s+3);
sigma(1) = init_sigma;
sigma(2) = init_sigma*sqrt(k*k-1);
for i = 3:s+3
    sigma(i) = sigma(i-1)*k;
end
input_img = imresize(input_img,2); %放大两倍
input_img = gaussian(input_img,sqrt(init_sigma^2-0.5^2*4));% 第一次高斯平滑
octvs = floor(log( min(size(input_img)) )/log(2) - 2);% 根据图片大小确定组数
% 高斯金字塔
[img_height,img_width] =  size(input_img);
gauss_pyr = cell(octvs,1);
gimg_size = zeros(octvs,2);
gimg_size(1,:) = [img_height,img_width]; % 当前组图片的大小
for i = 1:octvs
    if (i~=1)
        gimg_size(i,:) = [round(size(gauss_pyr{i-1},1)/2),round(size(gauss_pyr{i-1},2)/2)];
    end
    gauss_pyr{i} = zeros( gimg_size(i,1),gimg_size(i,2),s+3 );
end
for i = 1:octvs
    for j = 1:s+3
        if (i==1 && j==1)
            gauss_pyr{i}(:,:,j) = input_img;
        elseif (j==1)
            gauss_pyr{i}(:,:,j) = imresize(gauss_pyr{i-1}(:,:,s+1),0.5);% 从前一组的第s+1层图像下采样
        else
            gauss_pyr{i}(:,:,j) = gaussian(gauss_pyr{i}(:,:,j-1),sigma(j));
        end
    end
end
% 差分金字塔
dog_pyr = cell(octvs,1);
for i = 1:octvs
    dog_pyr{i} = zeros(gimg_size(i,1),gimg_size(i,2),s+2);
    for j = 1:s+2
    dog_pyr{i}(:,:,j) = gauss_pyr{i}(:,:,j+1) - gauss_pyr{i}(:,:,j);
    end
end
%关键点的定位
img_border = 5; % 留白边界大小(此范围内不考虑关键点的查找)
max_interp_steps = 5; % 利用插值法完成精确定位时，最大迭代次数
contr_thr = 0.04; % 低反差阈值
curv_thr = 10; % 边缘响应阈值
prelim_contr_thr = 0.5*contr_thr/intvls;
ddata_array = struct('x',0,'y',0,'octv',0,'intvl',0,'x_hat',[0,0,0],'scl_octv',0);
ddata_index = 1;
for i = 1:octvs
    [height, width] = size(dog_pyr{i}(:,:,1));
    %                                                                                                                                                                                                                                                                                                                                                             
    for j = 2:s+1
        dog_imgs = dog_pyr{i};
        dog_img = dog_imgs(:,:,j);
        for x = img_border+1:height-img_border
            for y = img_border+1:width-img_border
                % 去除低反差(low contrast)的点
                if(abs(dog_img(x,y)) > prelim_contr_thr)
                    % 与附近26个点比较，确定极值点
                    if(isExtremum(j,x,y))
                        ddata = interpLocation(dog_imgs,height,width,i,j,x,y,img_border,contr_thr,max_interp_steps);
                        if(~isempty(ddata))
                            if(~isEdgeLike(dog_img,ddata.x,ddata.y,curv_thr))
                                 ddata_array(ddata_index) = ddata;
                                 ddata_index = ddata_index + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end

function [ flag ] = isExtremum( intvl, x, y)
    % 极值点判断，与周围26个点比较
    value = dog_imgs(x,y,intvl);
    block = dog_imgs(x-1:x+1,y-1:y+1,intvl-1:intvl+1);
    if ( value > 0 && value == max(block(:)) )
        flag = 1;
    elseif ( value == min(block(:)) )
        flag = 1;
    else
        flag = 0;
    end
end

% 方向分配
n = size(ddata_array,2); % 关键点个数
ori_sig_factr = 1.5;      % 高斯sigma大小，用于平滑梯度方向和大小矩阵
ori_hist_bins = 36;      % 直方图bin的数量
ori_peak_ratio = 0.8;   % 特征方向阈值，超过0.8倍最大值将保留
features = struct('ddata_index',0,'x',0,'y',0,'scl',0,'ori',0,'descr',[]); % 特征集
feat_index = 1;
for i = 1:n
    ddata = ddata_array(i);
    ori_sigma = ori_sig_factr * ddata.scl_octv;
    hist = oriHist(gauss_pyr{ddata.octv}(:,:,ddata.intvl),ddata.x,ddata.y,ori_hist_bins,round(3*ori_sigma),ori_sigma); % 关键点周围产生一个直方图
    for j = 1:2
        smoothOriHist(hist,ori_hist_bins);
    end
    % 产生feature(梯度大小超过80%最大梯度值的梯度)
    feat_index = addOriFeatures(i,feat_index,ddata,hist,ori_hist_bins,ori_peak_ratio);
end

% 生成特征(描述)
n = size(features,2);  % 特征点数量
descr_hist_d = 4;       % 关键点形成描述子时所划分子区域宽度
descr_hist_obins = 8; % 方向直方图的bin数量
descr_mag_thr = 0.2; % 特征梯度大小阈值
descr_length = descr_hist_d*descr_hist_d*descr_hist_obins;
local_features = features;
local_ddata_array = ddata_array;
local_gauss_pyr = gauss_pyr;
clear features;
clear ddata_array;
clear gauss_pyr;
clear dog_pyr;
parfor feat_index = 1:n
    feat = local_features(feat_index);
    ddata = local_ddata_array(feat.ddata_index);
    gauss_img = local_gauss_pyr{ddata.octv}(:,:,ddata.intvl);
    % 计算相应描述子的梯度直方图
    hist_width = 3*ddata.scl_octv;
    radius = round( hist_width * (descr_hist_d + 1) * sqrt(2) / 2 );
    feat_ori = feat.ori;
    ddata_x = ddata.x;
    ddata_y = ddata.y;
    hist = zeros(1,descr_length);
    for i = -radius:radius
        for j = -radius:radius
            j_rot = j*cos(feat_ori) - i*sin(feat_ori);
            i_rot = j*sin(feat_ori) + i*cos(feat_ori);
            r_bin = i_rot/hist_width + descr_hist_d/2 - 0.5;
            c_bin = j_rot/hist_width + descr_hist_d/2 - 0.5;
            if (r_bin > -1 && r_bin < descr_hist_d && c_bin > -1 && c_bin < descr_hist_d)
                mag_ori = calcGrad(gauss_img,ddata_x+i,ddata_y+j);
                if (mag_ori(1) ~= -1)
                    ori = mag_ori(2);
                    ori = ori - feat_ori;
                    while (ori < 0)
                        ori = ori + 2*pi;
                    end
                    while (ori >= 2*pi)
                        ori = ori - 2*pi;
                    end
                    o_bin = ori * descr_hist_obins / (2*pi);
                    w = exp( -(j_rot*j_rot+i_rot*i_rot) / (2*(0.5*descr_hist_d*hist_width)^2) );
                    hist = interpHistEntry(hist,r_bin,c_bin,o_bin,mag_ori(1)*w,descr_hist_d,descr_hist_obins);
                end
            end
        end
    end
    local_features(feat_index) = hist2Descr(feat,hist,descr_mag_thr);
end
% 将描述子按照尺度大小排序
features_scl = [local_features.scl];
[~,features_order] = sort(features_scl,'descend');% 返回下坐标
descrs = zeros(n,descr_length);
locs = zeros(n,2);
for i = 1:n
    descrs(i,:) = local_features(features_order(i)).descr;
    locs(i,1) = local_features(features_order(i)).x;
    locs(i,2) = local_features(features_order(i)).y;
end
end
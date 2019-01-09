function bbs = softnms(boxes, overlap,sigma,threshold,method)
% 在目标检测得到检测窗后使用，用于消除冗余的窗
% boxes为一个m*n的矩阵，其中m为窗总数，n具体包含窗的位置信息和置信度(x1,y1,x2,y2,score)。
% overlap为IOU阈值，可以设置为0.3,0.5 .....
% method值为1：线性，2：高斯加权，3：传统NMS
if (nargin<3)
    sigma=0.5;
    threshold=0.2;
    method=2;
end
N=size(boxes,1);
% 获取所有窗的坐标信息，并求每个窗的面积
x1 = boxes(:,1);
y1 = boxes(:,2);
x2 = boxes(:,3);
y2 = boxes(:,4);
area = (x2-x1+1) .* (y2-y1+1); 
% 开始迭代
for ib=1:N
    tBD=boxes(ib,:);
    tscore=tBD(5);
    pos=ib+1;
    [maxscore,maxpos]=max(boxes(pos:end,5)); % 获得最大score的窗
    % 索引ib为最大score窗的所有信息
    if tscore<maxscore
        % 将最大score窗移至当前位置
        boxes(ib,:)=boxes(maxpos+ib,:);
        boxes(maxpos+ib,:)=tBD;
        tBD=boxes(ib,:);
        % 将相应的面积信息也进行置换
        tempAera=area(ib); 
        area(ib)=area(maxpos+ib);
        area(maxpos+ib)=tempAera;
    end
    % 获取ib索引窗和其它窗的合并下坐标和相交下坐标
    xx1=max(tBD(1),boxes(pos:end,1));
    yy1=max(tBD(2),boxes(pos:end,2));
    xx2= min(tBD(3),boxes(pos:end,3));
    yy2= min(tBD(4),boxes(pos:end,4));
    tarea=area(ib);
    w = max(0.0, xx2-xx1+1);
    h = max(0.0, yy2-yy1+1);
    inter = w.*h; % 相交的面积
    o = inter ./ (tarea + area(pos:end) - inter);%IOU计算
    % linear方法计算衰减系数
    if method==1   
        weight=ones(size(o));
        weight(o>overlap)=1-o;
    end
    % guassian 方法计算衰减系数
    if method==2   
        weight=exp((-o.*o)./sigma);
    end
    % NMS(经典最大值抑制)
    if method==3   
        weight=ones(size(o));
        weight(o>overlap)=0;
    end
    boxes(pos:end,5)=boxes(pos:end,5).*weight; %更新每个窗的score
end
bbs=boxes(boxes(:,5)>threshold,:); % 将置信度score大于阈值的窗返回
end
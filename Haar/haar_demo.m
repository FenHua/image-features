clc; clear; close all;

% Haar-like特征矩形计算

board = 24                                              % 检测窗口宽度
num = 24                                                % 检测窗口分划数

show = 1;                                               % 1为作图
time = 0.001;                                           % 作图间隔

%%

if mod(board,num)~=0
    error('检测窗口宽度必须是分划数的整数倍')
else
    delta = board/num                                   % 滑动步进值　
end

%% Haar特征1：左白,右黑,(s,t)=(1,2)

s = 1;
t = 2;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征1：左白,右黑,(s,t)=(1,2) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                   % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口宽
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 列方向移动个数
       
        Px0 = [0 r];                                     % 矩形坐标初始化
        Py0 = [0 c/2 c];
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;
               
                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(Px,repmat(Py',1,2),'r','LineWidth',5)
                    plot(repmat(Px,2,1),repmat([Py(1) Py(end)]',1,2),'r','LineWidth',5); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM

%% Haar特征2：上白,下黑,(s,t)=(2,1)

s = 2;
t = 1;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征2：上白,下黑,(s,t)=(2,1) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口宽
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 列方向移动个数
       
        Px0 = [0 r/2 r];                                 % 矩形坐标初始化
        Py0 = [0 c];
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;

                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(repmat(Px,2,1),repmat(Py',1,length(Px)),'r','LineWidth',3);
                    plot(repmat([Px(1) Px(end)]',1,2),repmat(Py,2,1),'r','LineWidth',3); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM

%% Haar特征3：左右白,中间黑,(s,t)=(1,3)

s = 1;
t = 3;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征3：左右白,中间黑,(s,t)=(1,3) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口宽
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 列方向移动个数
       
        Px0 = [0 r];                                     % 矩形坐标初始化
        Py0 = [0 c/3 c*2/3 c];
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;
               
                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(Px,repmat(Py',1,2),'r','LineWidth',5)
                    plot(repmat(Px,2,1),repmat([Py(1) Py(end)]',1,2),'r','LineWidth',5); hold off
                    pause(time)
                end

            end
        end
       
    end
end
NUM

%% Haar特征4：左右白,中间黑(2倍宽度),(s,t)=(1,4)

s = 1;
t = 4;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征4：左右白,中间黑(2倍宽度),(s,t)=(1,4) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口宽
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 列方向移动个数
       
        Px0 = [0 r];                                     % 矩形坐标初始化
        Py0 = [0 c/4 c*3/4 c];
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;
       
                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(Px,repmat(Py',1,2),'r','LineWidth',5)
                    plot(repmat(Px,2,1),repmat([Py(1) Py(end)]',1,2),'r','LineWidth',5); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM

%% Haar特征5：上下白，中间黑,(s,t)=(3,1)

s = 3;
t = 1;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征5：上下白，中间黑,(s,t)=(3,1) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口宽
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 列方向移动个数
       
        Px0 = [0 r/3 r*2/3 r];                           % 矩形坐标初始化
        Py0 = [0 c];
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;
               
                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(repmat(Px,2,1),repmat(Py',1,length(Px)),'r','LineWidth',3);
                    plot(repmat([Px(1) Px(end)]',1,2),repmat(Py,2,1),'r','LineWidth',3); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM

%% Haar特征6：上下白，中间黑(2倍宽度),(s,t)=(4,1)

s = 4;
t = 1;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征6：上下白，中间黑(2倍宽度),(s,t)=(4,1) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                 % Haar窗口宽
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 列方向移动个数
       
        Px0 = [0 r/4 r*3/4 r];                           % 矩形坐标初始化
        Py0 = [0 c];
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;

                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(repmat(Px,2,1),repmat(Py',1,length(Px)),'r','LineWidth',3);
                    plot(repmat([Px(1) Px(end)]',1,2),repmat(Py,2,1),'r','LineWidth',3); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM

%% Haar特征7：左上右下白，其它黑,(s,s)=(2,2)


s = 2;
t = 2;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征7：左上右下白，其它黑,(s,s)=(2,2) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口高
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 行方向移动个数
       
        Px0 = [0 r/2 r];                           % 矩形坐标初始化
        Py0 = [0 c/2 c];                           % 矩形坐标初始化
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;
               
                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(repmat(Px,3,1),repmat(Py',1,length(Px)),'r','LineWidth',3);
                    plot(repmat([Px(1) Px(end)]',1,3),repmat(Py,2,1),'r','LineWidth',3); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM

%% Haar特征8：四周白，中间黑,(s,s)=(3,3)

s = 3;
t = 3;
R = s:s:floor(num/s)*s;                                 % Haar窗口高
C = t:t:floor(num/t)*t;                                 % Haar窗口宽
NUM = 0;                                                % Haar特征总数

'---- Haar特征8：四周白，中间黑,(s,s)=(3,3) ---'
for I = 1:length(R)
    for J = 1:length(C)
       
        r = R(I)*delta;                                  % Haar窗口高
        c = C(J)*delta;                                  % Haar窗口高
        nr = num-R(I)+1;                                 % 行方向移动个数
        nc = num-C(J)+1;                                 % 行方向移动个数
       
        Px0 = [0 r/3 r*2/3 r];                           % 矩形坐标初始化
        Py0 = [0 c/3 c*2/3 c];                           % 矩形坐标初始化
        for i = 1:nr
            for j = 1:nc
                Px = Px0+(i-1)*delta;                    % 滑动取点
                Py = Py0+(j-1)*delta;
                NUM = NUM+1;
               
                if show
                    plot([0 board],repmat((0:delta:board)',1,2),'k'); hold on;
                    plot(repmat((0:delta:board)',1,2),[0 board],'k'); axis tight; axis square;
                    title('Haar矩形遍历演示');xlabel('x');ylabel('y');
                   
                    plot(repmat(Px,4,1),repmat(Py',1,length(Px)),'r','LineWidth',3);
                    plot(repmat([Px(1) Px(end)]',1,4),repmat(Py,2,1),'r','LineWidth',3); hold off
                    pause(time)
                end
               
            end
        end
       
    end
end
NUM
function table = lbp58table()
% 建立基本LBP模式表到均匀模式表下的映射 256->58
table = zeros([1 256]);
temp = 1;
for i=0:255
    if getHopcount(i)<=2
        table(i+1) = temp;
        temp = temp + 1;
    end
end
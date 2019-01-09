function minval=rotationMin(val)
% 循环（旋转）求得不同方向下的值，返回最小值
val=uint8(val);
vals=ones([1 8])*256;
for k=1:8
    vals(k)=val;
    last_bit=mod(val,2); % 最后一位的大小，判断最后一位是否有数
    val=bitshift(val,-1);
    val=last_bit*128+val; %循环队列
end
minval=min(vals);
end
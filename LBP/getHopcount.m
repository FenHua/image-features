function count = getHopcount(i)
% 根据当前二进制数的大小统计01变换次数
i = uint8(i);
bits = zeros([1 8]);
for k=1:8
    bits(k) = mod(i,2);
    i = bitshift(i,-1);
end
bits = bits(end:-1:1);
bits_circ = circshift(bits,[0 1]); %右移动一位
res = xor(bits_circ,bits); %异或，通过与右移一位可以发现向量中01或者10出现的次数
count = sum(res);
end
function out = toInt(arr)
% 二进制转数字
    out = 0;
    for i = 1: size(arr, 1)
        out = out + arr(i, 1) * 2 ^ (i - 1);
    end
end
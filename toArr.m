% 这两个也可以用内置 但还是自己写方便
function code = toArr(in, k)
% 数字转二进制
    code = zeros(k, 1);
    for kk = 1: k
        code(kk, 1) = bitand(bitshift(in, 1 - kk), 1);
    end
end
function out = judge2d(inputV, bits, isHard)
    % 对接受到的二维电平进行判决
    % inputV = 接受到的二维电平
    % bits = 比特数，2 = 四电平分布， 3 = 八电平分布
    % isHard = 是否为硬判决， isHard = 1 返回判决符号，isHard = 0 返回接受电平到所有符号之间的距离list
    if length(inputV) == 1 %若输入为复数，则更换为坐标对的形式
        inputV = [real(inputV), imag(inputV)];
    end
    if bits == 1
        V = {[-1,0], [1,0]};
    end
    if bits == 2 
        V = {[1,1]./sqrt(2), [1,-1]./sqrt(2), [-1,-1]./sqrt(2),[-1,1]./sqrt(2)};
    end
    if bits == 3 
        V = {[real(exp(j*5*pi/8)), imag(exp(j*5*pi/8))],
        [real(exp(j*3*pi/8)), imag(exp(j*3*pi/8))],
        [real(exp(j*15*pi/8)), imag(exp(j*15*pi/8))],
        [real(exp(j*1*pi/8)), imag(exp(j*1*pi/8))],
        [real(exp(j*7*pi/8)), imag(exp(j*7*pi/8))],
        [real(exp(j*9*pi/8)), imag(exp(j*9*pi/8))],
        [real(exp(j*13*pi/8)), imag(exp(j*13*pi/8))],
        [real(exp(j*11*pi/8)), imag(exp(j*11*pi/8))]};
    end
    if bits == 4
        V = {[3,3]./sqrt(10), [3,1]./sqrt(10), [3,-1]./sqrt(10), [3,-3]./sqrt(10),[1,-3]./sqrt(10), [-1,-3]./sqrt(10),[-3,-3]./sqrt(10),[-3, -1]./sqrt(10),[-3,1]./sqrt(10),[-3,3]./sqrt(10),[-1,3]./sqrt(10), [1,3]./sqrt(10),[1,1]./sqrt(10), [1,-1]./sqrt(10), [-1,-1]./sqrt(10), [-1,1]./sqrt(10)};
    end
    dst = inf;
    out = [];
    dstlist = zeros(1,length(V));
    if isHard
        for i=1:length(V)
            dsti = (inputV(1) - V{i}(1))^2 + (inputV(2) - V{i}(2))^2;
            if  dsti < dst
                dst = dsti;
                out = i - 1;
            end
        end
    else
        for i=1:length(V)
            dstlist(i) = (inputV(1) - V{i}(1))^2 + (inputV(2) - V{i}(2))^2;
        end
        out = dstlist;
    end
end
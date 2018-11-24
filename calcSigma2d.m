function sgma = calcSigma2d(snr, bits, isEqDst)
    % 已知snr，计算二维电平时的sigma值
    % sgma = calcSigma2d(snr, bits, isEqDst)
    % snr -- 信噪比
    % bits -- 每符号代表1,2,3比特
    % isEqDst -- 是否为等距分布
    if bits == 1
        sgma = sqrt(1/2*10^(-1/10*snr));
    end
    if bits == 2 && isEqDst
        sgma = 10^(-1/20*snr);
    elseif bits == 2 && ~isEqDst
        sgma = sqrt(10^(-1/10*snr)*3/8);
    elseif bits == 3 && isEqDst
        sgma = sqrt(3*10^(-1/10*snr));
    else
        sgma = sqrt(1/2*10^(-1/10*snr));
    end
end
function [out,key] = bits2syms(stream, bits, isEncrypt, encodeParam)
    % [out,key] = bits2syms(stream, bits, isEncrypt, encodeParam)
    % stream: 输入比特串
    % bits: 每电平代表的比特数:
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % isEncrypt: 1 -> 加密, 0 -> 不加密
    % encodeParam: 卷积参数: 1 -> 不卷积, 2 -> 1/2效率, 3 -> 1/3效率
    if isEncrypt
        if round(length(stream) / 240) ~= length(stream) / 240
            disp('length of stream must be a multiple of 240')
            out = 0;
            key = 0;
            return 
        end
        init();
        [kx, ky, key] = genKey();
        stream = encode(stream, kx, ky);
    else 
        key = 0;
    end
    if encodeParam == 1 % 不卷积时单独处理
        alignNumber = bits - mod(length(stream), bits);
        if alignNumber ~= bits
            residual = zeros(1, alignNumber);
            stream = [stream, residual];
        end
        tempMatrix = zeros(length(stream) / bits, bits);
        for i=1:size(tempMatrix, 1)
            for j=1:size(tempMatrix, 2)
                tempMatrix(i, j) = stream((i - 1) * bits + j);
            end
        end
        % 方便起见，乘法代替位移
        bitShift = zeros(bits, 1);
        for i=1:length(bitShift)
            bitShift(i) = 2^(bits - i);
        end
        stream = tempMatrix * bitShift;
        out = zeros(1, length(stream));
        for i=1:length(out)
            out(i) = generate2d(stream(i), bits);
        end
        return;
    end
    para = struct('m', encodeParam, 'batch', bits, 'dim', 2);
    out0 = channel(stream, 0, para);
    out = zeros(1, size(out0,1)*size(out0,2));
    k = 1;
    % 合并多行向量为一行
    for i=1:length(out0)
        for j=1:size(out0, 1)
            out(k) = out0(j,i);
            k = k + 1;
        end
    end            
end
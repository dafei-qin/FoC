function [out,key, aeskey, encryptHeader] = bits2syms(stream, bits, isEncrypt, encodeParam)
    % [out,key] = bits2syms(stream, bits, isEncrypt, encodeParam)
    % stream: 输入比特串
    % bits: 每电平代表的比特数:
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % isEncrypt: 1 -> 加密, 0 -> 不加密
    % encodeParam: 卷积参数: 1 -> 不卷积, 2 -> 1/2效率, 3 -> 1/3效率
    len = length(stream);
    lenlog = zeros(1, 13);
    for i=1:13
        lenlog(i) = floor(len / 2^(13 - i));
        len = len - floor(len / 2^(13 - i)) * 2^(13 - i);
    end
    % stream = [lenlog, stream];
    if isEncrypt
        aeskey = randi(256, 1, 24) - 1;
        header = zeros(1, 240);
        header(1:192) = bytes2bits(aeskey);
        header(193:192+13) = lenlog;

        init();
        [kx, ky, key] = genKey();
        encryptHeader = encode(header, kx, ky);
        disp('encryptHeader length:');
        length(encryptHeader)
        S = aesinit(aeskey);
        if mod(length(stream), 128) ~= 0
            prolix = 128 - mod(length(stream), 128);
        else
            prolix = 0;
        end
        stream = [stream, zeros(1, prolix)];
        encryptStream = zeros(1,length(stream));
        for i=1:(length(stream) / 128)
            encryptStream((i - 1)*128 + 1:i * 128) = bytes2bits(aesencrypt(S, bits2bytes(stream((i - 1)*128 + 1:i*128))));
        end
        encryptStream = [encryptHeader, encryptStream];
        disp('total length after encrypt:');
        length(encryptStream)
        stream = encryptStream;
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
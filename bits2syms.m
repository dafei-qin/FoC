function [out,key] = bits2syms(stream, bits, isEncrypt, encodeParam)
    % [out,key] = bits2syms(stream, bits, isEncrypt, encodeParam)
    % stream: input logical
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % isEncrypt: 1 -> encrypt on, 0 -> encrypt off
    % encodeParam: conv-params: 1 -> non-conv, 2 -> 1/2 effciency, 3 -> 1/3 effcienct
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
        % generate header for asym encryption
        header(1:192) = bytes2bits(aeskey);
        header(193:192+13) = lenlog;
        % initialization
        init(); 
        S = aesinit(aeskey);
        [kx, ky, key] = genKey(); 
        encryptHeader = encode(header, kx, ky); 
        % aligned to 128 bits
        if mod(length(stream), 128) ~= 0
            prolix = 128 - mod(length(stream), 128);
        else
            prolix = 0;
        end
        stream = [stream, zeros(1, prolix)];
        encryptStream = zeros(1,length(stream));
        % aes encryption
        for i=1:(length(stream) / 128)
            encryptStream((i - 1)*128 + 1:i * 128) = bytes2bits(aesencrypt(S, bits2bytes(stream((i - 1)*128 + 1:i*128))));
        end
        % total encrypted stream
        encryptStream = [encryptHeader, encryptStream];
        stream = encryptStream;
    else 
        key = 0;
    end

    if encodeParam == 1 % for non-conv-code
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
function [data] = syms2bits(stream, bits, key,encodeParam)
    % data = syms2bits(stream, bits, key, encodeParam)
    % stream: input logical
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % isEncrypt: 1 -> encrypt on, 0 -> encrypt off
    %para = struct('m', encodeParam, 'batch', bits, 'dim', 2, 'notail', 1);
    % cascade to parallel for de-conv
    
    out0 = zeros(encodeParam, length(stream) / encodeParam);

    for i = 1:size(out0, 2)

        for j = 1:encodeParam
            out0(j, i) = stream((i - 1) * encodeParam + j);
        end

    end
    if encodeParam == 1 % for non-conv
        for i=1:length(stream)
            stream(i) = judge2d(stream(i), bits, 1);
        end
        stream = stream';
        tempMatrix = zeros(length(stream), bits);
        for i=1:bits
            tempMatrix(:, i) = floor(stream ./ 2^(bits - i));
            stream = stream - floor(stream ./ 2^(bits - i)) * 2^(bits - i);
        end
        data = zeros(1, length(stream) * bits);
        for i=1:size(tempMatrix, 1)
            for j=1:size(tempMatrix, 2)
                data((i - 1) * bits + j) = tempMatrix(i, j);
            end
        end
    else
        data = viterbiGeneral(out0, poly_m(encodeParam), 1, 1, bits, 2);
        % dataAfterVbi = data;
    end
    % for transformation from 13 bit to integer
    M = zeros(13, 1);
    for i=1:13
        M(i) = 2^(13 - i);
    end

    if key
        encryptHeader = data(1:514);
        encryptData = data(515:end);
        % first use asym decode to find aes-key and len
        header = decode(encryptHeader, key);
        aeskey = header(1:192);
        len = header(193:192+13);
        aeskey = bits2bytes(aeskey);
        % transfer logical bits to integer
        len = len * M; 
        data = zeros(1, length(encryptData));
        % initialization
        S = aesinit(aeskey);
        % aes decode
        for i=1:(length(encryptData) / 128)
            data((i - 1)*128 + 1:i * 128) = bytes2bits(aesdecrypt(S, bits2bytes(encryptData((i - 1)*128 + 1:i*128))));
        end
        data = data(1:len);
    end
end

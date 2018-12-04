function data = syms2bits(stream, bits, key, encodeParam)
    % data = syms2bits(stream, bits, key, encodeParam)
    % stream: 输入比特串
    % bits: 每电平代表的比特数:
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % isEncrypt: 1 -> 加密, 0 -> 不加密
    % encodeParam: 卷积参数: 1 -> 不卷积, 2 -> 1/2效率, 3 -> 1/3效率
    %para = struct('m', encodeParam, 'batch', bits, 'dim', 2, 'notail', 1);
    out0 = zeros(encodeParam, length(stream) / encodeParam);

    for i = 1:size(out0, 2)

        for j = 1:encodeParam
            out0(j, i) = stream((i - 1) * encodeParam + j);
        end

    end
    if encodeParam == 1
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
        return;
    end
    data = viterbiGeneral(out0, poly_m(encodeParam), 0, 1, bits, 2);

    if key
        data = decode(data, key);
    end

    %data = data(1:end-3);
end

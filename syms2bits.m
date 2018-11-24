function data = syms2bits(stream, bits, key, encodeParam)
    % data = syms2bits(stream, bits, key, encodeParam)
    % stream: ������ش�
    % bits: ÿ��ƽ�����ı�����:
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % isEncrypt: 1 -> ����, 0 -> ������
    % encodeParam: ��������: 1 -> ������, 2 -> 1/2Ч��, 3 -> 1/3Ч��
    %para = struct('m', encodeParam, 'batch', bits, 'dim', 2, 'notail', 1);
    out0 = zeros(encodeParam, length(stream) / encodeParam);

    for i = 1:size(out0, 2)

        for j = 1:encodeParam
            out0(j, i) = stream((i - 1) * encodeParam + j);
        end

    end

    data = viterbiGeneral(out0, poly_m(encodeParam), 1, 1, bits, 2);

    if key
        data = decode(data, key);
    end

    %data = data(1:end-3);
end
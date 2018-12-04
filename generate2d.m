function out = generate2d(symbol, bits)
    % symbol: input logical bits
    % bits = 1 ->BPSK, bits = 2 ->4QAM, bits = 3 ->8PSK, bits = 4 - > 16QAM
    % out: output symbols
    if bits == 1
        V = {[-1, 0], [1, 0]};
    end

    if bits == 2
        V = {[1, 1] ./ sqrt(2), [1, -1] ./ sqrt(2), [-1, 1] ./ sqrt(2), [-1, -1] ./ sqrt(2)};
    end

    if bits == 3
        V = {[real(exp(j * 5 * pi / 8)), imag(exp(j * 5 * pi / 8))],
        [real(exp(j * 3 * pi / 8)), imag(exp(j * 3 * pi / 8))],
        [real(exp(j * 15 * pi / 8)), imag(exp(j * 15 * pi / 8))],
        [real(exp(j * 1 * pi / 8)), imag(exp(j * 1 * pi / 8))],
        [real(exp(j * 7 * pi / 8)), imag(exp(j * 7 * pi / 8))],
        [real(exp(j * 9 * pi / 8)), imag(exp(j * 9 * pi / 8))],
        [real(exp(j * 13 * pi / 8)), imag(exp(j * 13 * pi / 8))],
        [real(exp(j * 11 * pi / 8)), imag(exp(j * 11 * pi / 8))]};
    end

    if bits == 4
        V = {[3, 3] ./ sqrt(10), [3, 1] ./ sqrt(10), [3, -1] ./ sqrt(10), [3, -3] ./ sqrt(10), [1, -3] ./ sqrt(10), [-1, -3] ./ sqrt(10), [-3, -3] ./ sqrt(10), [-3, -1] ./ sqrt(10), [-3, 1] ./ sqrt(10), [-3, 3] ./ sqrt(10), [-1, 3] ./ sqrt(10), [1, 3] ./ sqrt(10), [1, 1] ./ sqrt(10), [1, -1] ./ sqrt(10), [-1, -1] ./ sqrt(10), [-1, 1] ./ sqrt(10)};
    end

    out = V{symbol + 1};
    out = out(1) + 1j * out(2);
end

function output = bits2bytes(input)
%bits2bytes - convert bits to bytes
%
% Syntax: output = bits2bytes(input)
%


    M = [2^7;2^6;2^5;2^4;2^3;2^2;2^1;2^0];
    output = zeros(1, length(input) / 8);
    for i=1:length(output)
        output(i) = input((i - 1) * 8 + 1:i*8) * M;
    end

end
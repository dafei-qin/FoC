function output = bytes2bits(input)
    %bits2bytes - convert bytes to  bits
    %
    % Syntax: output = bytes2bits(input)
    %
    
    validateattributes(input, {'numeric'}, {'real', 'vector', '>=', 0, '<', 256});
   
    output = zeros(1, length(input) * 8);
    for i =1:length(input)
        for j=1:8
            output((i - 1)*8 + j) = floor(input(i) / 2^(8 - j));
            input(i) = input(i) - floor(input(i) / 2^(8 - j)) * 2^(8 - j);
        end
    end
end
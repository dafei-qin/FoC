function encryptStream = test_aes(stream)
%testaes - Description
%
% Syntax: output = testaes(input)
%
% Long description
    aeskey = randi(8, 1, 24) - 1;
    header = zeros(1, 240);
    header(1:192) = bytes2bits(aeskey);

    %init();
    %[kx, ky, key] = genKey();
    %encryptHeader = encode(header, kx, ky);
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
    %encryptStream = [encryptHeader, encryptStream];
end
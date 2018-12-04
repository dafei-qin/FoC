function decryptStream = test_deaes(stream, aeskey)
%testaes - Description
%
% Syntax: output = testaes(input)
%
% Long description
    %init();
    %[kx, ky, key] = genKey();
    %encryptHeader = encode(header, kx, ky);
    S = aesinit(aeskey);

    decryptStream = zeros(1,length(stream));
    for i=1:(length(stream) / 128)
        decryptStream((i - 1)*128 + 1:i * 128) = bytes2bits(aesdecrypt(S, bits2bytes(stream((i - 1)*128 + 1:i*128))));
    end
    %encryptStream = [encryptHeader, encryptStream];
end
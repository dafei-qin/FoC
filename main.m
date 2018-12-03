%main.main
%by Senrui Chen
%
%A test program. without Encryption, without Encryption.
%
M = 1; 
N = 1000; %number of bits
n1 = 0.5;
message = randi(2,1,N)-1;
sstream = bits2syms(message,M,0,1);
res = syms2bits(WaveChannel(sstream,M,n1),M,0,1);
errorSymdrome = abs(res - message);
errorRate = sum(errorSymdrome)/N


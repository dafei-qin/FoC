%WaveChannel.m
function [out] = WaveChannel(sstream,M,n0)
%%%%%%%%%%
%parameter
%sstream: input complex symbol stream
%M : modeling rate (1=BPSK,2=4QAM,3=8PSK)
%n0: noise PSD. (optional) not finished
%output
%out: received symbol stream
%%%%%%%%%%
%setting:
%sampling rate:1
%symbol rate: 1/20/M
%carrier freq: 1/18
%%%%%%%%%%
%must use row vector
%%%%%%%%%%
    if(nargin<3)
        n0 = 0;
    end
    f_samp = 1;
    %M = 1;
    fc = 1/18;
    Rs = 1/20/M;
    Ts = 1/Rs;
    %N = 30; %number of bits
    %message = randi(2,1,N)-1;
    [~,omg,FT,IFT] = prefourier([-10*Ts,10*Ts],10000,[-2*pi*Rs,2*pi*Rs],1000);
    f = omg/2/pi;
    delta_T = 20*Ts/10000;
    delta_f = 2*Rs/1000;
    
    %%set sqrt-cosine filter
    Gc = 1.*(abs(f)<=1/80) + 0.5*(1+sin(40*pi*abs(f))).*(abs(f)>1/80 & abs(f)<=3/80);
    Gs = sqrt(Gc);
    g = (IFT*Gs)'; %generator filter (row vector)
    
    %%base-line modeling
    a = sstream;
    s_num = length(a);
    wlen = (s_num-1)*Ts/delta_T+10000;
    Sb = zeros(1,wlen);

    for k = 1:s_num
        Sb = Sb + [zeros(1,(k-1)*Ts/delta_T),a(k)*g,zeros(1,wlen-(k-1)*Ts/delta_T-10000)];
    end
    t = [1:wlen]*delta_T;

    %move to carrier 
    I = real(Sb);
    Q = imag(Sb);
    S = I.*cos(2*pi*fc*t)-Q.*sin(2*pi*fc*t);

    %plot(t,S);
    %功率谱绘制(还没做好)
    % [pxx,f] = periodogram(S);
    % figure, hold on, grid on
    % plot(f,pxx)
    % set(gca,'XLim',[0,1/20])

    %add AWGN
    n1 = n0; %wrong
    Qn = Q + randn(1,length(t))*n1;
    In = I + randn(1,length(t))*n1;
    Sbn = In + j*Qn;

    %receiver filter & sampling
    h = g;
    R = conv(Sbn,h,'same');
    sampTime = ([0:s_num-1]*Ts/delta_T) + 10*Ts/delta_T + 1;
    normFactor = 4/5; 
    a_re = R(sampTime) .* normFactor; %energy normalization
    out = a_re;
end



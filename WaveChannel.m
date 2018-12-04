%WaveChannel.m
function [out] = WaveChannel(sstream,M,m,ENR)
    %%%%%%%%%%
    %parameter
    %sstream: input complex symbol stream
    %M : modeling bits per symbol (1=BPSK,2=4QAM,3=8PSK)
    %m : inversed coding rate of convoluntion code m=1,2,3 => Rc=(1,1/2,1/3)
    %ENR: Eb/n0(dB num). For noise-free case, omit this parameter or input inf
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
    Rc = 1/m;
    if(ENR==inf)
        n0 = 0;
    else
        n0 = 10^(-ENR/10)/Rc;
    end
    Eb = 1;%coded bit energy (not info bit!)
    fs = 1;%采样率归一化 33300Hz
    f_real = 33300;
    fc = 1/18;
    Rs = 1/20/M/Rc;
    Ts = 1/Rs;
    [tt,omg,FT,IFT] = prefourier([-10*Ts,10*Ts],20*Ts*fs,[-2*pi*Rs,2*pi*Rs],1000);%这里的采样率一定要是fs 否则毫无意义
    f = omg/2/pi;
    len = length(tt);%g的长度
    %%set sqrt-cosine filter
    Gc = 1.*(abs(f)<=Rs/4) + 0.5*(1+sin(2*pi/Rs*abs(f))).*(abs(f)>Rs/4 & abs(f)<=3*Rs/4);
    Gs = sqrt(Gc);
    g = (IFT*Gs)'; %generator filter (row vector)
    gc = (IFT*Gc)';

    %%base-line modeling
    a = sstream;%no Encrypt, no coding
    s_num = length(a);
    wlen = (s_num-1)*Ts*fs+len;
    Sb = zeros(1,wlen);
    %s_ideal= zeros(1,wlen);
    for k = 1:s_num
        Sb = Sb + [zeros(1,(k-1)*Ts*fs),a(k)*g,zeros(1,wlen-(k-1)*Ts*fs-len)];
    end
    t = [1:wlen]/fs;

    %energy modification
    Sb = sqrt(M*2*Eb/Rs)*Sb;%修正后的Eb/n0是我们需要的值

    %figure

    %move to carrier 
    I = real(Sb);
    Q = imag(Sb);
    S = I.*cos(2*pi*fc*t)-Q.*sin(2*pi*fc*t);
    % %%%%%%%%%绘制：发射波形
    % subplot(2,2,1), hold on, grid on
    % plot(t/f_real,S);%转实际频率
    % xlabel('t/sec')
    % ylabel('s(t)')
    % title('Transmit signal time domain waveform')
    % set(gca,'XLim',[1,1.01])
    % %PSD

    % %%%%%%%%%绘制：发射功率谱
    % Fs = conv(abs(fft(S)/(length(S))).^2,ones(1,500)/500,'same');
    % Fs = fftshift(Fs);
    % ff = ([-length(Fs)/2:length(Fs)/2-1]/length(Fs)*fs);
    % subplot(2,2,3), hold on, grid on
    % plot(ff*f_real,Fs*f_real);%归一化频率转实际频率（功率不变）
    % xlabel('f/Hz')
    % ylabel('S(f)')
    % set(gca,'Xlim',[-0.5e4,0.5e4])
    % set(gca,'XTick',[-0.5e4:1000:0.5e4]);
    % title('Transmit signal PSD')

    %add AWGN
    n1 = sqrt(n0*fs);%理论计算给出的噪声值
    Qn = Q + randn(1,length(t))*n1;
    In = I + randn(1,length(t))*n1;
    Sn = In.*cos(2*pi*fc*t)-Qn.*sin(2*pi*fc*t);
    Sbn = In + j*Qn;
    % %plot(t,Sn)
    % subplot(2,2,2), hold on, grid on
    % plot(t/f_real,Sn);%转实际频率
    % xlabel('t/sec')
    % ylabel('s(t)')
    % title('Noisy signal time domain waveform')
    % set(gca,'XLim',[1,1.01])

    %%%%%%%%%%%绘制：接收功率谱
    Fsn = conv(abs(fft(Sn)/(length(Sn))).^2,ones(1,500)/500,'same');
    Fsn = fftshift(Fsn);
    % subplot(2,2,4), hold on, grid on
    % plot(ff*f_real,Fsn*f_real);%归一化频率转实际频率（功率不变）
    % xlabel('f/Hz')
    % ylabel('S_{re}(f)')
    % set(gca,'Xlim',[-0.5e4,0.5e4])
    % set(gca,'XTick',[-0.5e4:1000:0.5e4]);
    % title('Noisy signal PSD')


    %receiver filter & sampling
    %normFactor = 0.5*sqrt(M*2*Eb/Ecur)*fs;

    normFactor = 1/sqrt(M*2*Eb*Rs)*fs;
    h = normFactor * g;
    R = conv(Sbn,h,'same')/fs;
    sampTime = ([0:s_num-1]*Ts*fs) + 10*Ts*fs + 1;
    a_re = R(sampTime);% .* normFactor

    out = a_re;
end



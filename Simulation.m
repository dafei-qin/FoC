%Simulation
%of the total communication system
%By Senrui Chen
%main.main
%by Senrui Chen
%
%A test program. without Encryption, without Encryption.
%
M = 2; 
N = 8000; %number of bits

Pt_list = [];
Ps_list = [];
enr_list = [-4:2:16];

for enr = enr_list;
    err = 0;
    tot = 0;
    en = 10^(enr/10);
    P_theo = qfunc(sqrt(2*en));
    if(P_theo<5*10e-5)
        break
    end
    ep = max(1,round(500/N/P_theo));%确保估计精确度
    for (ep_cnt = 1:ep)
        message = randi(2,1,N)-1;
        sstream = bits2syms(message,M,0,1);
        res = syms2bits(WaveChannel(sstream,M,enr),M,0,1);
        err = err + sum(abs(res - message));  
        tot = tot + N;
    end
    Pt_list = [Pt_list,P_theo];
    Ps_list = [Ps_list,err/tot];
    [enr err/tot P_theo]
end

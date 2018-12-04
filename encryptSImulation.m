%Simulation
%of the total communication system
%By Senrui Chen
%main.main
%by Senrui Chen
%
%A test program. without Encryption, without Encryption.
%
M = 2;
m = 2;
N = 8000; %number of bits

Pt_list = [];
Ps_list = [];
enr_list = 8.5:0.5:10;
ep = 20;%�����û������������
for enr = enr_list
    err = 0;
    tot = 0;
    en = 10^(enr/10);
    
    %P_theo = 2/3*qfunc(sqrt(en*3*(1-2^-0.5)));
    % if(P_theo<5*10e-5)
        % break
    % end 
    % ep = max(1,round(500/N/P_theo));%ȷ�����ƾ�ȷ��
    for (ep_cnt = 1:ep)
        message = randi(2,1,N)-1;
        [sstream, key] = bits2syms(message,M,1,m);
        res = syms2bits(WaveChannel(sstream,M,m,enr),M,key,m);
        length(res)
        % plot(abs(res-message))
        % set(get(gca, 'XLabel'), 'String', '��Ϣ�������');
        % set(get(gca, 'YLabel'), 'String', '�Ƿ������');
        % legend('QPSK + 1/2��� + AES����, ENR=8dB')
        % ylim
        err = err + sum(abs(res - message));  
        if err ~= 0
            break
        end
    end
    err
    %Pt_list = [Pt_list,P_theo];
    if err == 0
        enr
        break
    end
end

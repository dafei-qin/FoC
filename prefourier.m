function [t,omg,FT,IFT] = prefourier(Trg,N,OMGrg,K)
% ��������� 
% Trg  : ��άʸ��������Ԫ�طֱ��ʾʱ���źŵ���ֹʱ�䣻
% N    : ʱ�����������
% OMGrg: ��άʸ��������Ԫ�طֱ��ʾƵ�׵���ֹƵ�ʣ�
% K    : Ƶ�����������
% ���������
% t    : ����ʱ�䣻
% omg  : ����Ƶ�ʣ�
% FT   : ʵ�ָ���Ҷ�任�ľ���~U~��ϵ����
% IFT  : ʵ�ָ���Ҷ��任�ľ���~V~��ϵ����
T = Trg(2)-Trg(1);
t = linspace(Trg(1),Trg(2)-T/N,N)';
OMG = OMGrg(2)-OMGrg(1);
omg = linspace(OMGrg(1),OMGrg(2)-OMG/K,K)';
FT = T/N*exp(-j*kron(omg,t.'));
IFT = OMG/2/pi/K*exp(j*kron(t,omg.'));

function out1 = channel(data, psnr, para)
    % para ÿ�����ߵĲ����ṹ�� []
    % psnr��
    % data ��������
    y = zeros(size(para, 2), size(psnr, 2), size(data, 2));
    idx = 0;
    for PSNR = psnr % ö�������
        idx = idx + 1;
        for i = 1: size(para, 2)
            m = para(i).m; % m Ч��
            batch = para(i).batch; % 1��ƽbatch����
            dim = para(i).dim; % ά��
            hard = (isfield(para(i),'hard') && para(i).hard); % �Ƿ�Ӳ�о� Ĭ�����о�
            notail = (isfield(para(i),'notail') && para(i).notail); %�Ƿ���β Ĭ����β
            poly = poly_m(m);
                out = convCode(data, poly);
                lout = size(out, 2);
                l1 = ceil(lout / batch);
                out = [out, zeros(m, l1 * batch - lout)];
                out1 = zeros(m, l1);
                % ���ɷ�����
                for ii = 1: m
                    for j = 1: l1
                        out1(ii, j) = generate2d(toInt(out(ii, (j - 1) * batch + 1: j * batch)'), batch);
                    end
                end
                % ͨ���ŵ�
            if notail
                out1 = out1(:, 1: size(out1, 2) - size(poly, 2) + 1);
            end
            %tmp = viterbiGeneral(out1, poly, hard, notail, batch, dim);
            %y(i, idx, :) = tmp(1: size(y, 3));
        end
        %PSNR % ��ʾ����
    end

end


function out = C1(in, n)
% �ŵ�
    out = sqrt(sum(([in, 0] + normrnd(0, n, 1, 2)).^2));
end

function out = convCode(in, poly)
% ����β���
    out = zeros(size(poly, 1), size(in, 2) + size(poly, 2) - 1);
    for i = 1: size(poly, 1)
        out(i, :) = mod(conv(in, poly(i, :)), 2);
    end
end
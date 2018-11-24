function out1 = channel(data, psnr, para)
    % para 每条曲线的参数结构体 []
    % psnr表
    % data 输入数据
    y = zeros(size(para, 2), size(psnr, 2), size(data, 2));
    idx = 0;
    for PSNR = psnr % 枚举信噪比
        idx = idx + 1;
        for i = 1: size(para, 2)
            m = para(i).m; % m 效率
            batch = para(i).batch; % 1电平batch比特
            dim = para(i).dim; % 维度
            hard = (isfield(para(i),'hard') && para(i).hard); % 是否硬判决 默认软判决
            notail = (isfield(para(i),'notail') && para(i).notail); %是否不收尾 默认收尾
            poly = poly_m(m);
                out = convCode(data, poly);
                lout = size(out, 2);
                l1 = ceil(lout / batch);
                out = [out, zeros(m, l1 * batch - lout)];
                out1 = zeros(m, l1);
                % 生成发送码
                for ii = 1: m
                    for j = 1: l1
                        out1(ii, j) = generate2d(toInt(out(ii, (j - 1) * batch + 1: j * batch)'), batch);
                    end
                end
                % 通过信道
            if notail
                out1 = out1(:, 1: size(out1, 2) - size(poly, 2) + 1);
            end
            %tmp = viterbiGeneral(out1, poly, hard, notail, batch, dim);
            %y(i, idx, :) = tmp(1: size(y, 3));
        end
        PSNR % 显示进度
    end

end


function out = C1(in, n)
% 信道
    out = sqrt(sum(([in, 0] + normrnd(0, n, 1, 2)).^2));
end

function out = convCode(in, poly)
% 带收尾卷积
    out = zeros(size(poly, 1), size(in, 2) + size(poly, 2) - 1);
    for i = 1: size(poly, 1)
        out(i, :) = mod(conv(in, poly(i, :)), 2);
    end
end
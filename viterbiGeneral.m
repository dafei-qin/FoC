function out = viterbiGeneral(in, poly,  hard, notail, batch, dim)
    if nargin < 5
        notail = 0;
    end
    % 一个电平含batch比特
    % dim 维度
    % in是m*(l - 1)的输入数据 效率1/m
    % polym*(k + 1)的多项式
    % 所以状态数是2^k

    m = size(poly, 1);
    l = size(in, 2) + 1;
    k = size(poly, 2) - 1;
    % 包括起始状态，总共动态规划的数组a为l * 2^k
    a = zeros(l, 2 ^ k);
    % pre数组记录每个状态点的最优前继
    pre = zeros(l, 2 ^ k);
    % 初始化距离无穷
    for i = 1: 2^k
        for j = 1: l
            a(j, i) = inf;
        end
    end
    % 除了初始点
    a(1, 1) = 0;
    
    
    % 循环整个数组
    for i = 2: l
        
        %一维和二维的接口函数都是返回某个电平对应各个允许电平的距离，预处理之
        for ii = 1: m
            %if dim == 1
            %    [~, preDis(ii, :)] = decide1D(batch, in(ii, i - 1), sigma, false);
            %else
                preDis(ii, :) = judge2d([real(in(ii, i - 1)), imag(in(ii, i - 1))], batch, false);
            %end
        end
            
        for j = 1: 2^k
            jBinary = toArr(j - 1, k);
            % jBinary 是j转化成二进制数组
            candidate = [];
            
            % p现在是枚举往前回去的batch位
            
            
            for p = 0: 2 ^ batch - 1
                pBinary = toArr(p, batch);
                supposed = [];
                % supposed是在p的假定下应该输出的结果
                for ii = 1: m
                    res = conv([pBinary', jBinary'], poly(ii, :));
                    supposed = [supposed, toInt(mod(res(k + 1: k + batch), 2)')];
                end
                %与实际结果in计算距离，hard指定是否硬判决
                pBjB = [pBinary; jBinary];
                tmp = a(i - 1, toInt(pBjB(1: k)) + 1);
                for ii = 1: m
                    if ~hard
                        %软判决就直接调用预存的距离
                        tmp = tmp + preDis(ii, supposed(ii) + 1);
                    else
                        if dim == 1
                            [near, ~] = decide1D(batch, in(ii, i - 1), sigma, false);
                        else
                            near = judge2d([real(in(ii, i - 1)), imag(in(ii, i - 1))], batch,true);
                        end
                        near = toArr(near, batch);
                        tmp = tmp + sum(abs(near - toArr(supposed(ii), batch)));
                    end
                end

                candidate = [candidate, tmp];
            end
            % 从候选中得出最优的
            [a(i, j), pre(i, j)] = min(candidate);
        end
    end
    out = zeros(1, (l - 1) * batch);
    
    cur = zeros(k, 1);
    tailcur = 0;
    if notail == 1
        [~, cur] = min(a(l, :));
        tailcur = toArr(cur - 1, k);
        cur = tailcur;
        % 若不收尾，则要决定尾巴
    end
    
    for i = l: -1: 2
        %通过pre往前回溯得到整个输出
        out(1, i * batch - 2 * batch + 1: i * batch - batch) = toArr(pre(i, toInt(cur) + 1) - 1, batch)';
        pBjB = [toArr(pre(i, toInt(cur) + 1) - 1, batch); cur];
        cur = pBjB(1: k);
    end
    out = out(k + 1: (l - 1) * batch);
    if notail == 1
        out = [out, tailcur'];
    end
end
function code = encode(info, kx, ky)
    global nSeg infoLen logRadix Radix;
    mx = int32(zeros(1, nSeg));

    for i = 1:infoLen

        for j = 1:logRadix
            mx(i) = mx(i) + bitshift(info((i - 1) * logRadix + j), j - 1);
        end

    end

    tryNum = 64000;

    while tryNum > 0
        tryNum = tryNum - 1;

        for i = infoLen + 1:nSeg
            mx(i) = randi(Radix) - 1;
        end

        [find, my] = findY(mx);

        if find
            [code1x, code1y, code2x, code2y] = encodeP(mx, my, kx, ky);
            code = [radixToBinary(code1x), mod(code1y(1), 2), radixToBinary(code2x), mod(code2y(1), 2)];
            return;
        end

    end

    code = int32(zeros(1, nSeg * 2 * logRadix + 2));
    % Fail
end

function f = eqBig(x, y)
    global nSeg;

    for i = 1:nSeg

        if x(i) ~= y(i)
            f = 0;
            return
        end

    end

    f = 1;
end

function ret = divSmall(x, sm)
    global nSeg Radix;
    ret = x;

    for i = nSeg:-1:1

        if i > 1
            ret(i - 1) = ret(i - 1) + Radix * mod(ret(i), sm);
        end

        ret(i) = floor(double(ret(i)) / sm);
    end

end

function [find, y] = findY(x)
    global p a b;
    p1 = minusDirect(p, pad(-1));
    p1 = divSmall(p1, 4);
    n = plusBig(plusBig(mulBig(x, mulBig(x, x)), mulBig(a, x)), b);
    y = powBig(n, p1);
    find = eqBig(mulBig(y, y), n);
end

function [code1x, code1y, code2x, code2y] = encodeP(mx, my, kx, ky)
    global n gx gy;
    r = randBig(n);
    [tmpx, tmpy] = powP(kx, ky, r);
    [code1x, code1y] = plusP(mx, my, tmpx, tmpy);
    [code2x, code2y] = powP(gx, gy, r);
end





function k = randBig(n)
    global nSeg;
    global Radix;

    for high = nSeg:-1:1

        if n(high) ~= 0
            break;
        end

    end

    k = zeros(1, nSeg);

    for i = 1:high - 1
        k(i) = randi(Radix) - 1;
    end

    k(high) = randi(n(high)) - 1;
end

function [x2, y2] = powP(x1, y1, k)
    global nSeg logRadix;
    first = 1;

    for i = 1:nSeg
        i% frofile of progress

        for j = 1:logRadix

            if bitand(k(i), bitshift(1, j - 1))

                if first == 1
                    x2 = x1;
                    y2 = y1;
                    first = 0;
                else
                    [x2, y2] = plusP(x2, y2, x1, y1);
                end

            end

            [x1, y1] = plusP(x1, y1, x1, y1);
        end

    end

end

function [x3, y3] = plusP(x1, y1, x2, y2)
    global a;

    if all(x1 == x2) && all(y1 == y2)
        k = mulBig(plusBig(mulBig(pad(3), mulBig(x1, x1)), a), inv(mulBig(pad(2), y1)));
    else
        k = mulBig(minusBig(y2, y1), inv(minusBig(x2, x1)));
    end

    x3 = minusBig(mulBig(k, k), plusBig(x1, x2));
    y3 = minusBig(mulBig(k, minusBig(x1, x3)), y1);
end

function c = pad(a)
    global nSeg;
    za = zeros(1, nSeg - size(a, 2));
    c = int32([a, za]);
end

function c = plusDirect(a, b)
    global nSeg;
    global Radix;
    a = int32(a);
    b = int32(b);
    c = a + b;

    for i = 1:nSeg - 1
        c(i + 1) = c(i + 1) + floor(double(c(i)) / double(Radix));
        c(i) = mod(c(i), Radix);
    end

end

function c = minusDirect(a, b)
    global nSeg;
    global Radix;
    a = int32(a);
    b = int32(b);
    c = a - b;

    for i = 1:nSeg - 1
        c(i + 1) = c(i + 1) + floor(double(c(i)) / double(Radix));
        c(i) = mod(c(i), Radix);
    end

end

function c = plusBig(a, b)
    global p;
    c = plusDirect(a, b);

    if get(c, p)
        c = minusDirect(c, p);
    end

end

function c = minusBig(a, b)
    global nSeg;
    global p;
    c = minusDirect(a, b);

    if c(nSeg) < 0
        c = plusBig(c, p);
    elseif get(c, p)
        c = minusDirect(c, p);
    end

end

function ret = get(a, b)
    global nSeg;

    for i = nSeg:-1:1

        if a(i) > b(i)
            ret = 1;
            return;
        elseif a(i) < b(i)
            ret = 0;
            return;
        end

    end

    ret = 1;
end

function ret = mulBig(a, b)
    global nSeg dict Radix logRadix;
    ret = int32(zeros(1, nSeg));
    c = uint32(zeros(1, 2 * nSeg));
    a = uint32(a);
    b = uint32(b);

    for i = 1:nSeg

        for j = 1:nSeg
            c(i + j - 1) = c(i + j - 1) + a(i) * b(j);
        end

    end

    for i = 1:2 * nSeg - 1
        c(i + 1) = c(i + 1) + uint32(floor(double(c(i)) / double(Radix)));
        c(i) = mod(c(i), uint32(Radix));
    end

    for i = 1:nSeg * 2

        for j = 1:logRadix

            if bitand(c(i), bitshift(1, j - 1))
                ret = plusBig(ret, dict(logRadix * (i - 1) + j, :));
            end

        end

    end

end

function c = powBig(a, b)
    global nSeg logRadix;
    c = pad(1);

    for i = 1:nSeg

        for j = 1:logRadix

            if bitand(b(i), bitshift(1, j - 1))
                c = mulBig(c, a);
            end

            a = mulBig(a, a);
        end

    end

end

function [a, b] = exGcdBig(x, y)

    if eqBig(y, pad(1))
        a = pad(0);
        b = pad(1);
        return;
    end

    if mod(x(1), 2) == 0
        x = divSmall(x, 2);
        [a1, b1] = exGcdBig(x, y);

        if mod(a1(1), 2) == 1
            a1 = plusDirect(a1, y);
            b1 = plusDirect(b1, x);
        end

        a = divSmall(a1, 2);
        b = b1;
        return;
    end

    if mod(y(1), 2) == 0
        y = divSmall(y, 2);

        if get(y, x)
            [a1, b1] = exGcdBig(x, y);

            if mod(b1(1), 2) == 1
                a1 = plusDirect(a1, y);
                b1 = plusDirect(b1, x);
            end

            a = a1;
            b = divSmall(b1, 2);
            return;
        end

        [b1, a1] = exGcdBig(y, x);
        b1 = minusDirect(x, b1);
        a1 = minusDirect(y, a1);

        if mod(b1(1), 2) == 1
            a1 = plusDirect(a1, y);
            b1 = plusDirect(b1, x);
        end

        a = a1;
        b = divSmall(b1, 2);
        return;
    end

    y = minusDirect(y, x);

    if get(y, x)
        [a1, b1] = exGcdBig(x, y);
        a = plusDirect(a1, b1);
        b = b1;
        return;
    end

    [b1, a1] = exGcdBig(y, x);
    b = minusDirect(x, b1);
    a = plusDirect(minusDirect(y, a1), b);
end

function y = inv(x)
    global p;
    [a, ~] = exGcdBig(x, p);
    y = minusDirect(p, a);
end

function ret = radixToBinary(x)
    global nSeg logRadix;
    ret = zeros(1, nSeg * logRadix);

    for i = 1:nSeg

        for j = 1:logRadix
            ret((i - 1) * logRadix + j) = bitand(1, bitshift(x(i), -(j - 1)));
        end

    end

end


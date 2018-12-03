
function poly = poly_m(m)
    poly1 = [1, 1, 0, 1; 1, 1, 1, 1]; % Ч��1/2�Ķ���ʽ
    poly2 = [1, 0, 1, 1; 1, 1, 0, 1; 1, 1, 1, 1]; % Ч��1/3�Ķ���ʽ

    if m == 2
        poly = poly1;
    elseif m == 3
        poly = poly2;
    elseif m == 1
        poly = [0,0,0,1];
    end
    
end
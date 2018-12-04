function out = shift_rows(in, dir)

if (dir == 0)
    out = reshape(in([1 6 11 16 5 10 15 4 9 14 3 8 13 2 7 12]),4,4);
else
    out = reshape(in([1 14 11 8 5 2 15 12 9 6 3 16 13 10 7 4]),4,4);
end
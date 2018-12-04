function out = shift_rows(in, dir)
% ShiftRows cyclically shift the rows of the 4 x 4 matrix.
%
%   dir = 0 (to left)
%  | 1 2 3 4 |
%  | 2 3 4 1 |
%  | 3 4 1 2 |
%  | 4 1 2 3 |
%
%   dir ~= 0 (to right)
%  | 1 2 3 4 |
%  | 4 1 2 3 |
%  | 3 4 1 2 |
%  | 2 3 4 1 |
% 
% absolute coordinate
% | 1 5 9  13 |
% | 2 6 10 14 |
% | 3 7 11 15 |
% | 4 8 12 16 |
% 
% (to right)
% 
% | 1 5 9 13  |
% | 14 2 6 10 | 
% | 11 15 3 7 |
% | 8 12 16 4 |

shift_index = [ 1 5 9 13;
               14 2 6 10;
               11 15 3 7;
               8 12 16 4];
           

if (dir == 0)
    % left
    % use linear indexing in 2d array
    out = reshape(in([1 6 11 16 5 10 15 4 9 14 3 8 13 2 7 12]),4,4);
    % old safe method
%     temp = reshape(in,16,1);
%     temp = temp([1 6 11 16 5 10 15 4 9 14 3 8 13 2 7 12]);
%     out = reshape(temp,4,4);
else
    % right
    % use linear indexing in 2d array
    out = reshape(in([1 14 11 8 5 2 15 12 9 6 3 16 13 10 7 4]),4,4);
    % old safe method
%     temp = reshape(in,16,1);
%     temp = temp([1 14 11 8 5 2 15 12 9 6 3 16 13 10 7 4]);
%     out = reshape(temp,4,4);
end
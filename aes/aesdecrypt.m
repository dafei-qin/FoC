function [out] = aesdecrypt(s, in)
% AESDECRYPT Decrypt 16-bytes vector.
% Usage:            out = aesdecrypt(s, in)
% s:                AES structure
% in:               input 16-bytes vector (ciphertext)
% out:              output 16-bytes vector (plaintext)

% Stepan Matejka, 2011, matejka[at]feld.cvut.cz
% $Revision: 1.1.0 $  $Date: 2011/10/12 $

if (nargin ~= 2)
    error('Bad number of input arguments.');
end

validateattributes(s, {'struct'}, {});
validateattributes(in, {'numeric'}, {'real', 'vector', '>=', 0, '<', 256});

% copy input to local
% 16 -> 4 x 4
state = reshape(in, 4, 4);

% Initial round
% AddRoundKey keyexp(s.rounds*4 + (1:4))
state = bitxor(state, (s.keyexp(s.rounds*4 + (1:4), :))');

% Loop over (s.rounds - 1) rounds
for i = (s.rounds - 1):-1:1
    % ShiftRows
    state = shift_rows(state, 1);
    % SubBytes - lookup table
    state = s.inv_s_box(state + 1);
    % AddRoundKey keyexp(i*4 + (1:4))
    state = bitxor(state, (s.keyexp((1:4) + 4*i, :))');
    % MixColumns
    state = mix_columns(state, s);
end

% Final round
% ShiftRows
state = shift_rows(state, 1);
% SubBytes - lookup table
state = s.inv_s_box(state + 1);
% AddRoundKey keyexp(1:4)
state = bitxor(state, (s.keyexp(1:4, :))');

% copy local to output
% 4 x 4 -> 16
out = reshape(state, 1, 16);

% ------------------------------------------------------------------------
function out = mix_columns(in, s)
% Each column of the state is multiplied with a fixed polynomial mod_pol
out = bitxor(bitxor(bitxor(...
    [s.mix_col14(in(1,1:4) + 1); s.mix_col9(in(1,1:4) + 1);  s.mix_col13(in(1,1:4) + 1); s.mix_col11(in(1,1:4) + 1)],...
    [s.mix_col11(in(2,1:4) + 1); s.mix_col14(in(2,1:4) + 1); s.mix_col9(in(2,1:4) + 1);  s.mix_col13(in(2,1:4) + 1)]),...
    [s.mix_col13(in(3,1:4) + 1); s.mix_col11(in(3,1:4) + 1); s.mix_col14(in(3,1:4) + 1); s.mix_col9(in(3,1:4) + 1)]),...
    [s.mix_col9(in(4,1:4) + 1);  s.mix_col13(in(4,1:4) + 1); s.mix_col11(in(4,1:4) + 1); s.mix_col14(in(4,1:4) + 1)]);

% ------------------------------------------------------------------------
function p = poly_mult(a, b, mod_pol, aes_logt, aes_ilogt)
% Multiplication in a finite field
% Faster implementaion
if (a && b)
    p = aes_ilogt(mod((aes_logt(a + 1) + aes_logt(b + 1)), 255) + 1);
else
    p = 0;
end

% ------------------------------------------------------------------------
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

if (dir == 0)
    % left
    % use linear indexing in 2d array
    out = reshape(in([1 6 11 16 5 10 15 4 9 14 3 8 13 2 7 12]),4,4);

else
    % right
    % use linear indexing in 2d array
    out = reshape(in([1 14 11 8 5 2 15 12 9 6 3 16 13 10 7 4]),4,4);

end

% ------------------------------------------------------------------------
% end of file

function [out] = aesencrypt(s, in)
% AESENCRYPT  Encrypt 16-bytes vector.
% Usage:            out = aesencrypt(s, in)
% s:                AES structure
% in:               input 16-bytes vector (plaintext)
% out:              output 16-bytes vector (ciphertext)

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
% AddRoundKey keyexp(1:4)
state = bitxor(state, (s.keyexp(1:4, :))');

Reg_before = reshape(state,1,16);
Reg_after = zeros(1,16);

% Loop over (s.rounds - 1) rounds
for i = 1:(s.rounds - 1)
    % SubBytes - lookup table
    state = s.s_box(state + 1);
    % ShiftRows
    state = shift_rows(state, 0);
    % MixColumns
    state = mix_columns(state, s);
    % AddRoundKey keyexp(i*4 + (1:4))
    state = bitxor(state, (s.keyexp((1:4) + 4*i, :))');
    
    % Here are 9 power peak;
    Reg_after = reshape(state,1,16);
    
    Reg_before = Reg_after;
end

% Final round
% SubBytes - lookup table
state = s.s_box(state + 1);
% ShiftRows
state = shift_rows(state, 0);
% AddRoundKey keyexp(4*s.rounds + (1:4))
% Here is the final power peak;
state = bitxor(state, (s.keyexp(4*s.rounds + (1:4), :))');



% copy local to output
% 4 x 4 -> 16
out = reshape(state, 1, 16);


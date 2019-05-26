function melval = hz2mel(hzval)
% Convert a vector of values in Hz to Mels.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% hzval : 1 x N array
% values in Hz
%
% Returns
% -------
% melval : 1 x N array
% values in Mels
    melval = 1127.01028 * log(1 + hzval/700);
    
end
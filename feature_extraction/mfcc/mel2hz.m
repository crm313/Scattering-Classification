function hzval = mel2hz(melval)
% Convert a vector of values in Hz to Mels.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% melval : 1 x N array
% values in Mels
%
% Returns
% -------
% hzval : 1 x N array
% values in Hz
    hzval = 700 * (exp(melval/1127.01028) - 1);
end
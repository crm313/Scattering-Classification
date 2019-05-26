function [x_t, fs, t] = import_audio(filepath)
% Import an audio signal from a wave file.
%
% Parameters
% ----------
% filepath : string
% path to a .wav file
%
% Returns
% -------
% x t : 1 x T array
% time domain signal
% t : 1 x T array
% time points in seconds
% fs : int
% sample rate (samples per second)
    [x_t, fs] = audioread(filepath);
    [len, num_channels] = size(x_t);
    if num_channels > 1
       x_t = x_t(:,1); 
    end
    
    t = 0:1/fs:(len-1)/fs;
    
    % Normalize
    x_t = x_t/norm(x_t);
end
function [mfccs, fs_mfcc] = compute_mfccs(filepath, win_size, hop_size, ...
min_freq, max_freq, num_mel_filts, n_dct)
% Compute MFCCs from audio file.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% filepath : string
% path to .wav file
% win size : int
% spectrogram window size (samples)
% hop size : int
% spectrogram hop size (samples)
% min freq : float
% minimum frequency in Mel filterbank (Hz)
% max freq : float
% maximum frequency in Mel filterbank (Hz)
% num mel filts: int
% number of Mel filters
% n dct: int
% number of DCT coefficients
%
% Returns
% -------
% mfccs : n dct x NT array
% MFCC matrix (NT is number spectrogram frames)
% fs mfcc : int
% sample rate of MFCC matrix (samples/sec)
    [x, fs, t] = import_audio(filepath);
    
    noverlap = win_size - hop_size;
    nfft = win_size;
    % Zero pad signal to center first window at first sample
    x = [zeros(win_size/2, 1); x; zeros(win_size/2, 1)];
    [S, w, t_S] = spectrogram(x, hamming(win_size), noverlap, nfft, fs);
    fs_mfcc = fs/hop_size;
    [N, M] = size(S);
    
    min_mel = hz2mel(min_freq);
    max_mel = hz2mel(max_freq);
    
    mel_centers = linspace(min_mel, max_mel, num_mel_filts);
    % Append extra value to each end (needed for mel_filt_bank windows)
    interval = mel_centers(2) - mel_centers(1);
    mel_centers = [mel_centers(1)-interval, mel_centers, mel_centers(end)+interval];
    
    hz_centers = mel2hz(mel_centers);
    centers = find_nearest(w, hz_centers);
    
    mel_filt_bank = zeros( num_mel_filts, N);
    % Skip first and last elements (still used in window calculation)
    for i = 2:length(centers)-1
        prev = centers(i-1);
        curr = centers(i);
        next = centers(i+1);

        mel_filt_bank(i-1, prev:curr) = linspace(0,1, curr-prev+1);
        mel_filt_bank(i-1, curr:next) = linspace(1,0, next-curr+1); 
        
        % Normalize to unity
        mel_filt_bank(i-1,:) = mel_filt_bank(i-1,:)/sum(mel_filt_bank(i-1,:));
    end

    % Plot mel_filt_bank
    %imagesc(mel_filt_bank);set(gca,'ydir','normal');
    %plot(mel_filt_bank');
    
    mel_power_spec = mel_filt_bank * 20*log10(abs(S));
    
    % Plot mel power spec
    %imagesc(mel_power_spec);set(gca,'ydir','normal');
    
    dct_matrix = dctmtx(num_mel_filts);
    dct_matrix = dct_matrix(1:n_dct, :);
    mfccs = dct_matrix * mel_power_spec;
end
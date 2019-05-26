% Chris Miller
% crm313
% Music Information Retrieval
% Final

function [ scatCoeff, fs_scat, basis ] = compute_scattering_coeffs( filepath, win_size, hop_size, ...
    min_freq, max_freq, num_mel_filts, m)
%
% compute_scattering_coeffs: compute scattering transform coefficients
%
%   INPUTS:
%       filepath        - audio file for analysis
%       win_size        - window size (samples)
%       hop_size        - hop size (samples)
%       min_freq        - minimum frequency in Mel filterbank (Hz)
%       max_freq        - maximum frequency in Mel filterbank (Hz)
%       num_mel_filts   - number of filters for Mel filterbank
%       m               - scattering transform order (1 or 2)
%
%   OUTPUTS:
%       scatCoeff       - m-order scattering coefficients 
%                             ((no. filters x m) x no. windows)
%       fs_scat         - sampling frequency of scattering frames (samples/sec)
%       basis           - time-domain wavelet basis
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[x_t, fs, t] = import_audio(filepath);
overlap = win_size - hop_size;
phi = gausswin(win_size);
x_windowed = buffer(x_t,win_size,overlap);
[X,F,T] = spectrogram(x_t, phi, overlap, win_size, fs); 
nWins = size(X,2);
Fmel = hz2mel(F);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build morlet wavelet filter bank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


minMel = hz2mel(min_freq);
maxMel = hz2mel(max_freq);
melCenters = linspace(minMel,maxMel,num_mel_filts);

% find (linear) difference between consecutive Mel filters
deltaMel = melCenters(2)-melCenters(1);
melCenters = [melCenters (maxMel + deltaMel)];

% find bandwidth of each filter -- make twice the standard deviation
%       of each filter coincide with start of the next filter
% bandwidths therefore constant below 1000 Hz / proportional to lambda above
for j = 1:num_mel_filts
    sigma(j) = (mel2hz(melCenters(j+1)) - mel2hz(melCenters(j)))/2;
end

% center frequencies (lambda) in Hz
lambda = mel2hz(melCenters(1:end-1));
mu = F(find_nearest(F,lambda));

psi = zeros(length(F),num_mel_filts+1);
for j = 1:num_mel_filts
    psi(:,j+1) = normpdf(F,mu(j),sigma(j));
end

% create low-pass filter phi (fourier transform of window function)
% psi(1) is phi
sigmaLP = lambda(1)/2;
psi(:,1) = normpdf(F,0,sigmaLP);

% normalize morlet filterbank
for j = 1:num_mel_filts+1
    psi(:,j) = psi(:,j)/norm(psi(:,j),1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scattering transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% transform wavelet basis into time domain
basis = real(ifft(psi,win_size));

% unwrap wavelets
basis = [basis(win_size/2 + 1:end,:); basis(1:win_size/2,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first-order scattering coefficients -- same as MFSCs
if m == 1
    scatCoeff = abs(psi(:,2:end)'*X);

    % convert to dB
    scatCoeff = 20*log10(scatCoeff);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second-order scattering coefficients
if m==2
    for i = 1:nWins
        for j = 1:num_mel_filts
            for k = 1:num_mel_filts
                scatCoeff(j,k,i) = sum(abs(abs(psi(:,j+1).*X(:,i)).*psi(:,k+1)));
            end
        end
    end
end

% scattering sampling frequency
fs_scat = fs/hop_size;

end


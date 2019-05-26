function features = compute_features(mfccs, fs_mfcc)
% Compute features from MFCCs.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% mfccs : n dct x NT matrix
% MFCC matrix
% fs mfcc : int
% sample rate of MFCC matrix (samples/sec)
%
% Returns
% -------
% features: NF X NE
% matrix of segmented and averaged MFCCs
% (NF is number of features = n dct-1 and
% NE is number of examples)
    
    % Remove DC content
    mfccs = mfccs(2:end, :);
    
    [N, M] = size(mfccs);
    hop_size = floor(fs_mfcc);
    % Floor removes the last fraction of a second sample
    NE = floor(M/hop_size);
    
    features = zeros(N, NE);
    for m = 1:NE
        first = (m-1)*hop_size+1;
        last = m*hop_size;
        % This is only needed if including the last fractional second
%         if last > M
%             last = M;
%         end
        features(:, m) = mean(mfccs(:, first:last), 2);
    end

end
% Chris Miller
% crm313
% Music Information Retrieval
% FINAL

function [ features ] = compute_features( scatCoeff, fs_scat, n_dct )
%
% compute_features: construct feature vector from mfccs
%
%   INPUTS:
%       scatCoeff       - tensor of scattering coefficients
%       fs_scat         - sampling frequency of MFCC frames (samples/sec)
%       n_dct           - number of DCT coefficients
%
%   OUTPUTS:
%       features        - matrix of feature vectors
%

% order of input scattering coefficients
m = length(size(scatCoeff)) - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% feature extraction from first-order scattering transform

if m == 1
    % take DCT
    S1 = dct(scatCoeff);
    S1 = S1(1:n_dct,:);

    % remove first component
    S1 = S1(2:end,:);

    % average first-order scattering coeffs across one-second windows
    winSize = round(fs_scat);
    numWins = floor(size(S1,2)/winSize);
    features = zeros(size(S1,1),numWins);

    for coeff=1:size(S1,1)
        for idx=1:numWins
            startIdx = (idx-1)*winSize + 1;
            endIdx = idx*winSize;
            features(coeff,idx) = mean(S1(coeff,startIdx:endIdx));
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% feature extraction from second-order scattering transform

if m == 2
    
    numFilts = size(scatCoeff,1);
    N = size(scatCoeff,3);
    winSize = round(fs_scat);
    numWins = floor(N/winSize);
    sDCT = zeros(N,numFilts,numFilts);
    
    % take DCTs first along k and then along j
    sPermute = permute(scatCoeff,[3 1 2]);
    for k = 1:numFilts
        scatCos2 = dct(squeeze(sPermute(:,:,k))')';
        sDCT(:,:,k) = scatCos2;
    end
    
    sDCT = permute(sDCT,[1 3 2]);
    for j = 1:numFilts
        scatCos1 = dct(squeeze(sPermute(:,j,:))')';
        sDCT(:,:,j) = scatCos1;
    end
    sDCT = permute(sDCT,[2 3 1]);
    sDCT = sDCT(1:n_dct,1:n_dct,:);

    % PCA for dimensionality reduction on each numFilts x numFilts matrix
    % of scattering coefficients
    sPCA = zeros(n_dct,N);
    for i = 1:N
        [U,S,V] = svd(sDCT(:,:,i));
        proj1D = U*S;
        sing1(i) = S(1,1);
        sing2(i) = S(2,2);
        proj1D = proj1D(1,:);
        sPCA(:,i) = proj1D;
    end

    % remove first component
    sPCA = sPCA(2:end,:);
    
    % average second-order scattering coeffs across one-second windows
    winSize = round(fs_scat);
    numWins = floor(size(sPCA,2)/winSize);
    features = zeros(size(sPCA,1),numWins);

    for coeff=1:size(sPCA,1)
        for idx=1:numWins
            startIdx = (idx-1)*winSize + 1;
            endIdx = idx*winSize;
            features(coeff,idx) = mean(sPCA(coeff,startIdx:endIdx));
        end
    end
    
end

end



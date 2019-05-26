function [features_norm] = normalize_features(features)
% Normalize matrix of features.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% features: NF x NE matrix
% matrix of features (NF is number of
% features and NE is number of examples)
% a: NF x 1 array
% normalization parameter (optional)
% b: NF x 1 array
% normalization parameter (optional)
%
% Returns
% -------
% features norm: NF x NE matrix
% matrix of normalized features (NF is number of
% features and NT is number of examples)
% a: NF x 1 array
% normalization parameter
% b: NF x 1 array
% normalization parameter

%     if (~exist('a', 'var'))
%         a = min(features, [], 2);
%     end
%     if (~exist('b', 'var'))
%         b = max(bsxfun(@minus,features,a), [], 2);
%     end
    % Normalize across rows
    %features_norm = bsxfun(@rdivide, (bsxfun(@minus,features,a)), b);
    
    % Ignore a and b, normalize across columns instead
    features_norm = zeros(size(features));
    for m = 1:size(features, 2)
        n = norm(features(:, m), 2);
        if n ~= 0
            features_norm(:, m) = features(:, m)/n;
        end
    end
end
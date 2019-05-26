function [train_features, train_labels] = create_train_set(files, labels, params)
% Compute features and parameters for train
%
% Parameters
% ----------
% file_paths: cell-array of cell-arrays
% list of full paths to audio files with train data
% params: struct
% Matlab structure with fields are win size, hop size,
% min freq, max freq, num mel filts, n dct, the parameters
% needed for computation of MFCCs
%
% Returns
% -------
% train features: NF x NE matrix
% matrix of training set features (NF is number of
% features and NT is number of feature instances)
% train labels: 1 x NE array
% vector of labels (class numbers) for each instance
% of train features
    % Initialize scatterbox package
    addpath(genpath('scatterbox'));
    startup();
    
    train_labels = [];
    train_features = [];
    
    for i = 1:length(files)
        disp(['instrument: ', num2str(i)]);
        for f = 1:length(files{i})
            disp(files{i}{f});
            features = compute_cl_scatt(files{i}{f}, params.opt);
            
            train_features = [train_features, features];
            train_labels = [train_labels, ones(1,size(features,2)) * i];
        end
    end
    
    % Normalize all features together
    train_features = normalize_features(train_features);
    
    % Convert int labels to strings
    train_labels = labels(train_labels);
end
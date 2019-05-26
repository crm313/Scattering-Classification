function [test_features, test_labels] = create_test_set(files, labels, params)
% Compute features and parameters for test data.
%
% Parameters
% ----------
% file_paths: cell-array
% list of full paths to audio files with test data
% params: struct
% struct storing the parameters
% needed for computation of MFCCs.
% The fields of the struct are: win size, hop size,
% min freq, max freq, num mel filts, n dct
% a: float
% normalization parameter
% b: float
% normalization parameter
%
% Returns
% -------
% test features: NF x NE matrix
% matrix of test set features (NF is number of
% features and NT is number of feature instances)
% test labels: 1 x NE array
% vector of labels (class numbers) for each instance
% of test features
    % Initialize scatterbox package
    addpath(genpath('scatterbox'));
    startup();

    test_labels = [];
    test_features = [];
    
    for i = 1:length(files)
        disp(['instrument: ', num2str(i)]);
        for f = 1:length(files{i})
            features = compute_cl_scatt(files{i}{f}, params.opt);

            test_features = [test_features, features];
            test_labels = [test_labels, ones(1,size(features,2)) * i];
        end
    end

    % Normalize
    test_features = normalize_features(test_features);

    % Convert int labels to strings
    test_labels = labels(test_labels);
end
function predicted_labels = knn_predict(train_features, train_labels, test_features, k)
% Predict the labels of the test features,
% given training features and labels,
% using a k-nearest-neighbor classifier.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% train features: NF x NE train matrix
% matrix of training set features (NF is number of
% features and NE train is number of feature instances)
% train labels: 1 x NE train array
% vector of labels (class numbers) for each instance
% of train features
% test features: NF x NE test matrix
% matrix of test set features (NF is number of
% features and NE test is number of feature instances)
% k: integer
% Optional number of nearest neighbors to use
%
% Returns
% -------
% predicted labels: 1 x NE test array
% array of predicted labels

    if (~exist('k', 'var'))
        % If k is not given, use sqrt of L
        [~, L] = size(train_features);
        k = floor(sqrt(L));
        disp(['k = ', num2str(k)]);
    end
    
    [F, M] = size(test_features);
    predicted_labels = cell(1, M);
    
    for m = 1:M
        dot_product = train_features' * test_features(:, m);

        % K-Nearest Neighbor
        [~, sorted_indices] = sort(dot_product(:), 'descend');
        sorted_indices = sorted_indices(1:k);
        [unique_strings, ~, string_map] = unique(train_labels(sorted_indices));
        label = unique_strings(mode(string_map));
        
        predicted_labels(m) = label;
    end
    
end
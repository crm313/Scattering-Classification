function [predicted_labels, accuracy, prob] = svm_predict(train_features, train_labels, test_features, test_labels)
    cost = 1.1;
    gamma = 4;

    % Use the libsvm library instead of matlabs svm
    addpath(genpath('libsvm'));
    addpath(genpath('../tools'));
    
    unique_labels = unique(train_labels);
    num_labels = length(unique_labels);
    integer_labels = zeros(size(train_labels));
    for l = 1:length(train_features)
        integer_labels(l) = find(strcmp(unique_labels, train_labels(l)));
    end
    if ~exist('test_labels', 'var')
        % Create random test_labels
        % Accuracy won't make sense, but we need something to pass to svmpredict
        integer_test_labels = randi([1 num_labels], length(test_features), 1);
    else
        integer_test_labels = zeros(size(test_labels));
        for l = 1:length(test_features)
            integer_test_labels(l) = find(strcmp(unique_labels, test_labels(l)));
        end
    end

    % train one-against-one model
    options = ['-g ' num2str(gamma) ' -c ' num2str(cost) ' -h 0'];
    model = svmtrain(integer_labels, train_features, options);
    
    [predicted_labels, accuracy, prob] = svmpredict(integer_test_labels, test_features, model);

    predicted_labels = unique_labels(predicted_labels);
end
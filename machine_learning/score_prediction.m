function [overall_accuracy, per_class_accuracy] = ...
score_prediction(test_labels, predicted_labels)
% Compute the confusion matrix given the test labels and predicted labels.
%
% Colin Fahy
% cpf247@nyu.edu
%
% Parameters
% ----------
% test labels: 1 x NE array
% array of ground truth labels for test data
% predicted labels: 1 x NE test array
% array of predicted labels
%
% Returns
% -------
% overall accuracy: scalar
% The fraction of correctly classified examples.
% per class accuracy: 1 x 4 array
% The fraction of correctly classified examples
% for each instrument class.
% per class accuracy[1] should give the value for
% instrument class 1, per class accuracy[2] for
% instrument class 2, etc.

    [confusion, order] = confusionmat(test_labels, predicted_labels);
    
    [T, P] = size(confusion);
        
    % Sum of diagonal elements
    correct = trace(confusion);
    total = sum(sum(confusion));
    overall_accuracy= correct/total;
    
    per_class_accuracy = zeros(1, P);
    for i = 1:P
        class_correct = sum(confusion(i,i));
        class_total = sum(confusion(i,:));
        per_class_accuracy(i) = class_correct/class_total;
    end
    
    plot_confusion(confusion, order);
end
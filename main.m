function main(train_dir, test_dir, feature, classifier, model_file)
    tic;
    % Default values for optional parameters
    if ~exist('train_dir', 'var')
       train_dir = 'data/train';
    end
    if ~exist('test_dir', 'var')
       test_dir = 'data/test';
    end
    if ~exist('feature', 'var')
       feature = 'mfcc';
    end
    if ~exist('classifier', 'var')
       classifier = 'knn';
    end
    if ~strmatch(classifier, {'svm', 'knn'})
        error('classifier must be one of: [svm, knn]');
    end
    if exist('model_file', 'var') && exist(model_file, 'file')
       disp(['Loading train features from:', model_file]);
       model = load(model_file);
    else
        model = struct();
        % Set parameters
        model.params.win_size = 1024;
        model.params.hop_size = 512;
        model.params.min_freq = 60;
        model.params.max_freq = 8000;
        model.params.num_mel_filts = 40;
        model.params.n_dct = 15;
    end
    
    % Add required paths
    addpath(genpath('machine_learning'));
    addpath(genpath('tools'));
    if strcmp(feature, 'mfcc')
        addpath(genpath('feature_extraction/mfcc'));
    elseif strcmp(feature, 'scattering')
        addpath(genpath('feature_extraction/scattering'));
        model.params.opt.M = 1;
    elseif strcmp(feature, 'cls1')
        addpath(genpath('feature_extraction/scattering2'));
        model.params.opt.M = 1;     % Scattering order
        model.params.opt.J = 8;	% Maximal scale corresponding to T=Q*2^(J/Q+1),
    elseif strcmp(feature, 'cls2')
        addpath(genpath('feature_extraction/scattering2'));
        model.params.opt.M = 2;
        model.params.opt.J = 16;
    end
    
    % Get cell-array of train and test files/labels
    disp('Loading files...');
    [train_files, train_classes] = get_files(train_dir);
    [test_files, test_classes] = get_files(test_dir);
    
    % Compute Features
    if ~isfield(model, {'train_features', 'train_labels'})
        toc;
        disp('Computing train features...');
        [train_features, train_labels] = create_train_set(train_files, train_classes, model.params);
        model.train_features = train_features;
        model.train_labels = train_labels;
        if exist('model_file', 'var')
            save(model_file, '-struct', 'model');
        end
    end
    toc;
    disp('Computing test features...');
    [test_features, test_labels] = create_test_set(test_files, test_classes, model.params);
    
    % Predict class
    toc;
    disp('Predicting labels...');
    if strcmp(classifier, 'knn')
        predicted_labels = knn_predict(model.train_features, model.train_labels, test_features);
    elseif strcmp(classifier, 'svm')
        predicted_labels = svm_predict(model.train_features', model.train_labels', test_features', test_labels')';
    end
    
    [overall_accuracy, per_class_accuracy] = score_prediction(test_labels, predicted_labels);
    
    disp(['Overall Accuracy: ', num2str(overall_accuracy)]);
    disp(['Per Class Accuracy: ', num2str(per_class_accuracy)]);
    disp(char(10));
    
    if ~exist('output', 'dir')
       mkdir('output');
    end 
    toc;
    disp('Saving figure...');
    % Set Dimensions before saving
    title(['Feature: ' upper(feature) '    Classifier: ' upper(classifier) '    Overall Accuracy: ' num2str(overall_accuracy*100) '%']);
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 10]);
    set(gcf, 'PaperSize', [16 10]);
    set(gcf,'renderer','painters');
    print(gcf, '-r1600', '-painters', ['output/', datestr(clock, 0), '_', feature, '_', classifier], '-depsc2');
    
    disp('Done');
    toc;
end
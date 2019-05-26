function features = compute_cl_scatt(filepath, params)
% Compute features from a given audio filepath
% averaged over seconds using the Scatterbox package.

    [x1, fs1, t] = import_audio(filepath);
    % J = 8 for example. can compare how classification differs for, say, J=4
    [f1] = cl_scatt(x1,params);
    f1 = f1';
    % average over 1 second windows
    winSize = round(size(f1,2)/(length(x1)/fs1));
    numWins = floor(size(f1,2)/winSize);
    features = zeros(size(f1,1),numWins);

    for coeff=1:size(f1,1)
        for idx=1:numWins
            startIdx = (idx-1)*winSize + 1;
            endIdx = idx*winSize;
            features(coeff,idx) = mean(f1(coeff,startIdx:endIdx));
        end
    end
end
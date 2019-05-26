function plot_confusion(confusion_matrix, order)
% Plot a confusion matrix

    [T, P] = size(confusion_matrix);
    
    % Create percentage confusion matrix
    percent_confusion = zeros(size(confusion_matrix));
    for i = 1:T
        class_total = sum(confusion_matrix(i,:));
        percent_confusion(i,:) = confusion_matrix(i,:)/class_total;
    end
    
    % Plot the confusion matrix
    disp(confusion_matrix);
    figure('units','normalized','outerposition',[0 0 1 1])
    str_confusion = [num2str(confusion_matrix(:)),...
                     repmat(10, T*P, 1),...% Newline
                     num2str(percent_confusion(:)*100, '%0.2f'),...
                     repmat('%', T*P, 1)];
    imagesc(percent_confusion);
    colormap(flipud(gray));
    [x,y] = meshgrid(1:P);
    hStrings = text(x(:),y(:),str_confusion, 'HorizontalAlignment','center');
    midValue = mean(get(gca,'CLim'));
    textColors = repmat(percent_confusion(:) > midValue,1,3);
    set(hStrings,{'Color'},num2cell(textColors,2));
    set(gca,...
        'XTick',1:P,...
        'XTickLabel',order,...
        'YTick',1:P,...
        'YTickLabel',order,...
        'TickLength',[0 0]);
end
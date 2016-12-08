% compareFeatureStatsIMPROVED.m
% This script produces histograms of the standard statistics for each
% feature, across all 535 recordings


features_ALL = [featuresALL.features];

n = length(features_ALL);

cases{1} = 'mean';
cases{2} = 'median';
cases{3} = 'stdev';
cases{4} = 'min';
cases{5} = 'max';

%featuresALL(1).features(28,:)

for j = 1:5
    for i = 1:35
        switch j
            case 1
                for k = 1:length(featuresALL)
                    test(k) = mean(featuresALL(k).features(i,:));
                end

            case 2
                for k = 1:length(featuresALL)
                    test(k) = median(featuresALL(k).features(i,:));
                end
            case 3
                for k = 1:length(featuresALL)
                    test(k) = std(featuresALL(k).features(i,:));
                end
            case 4
                for k = 1:length(featuresALL)
                    test(k) = min(featuresALL(k).features(i,:));
                end
            case 5
                for k = 1:length(featuresALL)
                    test(k) = max(featuresALL(k).features(i,:));
                end
        end
        
        h = histogram(test);
        title(['Feature ' num2str(i) ', Stat: ' cases{j}])
        pause
    end
end
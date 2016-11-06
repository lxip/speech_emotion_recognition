function compareEmoIntra(featuresALL, speaker, emotion)
% This function can be used to compare frequency histograms of features for
% different textcodes given a constant speaker and emotion.

% speakerIDs = unique([featuresALL.speaker]); %
speakers = [featuresALL.speaker]';
emotions = [featuresALL.emotion]';
hold on

mask = (emotions == emotion & ... %repmat(emotion,length(emotions),1) & ...
    speakers == speaker); %repmat(speaker,length(speakers),1));

data = featuresALL(mask);

for j = 1:35
    clf
    hold on
    for i = 1:length(data)
        [counts,bin_edges] = histcounts(featuresALL(i).features(j,:));
        plot(bin_edges(1:end-1),counts./sum(counts))
    end
    title({['Speaker: ' num2str(speaker) ... %num2str(data(speaker).speaker) ...
        ' Emotion: ' emotion ]... %num2str(data(speaker).emotion)]; ...
        ['Feature: ' num2str(j)]});
    pause
end

end
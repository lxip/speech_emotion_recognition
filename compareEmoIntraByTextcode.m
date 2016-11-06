function compareEmoIntraByTextcode(featuresALL, speaker, textcode)
% This function can be used to compare frequency histograms of features for
% different emotions given a constant speaker and textcode.

% speakerIDs = unique([featuresALL.speaker]); %
speakers = [featuresALL.speaker]';
textcodes = reshape([featuresALL.textcode],3,length(featuresALL))';
hold on

mask = sum(textcodes == repmat(textcode,length(featuresALL),1),2) == 3 & ...
    speakers == speaker;

data = featuresALL(mask);
leg = [];
for j = 1:35
    clf
    hold on
    for i = 1:length(data)
        [counts,bin_edges] = histcounts(featuresALL(i).features(j,:));
        plot(bin_edges(1:end-1),counts./sum(counts))
        leg = [leg data(i).emotion];
    end
    title({['Speaker: ' num2str(speaker) ... %num2str(data(speaker).speaker) ...
        ' Text code: ' textcode ]... %num2str(data(speaker).emotion)]; ...
        ['Feature: ' num2str(j)]});
    legend(leg');
    pause
end

end
function compareEmoInter(featuresALL, speaker1, speaker2, emotion)

% speakerIDs = unique([featuresALL.speaker]); %
speakers = [featuresALL.speaker]';
emotions = [featuresALL.emotion]';

mask1 = (emotions == repmat(emotion,length(emotions),1) & ...
    speakers == repmat(speaker1,length(speakers),1));

mask2 = (emotions == repmat(emotion,length(emotions),1) & ...
    speakers == repmat(speaker2,length(speakers),1));

data1 = featuresALL(mask1);
data2 = featuresALL(mask2);

spk1 = cell(length(data1),1);
spk2 = cell(length(data2),1);

for i = 1:length(data1)
    spk1{i} = data1(i).features;
end
for i = 1:length(data2)
    spk2{i} = data2(i).features;
end

spk1mean = meanExt2(spk1);
spk2mean = meanExt2(spk2);

for j = 1:35
    clf
    hold on
    
    [counts,bin_edges] = histcounts(spk1mean(j,:));
    plot(bin_edges(1:end-1),counts./sum(counts),'r')
    
    [counts,bin_edges] = histcounts(spk2mean(j,:));
    plot(bin_edges(1:end-1),counts./sum(counts),'b')
    title({['Speaker ' num2str(speaker1) ' vs. Speaker ' num2str(speaker2) ...
        ', Emotion: ' emotion]; ...
        ['Feature: ' num2str(j)]});
    legend(['Speaker ' num2str(speaker1)], ['Speaker ' num2str(speaker2)])
    pause
end

end
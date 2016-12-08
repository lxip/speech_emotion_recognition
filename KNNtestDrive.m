% A drive for running KNN classifier in the library.
% Made to permutaion tests: get KNN score on every single feature
% Also do the permutation test for difference between two accuracy 
    %Ac1 Ac2 in the KNN result
% Creator: Xipei Liu
% Last Edited: 2016-11-18
clc;
clear all;
load('featuresGerman37.mat')


emos = unique([featuresALL.emotion])'; % All unique emotions
speakers = unique([featuresALL.speaker])'; % All unique speakers
emotions = [featuresALL.emotion]';
numfeatures = size([featuresALL.features],1); 
numstats = 5; % mean,median,std,min,max

% emoPick = datasample(emos',2,'Replace',false);
emoPick = 'WE';
disp(['Emotion ',emoPick(1), ' and ',emoPick(2),' are picked.']);


for i = 1:length(emoPick)
    feature_emo{i} = featuresALL(emotions==emoPick(i));
    featureData{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
end

for i = 1:length(featureData)
   for j = 1:size(featureData{i},2)
       featureData{i}((1:numfeatures)*numstats-(numstats-1),j) = mean  (feature_emo{i}(j).features,2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-2),j) = median(feature_emo{i}(j).features,2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-3),j) = std   (feature_emo{i}(j).features,0,2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-4),j) = min   (feature_emo{i}(j).features,[],2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-5),j) = max   (feature_emo{i}(j).features,[],2)';
   end
end
clearvars i j;

%% Experiment 
% the classification result for each feature, KNN working or not, unsorted
nreps = 1;% no need for extra rep
accus1 = zeros(nreps, numfeatures*numstats);
accus2 = zeros(nreps, numfeatures*numstats);
for n = 1:nreps
    for j = 1:numfeatures*numstats
        for i = 1:length(featureData)
            featureSelect{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
            featureSelect{i}(j,:) = featureData{i}(j,:);%commend out this line for accuracy test
        end
        [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                evaluateClassifier(featureSelect, 2, 1, [0.8,35]);
        % repeat 35 times for each classification, .8 training .2 testing
        % randomly assign in each generation
        % 2 nearest neighbor used
        accus1(n,j) = Ac1;
        accus2(n,j) = Ac2;
    end
end

%%
%%%
figure('units','normalized','position',[.1 .1 .8 .4])
hold on
% plot(mean(accus1),'-*')
% plot(mean(accus2),'-^')
plot(accus1,'-*')
plot(accus2,'-^')
set(gca,'XTick',linspace(0,190,6))
set(gca,'ylim',[0.4,1])
xlabel('repetition')
ylabel('accuracy')
legend('Ac for G-normalization','Ac for RW-normalization')
title(['KNN: accuracy difference with zero feature turned on. Choose emotion ',emoPick(1),' and ',emoPick(2)'])
      



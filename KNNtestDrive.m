% A drive for running KNN classifier in the library.
% And plot for showing the functionality on selected emotions.
% Creator: Xipei Liu
% Last Edited: 2016-11-18
clc;
clear all;
load('featuresGerman.mat')

% iter = [1,5,10,30,50,100,200,300,500,1000];
% 
% for loop = 1:6
emos = unique([featuresALL.emotion])'; % All unique emotions
speakers = unique([featuresALL.speaker])'; % All unique speakers
emotions = [featuresALL.emotion]';
numfeatures = size([featuresALL.features],1); 
numstats = 5; % mean,median,std,min,max

emoPick = datasample(emos',2,'Replace',false); 
disp(['Emotion ',emoPick(1), ' and ',emoPick(2),' are picked.']);

for i = 1:length(emoPick)
    feature_emo{i} = featuresALL(emotions==emoPick(i));
    featureData{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
end

for i = 1:length(featureData)
   for j = 1:size(featureData{i},2)
       featureData{i}((1:numfeatures)+numfeatures*(numstats-5),j) = mean  (feature_emo{i}(j).features,2)';
       featureData{i}((1:numfeatures)+numfeatures*(numstats-4),j) = median(feature_emo{i}(j).features,2)';
       featureData{i}((1:numfeatures)+numfeatures*(numstats-3),j) = std   (feature_emo{i}(j).features,0,2)';
       featureData{i}((1:numfeatures)+numfeatures*(numstats-2),j) = min   (feature_emo{i}(j).features,[],2)';
       featureData{i}((1:numfeatures)+numfeatures*(numstats-1),j) = max   (feature_emo{i}(j).features,[],2)';
   end
end
clearvars i j;


% %%% Experiment 1
% % the performance for different reps: may speed up KNN(?)
% 
% accus_iter{loop} = zeros(2,length(iter));
% for i = 1:length(iter)
%     [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
%         evaluateClassifier(featureData, 2, 1, [0.8,iter(i)]);
%     accus_iter{loop}(1,i) = Ac1;
%     accus_iter{loop}(2,i) = Ac2;
% end
% end
% 
% %%%
% figure('units','normalized','position',[.1 .1 .8 .4])
% hold on
% for loop=1:6
%     plot(iter,accus_iter{loop}(1,:)','-*')
%     plot(iter,accus_iter{loop}(2,:)','-^')
% end
% set(gca,'XTick',iter)
% set(gca,'xscale','log')
% xlabel(['feature # for emotion ',emoPick(1),' and ',emoPick(2)])
% ylabel('accuracy')
% legend('Ac for G-normalization','Ac for RW-normalization')
% title('KNN: different iteration for choosen 6 emotions classification result (shown in different colors)')


%% Experiment 2
% the classification result for each feature, KNN working or not
nreps = 2;
accus1 = zeros(nreps, numfeatures*numstats);
accus2 = zeros(nreps, numfeatures*numstats);
for n = 1:nreps
    for j = 1:numfeatures*numstats
        for i = 1:length(featureData)
            featureSelect{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
            featureSelect{i}(j,:) = featureData{i}(j,:);
        end
        [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                evaluateClassifier(featureSelect, 2, 1, [0.8,100]);
        % repeat 100 times for each classification, 80%train?ing 20%testing
        accus1(n,j) = Ac1;
        accus2(n,j) = Ac2;
    end
end
%%%
figure('units','normalized','position',[.1 .1 .8 .4])
hold on
plot(mean(accus1),'-*')
plot(mean(accus2),'-^')
set(gca,'XTick',linspace(0,175,6))
xlabel(['feature # for emotion ',emoPick(1),' and ',emoPick(2)])
ylabel('accuracy')
legend('Ac for G-normalization','Ac for RW-normalization')
title('KNN: single feature classification result for selected emotions')
      



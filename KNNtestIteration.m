% A drive for running KNN classifier in the library.
% And plot for showing the functionality on selected emotions.
% Creator: Xipei Liu
% Last Edited: 2016-11-18


%% prepare emotion data
clc;
clear all;
load('featuresGerman37.mat')

% %%% prepare gender data
% gender = [featuresALL.gender]'; % gender info for all recordings
% genderPick = unique(gender);
% numfeatures = size([featuresALL.features],1); 
% numstats = 5; % mean,median,std,min,max
% 
% for i = 1:length(genderPick)
%     feature_emo{i} = featuresALL(gender==genderPick(i));
%     featureData{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
% end


emos = unique([featuresALL.emotion])'; % All unique emotions
emotions = [featuresALL.emotion]';
numfeatures = size([featuresALL.features],1); 
numstats = 5; % mean,median,std,min,max

emoPick = datasample(emos',2,'Replace',false); 
disp(['Emotion ',emoPick(1), ' and ',emoPick(2),' are picked for this run.']);


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
% the performance for different reps: speed up KNN

iter = linspace(0,100,21);
iter(1) = 1;
rep = 10;

Ac_results = zeros(rep,length(iter));
Ft_results = zeros(rep,length(iter));

for i = 1:rep
    for j = 1:length(iter)
        [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
            evaluateClassifier(featureData, 10, 1, [0.8,iter(j)]);
        Ac_results(i,j) = (Ac1+Ac2)/2;
%         Ft_results(i,j) = (Re1+Re2)*(Pr1+Pr2)/(Pr1+Pr2+Re1+Re2);
    end
end

%% Plotting

mean_Ac_results = mean(Ac_results);
std_Ac_results = std(Ac_results);

figure('units','normalized','position',[.1 .1 .6 .6])
subplot(2,1,1)
hold on;
plot(iter(1:2),mean_Ac_results(1:2),'b*-')
errorbar(iter(2:end), mean_Ac_results(2:end),std_Ac_results(2:end),'b*-')
set(gca,'XTick',iter)
xlim([0,iter(end)+1])
ylabel('mean accuracy and std')
title('KNN: different accuracy for choosen iterations, use emotion W and N.')


subplot(2,1,2)
hold on
plot(iter(2:end),std_Ac_results(2:end),'^-')
set(gca,'XTick',iter)
xlim([0,iter(end)+1])
xlabel('iterations')
ylabel('std for accuracy')




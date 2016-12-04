% A drive for running KNN classifier in the library.
% And plot for showing the functionality on selected emotions.
% Creator: Xipei Liu
% Last Edited: 2016-12-02

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
% the k parameter of KNN effects the result


for i = 1:size(featureData,2)
    Nsamples(i) = size(featureData{i},2);
end
kmax = floor(0.2*min(Nsamples)); %use 0.2*Nsamples as the upper limit for emotion
% kmax = floor(0.1*min(Nsamples)); %use 0.1*Nsamples as the upper limit for
% gender
k2run = linspace(1,kmax,kmax); %get the group of k parameters

rep = 10;
Ac_results = zeros(rep,length(k2run));
T_results = zeros(rep,length(k2run));
for j = 1:rep
    for i = 1:length(k2run)
        tic;
        [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                evaluateClassifier(featureData, k2run(i), 1, [0.8,20]);
        Ac_results(j,i) = (Ac1+Ac2)/2;
        T_results(j,i) = toc;
    end
end

%% Plotting
mean_Ac_results = mean(Ac_results);
std_Ac_results  = std(Ac_results);
mean_T_results  = mean(T_results);
std_T_results   = std(T_results);

figure('units','normalized','position',[.1 .1 .8 .8])

subplot(2,2,1)
hold on
errorbar(k2run, mean_Ac_results,std_Ac_results,'b*-')
set(gca,'XTick',k2run)
xlim([0,k2run(end)+1])
ylabel('mean accuracy and std')

subplot(2,2,2)
plot(k2run,std_Ac_results,'b^-')
set(gca,'XTick',k2run)
xlim([0,k2run(end)+1])
ylabel('std for accuracy')

subplot(2,2,3)
errorbar(k2run, mean_T_results,std_T_results,'ro-')
set(gca,'XTick',k2run)
xlim([0,k2run(end)+1])
ylabel('mean time and std')
xlabel('k parameter')

subplot(2,2,4)
plot(k2run,std_T_results,'r^-')
set(gca,'XTick',k2run)
xlim([0,k2run(end)+1])
ylabel('std for time')
xlabel('k parameter')

supertitle('KNN: difference of accuracy and time for choosen k param, use emotion A and T')
      



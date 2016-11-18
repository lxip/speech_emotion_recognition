% A drive for running KNN classifier in the library.
% Creator: Xipei Liu
% Last Edited: 2016-11-18
clc;
clear all;
load('featuresGerman.mat')


% emos = unique([featuresALL.emotion])'; % All emotions
% speakers = unique([featuresALL.speaker])'; % All speakers
% 
% emo12 = datasample(emos',2,'Replace',false);


% Pick out 2 emotions
emo1 = 'W'; %anger
emo2 = 'F'; %happiness

% select out just those 2 emotions
emotions = [featuresALL.emotion]';

data_emo1 = featuresALL(emotions == emo1);
data_emo2 = featuresALL(emotions == emo2);

%%
% Set up the data matrix
numfeatures = 35;
numstats = 5;
featureData_emo1 = zeros(length(data_emo1), numfeatures*numstats);
featureData_emo2 = zeros(length(data_emo2), numfeatures*numstats);
%%

for i = 1:size(featureData_emo1,1)
    featureData_emo1(i,(1:35)*numstats-(numstats-1)) = mean  (data_emo1(i).features, 2);
    featureData_emo1(i,(1:35)*numstats-(numstats-2)) = median(data_emo1(i).features, 2);
    featureData_emo1(i,(1:35)*numstats-(numstats-3)) = std   (data_emo1(i).features,0,2);
    featureData_emo1(i,(1:35)*numstats-(numstats-4)) = min   (data_emo1(i).features,[],2);
    featureData_emo1(i,(1:35)*numstats-(numstats-5)) = max   (data_emo1(i).features,[],2); 
end

for j = 1:size(featureData_emo2,1)
    featureData_emo2(j,(1:35)*numstats-(numstats-1)) = mean  (data_emo2(j).features, 2);
    featureData_emo2(j,(1:35)*numstats-(numstats-2)) = median(data_emo2(j).features, 2);
    featureData_emo2(j,(1:35)*numstats-(numstats-3)) = std   (data_emo2(j).features,0,2);
    featureData_emo2(j,(1:35)*numstats-(numstats-4)) = min   (data_emo2(j).features,[],2);
    featureData_emo2(j,(1:35)*numstats-(numstats-5)) = max   (data_emo2(j).features,[],2); 
end

clearvars i j;

featureData = {featureData_emo1',featureData_emo2'};



%%
[CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                evaluateClassifier(featureData, 2, 1, [0.8,500]);
            

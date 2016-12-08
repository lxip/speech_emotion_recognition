% scrappaper

load('featuresGerman.mat')

global featureData % declare global so the fitness fct can see it

%%%%%%%%%%% Code to re-use when classifying by emotion (not gender) %%%%%%%
% emos = unique([featuresALL.emotion])'; % All emotions
% speakers = unique([featuresALL.speaker])'; % All speakers
% Pick out 2 emotions
% emo1 = 'W'; %anger
% emo2 = 'F'; %happiness
% select out just those 2 emotions
% emotions = [featuresALL.emotion]';
% data_emo1 = featuresALL(emotions == emo1);
% data_emo2 = featuresALL(emotions == emo2);


gender = [featuresALL.gender]'; % gender info for all recordings

% seleect by gender
data_m = featuresALL(gender == 'm');
data_f = featuresALL(gender == 'f');

% Relabeling to a more generic form
data_1 = data_m;
data_2 = data_f;

%%
% Set up the data matrix
numfeatures = 35;
numstats = 5;
featureData_emo1 = zeros(length(data_1), numfeatures*numstats);
featureData_emo2 = zeros(length(data_2), numfeatures*numstats);
%%

for i = 1:size(featureData_emo1,1)
    featureData_emo1(i,(1:35)*numstats-(numstats-1)) = mean  (data_1(i).features, 2);
    featureData_emo1(i,(1:35)*numstats-(numstats-2)) = median(data_1(i).features, 2);
    featureData_emo1(i,(1:35)*numstats-(numstats-3)) = std   (data_1(i).features,0,2);
    featureData_emo1(i,(1:35)*numstats-(numstats-4)) = min   (data_1(i).features,[],2);
    featureData_emo1(i,(1:35)*numstats-(numstats-5)) = max   (data_1(i).features,[],2); 
end

for j = 1:size(featureData_emo2,1)
    featureData_emo2(j,(1:35)*numstats-(numstats-1)) = mean  (data_2(j).features, 2);
    featureData_emo2(j,(1:35)*numstats-(numstats-2)) = median(data_2(j).features, 2);
    featureData_emo2(j,(1:35)*numstats-(numstats-3)) = std   (data_2(j).features,0,2);
    featureData_emo2(j,(1:35)*numstats-(numstats-4)) = min   (data_2(j).features,[],2);
    featureData_emo2(j,(1:35)*numstats-(numstats-5)) = max   (data_2(j).features,[],2); 
end

clearvars i j;

genes = eye(numfeatures*numstats);

featureData = {featureData_emo1',featureData_emo2'};

errors = zeros(175,10);

for i = 1:10
    errors(:,i) = fitnessFctKNN(genes);
end

error = mean(errors,2);
    
[error_sorted,error_sorted_idx] = sort(1-error, 'descend');

plot(error_sorted,'.')
hold on

% gaResults = history.BestIndividual(end,:);

gaResultsIdx = find(gaResults == 1);
gaResultsSortedIdx = find(ismember(error_sorted_idx,gaResultsIdx));

plot(gaResultsSortedIdx,error_sorted(gaResultsSortedIdx),'o','MarkerFaceColor','r');

%%

results_minus1 = repmat(gaResults,sum(gaResults),1);

for i = 1:length(gaResultsIdx)
    results_minus1(i,gaResultsIdx(i)) = 0;
end

fitnessFctKNN(results_minus1);
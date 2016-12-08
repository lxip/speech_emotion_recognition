% A drive for running GA-KNN 
% Creator: Larry, Xipei
% Last Edited: 2016-12-04

clear all;
load('featuresGerman37.mat') % data with 37 features

global featureData % declare global so the fitness fct can see it

numfeatures = size([featuresALL.features],1); 
numstats = 5; % expand each feature on 5 statistics: mean,median,std,min,max


%%%%%%%%%% Code to re-use when classifying by emotion (not gender) %%%%%%%
emotions = [featuresALL.emotion]';     % emotion info for all recordings
emos = unique([featuresALL.emotion])'; % All unique emotions
emos_comb = nchoosek(emos, 2);         % all possible combinations of emotions in pair

classPick = 'WF';% temporarily just random pick a combo of emotions 
disp(['Emotion ',classPick(1),' and ',classPick(2),' are picked for this run.']);
% classPick = datasample(emos',3,'Replace',false);% choose 3 emotions to classify
% disp(['Emotion ',classPick(1),',',classPick(2),' and ',classPick(3),' are picked for this run.']);

    %%%%%%%%%% Normal run for 2 picked emotion %%%%%%%
    for i = 1:length(classPick)
        featurePicked{i} = featuresALL(emotions==classPick(i));
        featureData{i} = zeros(numfeatures*numstats, length(featurePicked{i}));
    end

%         %%%%%%%%%% Permutation test for 2 picked emotion %%%%%%%
%         for i = 1:length(classPick)
%             featureLength(i) = size(featuresALL(emotions==classPick(i)),2);
%             featureData{i} = zeros(numfeatures*numstats, featureLength(i));
%         end
% 
%         featureChoose = featuresALL(find(ismember(emotions,classPick)));
%         featureChoose_shuffle = featureChoose(randperm(length(featureChoose)));
% 
%         featurePicked{1} = featureChoose_shuffle(1:featureLength(1));
%         featurePicked{2} = featureChoose_shuffle(featureLength(1)+1:end);

    
% %%%%%%%%%% Code to re-use when classifying by gender (not emotion) %%%%%%%
% gender = [featuresALL.gender]'; % gender info for all recordings
% classPick = unique(gender);
% for i = 1:length(classPick)
%     featurePicked{i} = featuresALL(gender==classPick(i));
%     featureData{i} = zeros(numfeatures*numstats, length(featurePicked{i}));
% end



%%%%%%%%%% shared code for gender and emotion %%%%%%%%%%
%%% Set up the data matrix 
for i = 1:length(featureData)
   for j = 1:size(featureData{i},2)
       featureData{i}((1:numfeatures)*numstats-(numstats-1),j) = mean  (featurePicked{i}(j).features,2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-2),j) = median(featurePicked{i}(j).features,2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-3),j) = std   (featurePicked{i}(j).features,0,2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-4),j) = min   (featurePicked{i}(j).features,[],2)';
       featureData{i}((1:numfeatures)*numstats-(numstats-5),j) = max   (featurePicked{i}(j).features,[],2)';
   end
end
clearvars i j;


%% 
%%%%%%%% GA stuff %%%%%%%%


% GA INPUT VARIABLES
P = 50;  % population size
R = .1;  % initialization rate
N = numfeatures*numstats; % genome size

eliteCt = 1;
maxGens = 300;
fitnessLim = 0;
crossoverFrac = 0.8;  % using inter/union crossover
mutationRate  = 0.01; % using bit-flip mutation

%%% VARIABLE setting in KNN classifier: k = 2, iteration = 35 (hard coded in fitnessFctKNN.m)

population = KNNpopInit(P, N, R); % Initialize population

audioOptions = gaoptimset(  'CreationFcn',    @KNNpopInit, ...
                            'CrossoverFcn',   @crossoverIntU, ... 
                            'CrossoverFraction', crossoverFrac, ...
                            'EliteCount',     eliteCt, ...
                            'FitnessLimit',   fitnessLim, ...
                            'Generations',    maxGens, ...
                            'MutationFcn',   {@mutateBitFlip,mutationRate}, ... 
                            'PopulationSize', P, ...
                            'PopulationType', 'custom', ...
                            'SelectionFcn',   @selectiontournament, ... % using tournament selection
                            'Vectorized',     'on',...
                            'OutputFcns',     @gaoutputfcn);
                         
audioOptions.InitialPopulation = population; 
        
% Run GA
tic();
[x, fval, exitflag] = ga(@fitnessFctKNN, N, audioOptions);
elp = toc();

% Save history
history = gaoutputfcn;
history.emotions = classPick;
save(['./history/history',classPick,'rerun.mat'],'history')

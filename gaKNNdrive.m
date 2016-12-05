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

emoPick = 'AF';   % temporarily just random pick a combo of emotions
disp(['Emotion ',emoPick(1), ' and ',emoPick(2),' are picked for this run.']);


for i = 1:length(emoPick)
    feature_emo{i} = featuresALL(emotions==emoPick(i));
    featureData{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
end



% %%%%%%%%%% Code to re-use when classifying by gender (not emotion) %%%%%%%
% gender = [featuresALL.gender]'; % gender info for all recordings
% genderPick = unique(gender);
% 
% for i = 1:length(genderPick)
%     feature_gender{i} = featuresALL(gender==genderPick(i));
%     featureData{i} = zeros(numfeatures*numstats, length(feature_gender{i}));
% end



%%%%%%%%%% shared code for gender and emotion %%%%%%%%%%
%%% Set up the data matrix 
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

%%% VARIABLE setting in KNN classifier: k = 2, iteration = 35 (hard coded in fitness fct)

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

history = gaoutputfcn;

%%
% process GA results
EL_Ac = load('GAhist_pop50gen300elit1initrate010_EL_Ac_964s.mat');
EL_Ac = EL_Ac.history;
EL_Fc = load('GAhist_pop50gen300elit1initrate010_EL_Fc_398s.mat');
EL_Fc = EL_Fc.history;

EF_Ac = load('GAhist_pop50gen300elit1initrate010_EF_Ac_549s.mat');
EF_Ac = EF_Ac.history;
EF_Fc = load('GAhist_pop50gen300elit1initrate010_EF_Fc_1053s.mat');
EF_Fc = EF_Fc.history;

LE_Ac = load('GAhist_pop50gen300elit1initrate010_LE_Ac_562s.mat');
LE_Ac = LE_Ac.history;
LE_Fc = load('GAhist_pop50gen300elit1initrate010_LE_Fc_1006s.mat');
LE_Fc = LE_Fc.history;

figure('units','normalized','position',[.1 .1 .6 .9])

subplot(3,1,1)
hold on;
plot(1-EL_Ac.BestScore,'*-')
plot(1-EL_Fc.BestScore,'o-')
legend('fitness use accuracy','fitness from book','Location','southeast')
xlabel('generation, Emotion E and L')
ylabel('BestScore')

   
subplot(3,1,3)
hold on;
plot(1-EF_Ac.BestScore,'*-')
plot(1-EF_Fc.BestScore,'o-')
legend('fitness use accuracy','fitness from book','Location','southeast')
xlabel('generation, Emotion E and F')
ylabel('BestScore')


subplot(3,1,2)
hold on;
plot(1-LE_Ac.BestScore,'*-')
plot(1-LE_Fc.BestScore,'o-')
legend('fitness use accuracy','fitness from book','Location','southeast')
xlabel('generation, Emotion L and E')
ylabel('BestScore')


supertitle({['KNN classifier k=2 iteration=35,']
       [' with initial pop=' num2str(P) ', max generations=' num2str(maxGens)...
       ' elitism=' num2str(eliteCt) ', initializaiton rate=' num2str(R)]})

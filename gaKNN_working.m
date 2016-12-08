% gaKNN.m
% This driver executes the GA to produce a 

load('featuresGerman.mat'); % load data

global featureData % declare global so the fitness fct can see it

% %%%%%%%%%% Code to re-use when classifying by emotion (not gender) %%%%%%%
% emos = unique([featuresALL.emotion])'; % All emotions
% speakers = unique([featuresALL.speaker])'; % All speakers
% % Pick out 2 emotions
% emo1 = 'E'; %anger
% emo2 = 'L'; %happiness
% % select out just those 2 emotions
% emotions = [featuresALL.emotion]';
% data_emo1 = featuresALL(emotions == emo1);
% data_emo2 = featuresALL(emotions == emo2);
% 
% data_1 = data_emo1;
% data_2 = data_emo2;

% %%%%%%%%%% Code to re-use when classifying by gender (not emotion) %%%%%%%
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

% % feat = getExtraneousFeatures(featuresALL);
% % 
% % notExt = ~ismember(1:175,feat);
% % 
% % featureData = {featureData_emo1(:,notExt)',featureData_emo2(:,notExt)'};

featureData = {featureData_emo1',featureData_emo2'};

%% GA stuff

% GA INPUT VARIABLES
P = 50; % population size
N = 175; % genome size
R = .1; % initialization rate
crossoverFrac = 0.8;
eliteCt = 1;
fitnessLim = 0;
maxGens = 300;
mutationRate = 0.01;

pop = createPop(P, N, R); % Create initial population

audioOptions = gaoptimset('CreationFcn', @createPop, ...
                            'CrossoverFcn', @crossoverIntU, ... 
                            'CrossoverFraction', crossoverFrac, ...
                            'EliteCount', eliteCt, ...
                            'FitnessLimit', fitnessLim, ...
                            'Generations', maxGens, ...
                            'MutationFcn', {@mutateBitFlip,mutationRate}, ...
                            'PopulationSize', P, ...
                            'PopulationType', 'custom', ...
                            'SelectionFcn', @selectiontournament, ...
                            'Vectorized', 'on',...
                            'OutputFcns', @gaoutputfcn);
                        
audioOptions.InitialPopulation = pop;
        
% Run the GA
tic();
[x, fval, exitflag] = ga(@fitnessFctKNN, N, audioOptions);
toc()

history = gaoutputfcn;
plot(1-history.BestScore,'*-')
xlabel('generation')
ylabel('Accuracy')
title({['KNN classifier w/ initial pop. ' num2str(P) ', ' ...
    num2str(maxGens) ' generations'] ['elitism=' num2str(eliteCt) ...
    ', initializaiton rate ' num2str(R)]})

%%
nngens = size(history.popALL,3);
temp = zeros(nngens,185);
for i = 1:nngens
    popi = history.popALL(:,:,i);
    temp(i,:) = sum(popi) ./ size(popi,1);
end

figure
heatmap(temp',[],1:nngens',[],'Colormap','hot','Colorbar',true,'UseLogColormap','true');
%colormap(flipud(colormap))
xlabel('feature')
ylabel('generation')
title('Frequency of feature appearance in each generation of the GA')

temp2 = history.BestIndividual;
figure
imagesc(temp2)
xlabel('feature')
ylabel('generation')
title('Best individuals during each generation by feature')

gaPlots

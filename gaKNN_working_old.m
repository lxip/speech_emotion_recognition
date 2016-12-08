% scrappaper

load('featuresGerman_addFeature.mat')

global featureData % declare global so the fitness fct can see it


gender = [featuresALL.gender]'; % gender info for all recordings
genderPick = unique(gender);
numfeatures = size([featuresALL.features],1); 
numstats = 5; % mean,median,std,min,max

for i = 1:length(genderPick)
    feature_emo{i} = featuresALL(gender==genderPick(i));
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

%% GA stuff

% GA INPUT VARIABLES
P = 50; % population size
N = numfeatures*numstats; % genome size
R = .5; % initialization rate
crossoverFrac = 0.5;
eliteCt = 1;
fitnessLim = 0;
maxGens = 10;
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
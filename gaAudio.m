load('featuresGerman.mat')

% Declare global variables to be visible to fitness function
global data
global emotions_raw

% Pick out 2 emotions
emo1 = 'W'; %anger
emo2 = 'F'; %happiness

% select out just those 2 emotions
emotions = [featuresALL.emotion]';
data_raw = featuresALL(emotions == emo1 | emotions == emo2);
emotions_raw = [data_raw.emotion]';

% Set up the data matrix
numfeatures = 35;
numstats = 5;
data = zeros(length(data_raw), numfeatures*numstats);

for i = 1:length(data_raw)
    data(i,(1:35)*numstats-(numstats-1)) = mean(data_raw(i).features, 2);
    data(i,(1:35)*numstats-(numstats-2)) = median(data_raw(i).features, 2);
    data(i,(1:35)*numstats-(numstats-3)) = std((data_raw(i).features),0,2);
    data(i,(1:35)*numstats-(numstats-4)) = min(data_raw(i).features,[],2);
    data(i,(1:35)*numstats-(numstats-5)) = max(data_raw(i).features,[],2);
    
end

% Features info
numfeatures = 35;
numstats = 5;

% GA INPUT VARIABLES
P = 300; % population size
N = numfeatures*numstats; % genome size
R = 3/(numfeatures*numstats); % initialization rate
crossoverFrac = 0.5;
eliteCt = 0;
fitnessLim = 0;
maxGens = 10;
mutationRate = 0.005;

pop = createPop(P, N, R); % Create initial population

audioOptions = gaoptimset('CreationFcn', @createPop, ...
                            'CrossoverFcn', @crossover, ... 
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
[x, fval, exitflag] = ga(@fitnessFct, N, audioOptions);
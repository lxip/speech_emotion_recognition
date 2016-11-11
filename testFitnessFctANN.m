% Testing different fitness functions

global data
global emotions_raw

clearvars -except k errors

load('featuresGerman.mat')

% Pick out 2 emotions
emo1 = 'A'; %anger
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

error = zeros(10,numfeatures*numstats); % preallocating for error variable
genes = eye(numfeatures*numstats);

% Average over 10 repetitions
for i = 1:2
    % Split data into training (80%) and testing (20%) sets.

    mask = rand(length(data_raw),1) < 0.8;

    traindata = data(mask,:);
    testdata = data(~mask,:);

    trainclasses = emotions_raw(mask);
    testclasses = emotions_raw(~mask);

    % Run the ANN using a single statistical descriptor of a single feature (X10)

    error(i,:) = fitnessCounterPropANN(genes,traindata,trainclasses,testdata,testclasses)';
end

% % for j = 1:10
% %     for i = 1:length(emotions_raw)
% %         genes = zeros(1,length(emotions_raw));
% %         genes(i) = 1;
% %         error(j,i)=fitnessCounterPropANN(genes,traindata,trainclasses,testdata,testclasses);
% %     end
% % end

% Plot the results

plot(mean(error),'-*')
xlabel('feature/statistic #')
ylabel('error')
historyA =    load('historyFT.mat');
historyA = historyA.history;
% historyB = load('historyFTperm.mat');
% historyB = historyB.history;

% result = 1-historyA.AvgScore(end)


figure

startpt = 1;

lA = length(historyA.AvgScore);
% lB = length(historyB.AvgScore);
hold on;
plot(startpt:lA,1-historyA.AvgScore(startpt:end),'*-')
% plot(startpt:lB,1-historyB.AvgScore(startpt:end),'*-')
% set(gca,'xlim',[10^0,10^2.2])
% set(gca,'xscale','log')
% legend('GA-KNN','GA-KNN permutation')
xlabel('generation')
ylabel('average accuracy')
% title('emotion F and T')
%%

figure
hold on

for i = startpt:size(historyA.AllScores,2)
    %plot(i*ones(5,size(history.AllScores,1)),1-history.AllScores(:,i),'*b')
    plot(i*ones(1,size(historyA.AllScores,1)),1-historyA.AllScores(:,i),'*b')
end

% plot(1-history.BestScore,'-d')
% plot(1-history.WorstScore,'-p')

plot(startpt:lA,1-historyA.BestScore(startpt:end),'r')
plot(startpt:lA,1-historyA.WorstScore(startpt:end),'r')

xlabel('generation')
ylabel('Accuracy')
title({['KNN classifier w/ initial pop. ' num2str(P) ', ' ...
num2str(maxGens) ' generations'] ['elitism=' num2str(eliteCt) ...
', initializaiton rate ' num2str(R)]})

%%
figure
heatmap(reshape(mean(historyA.BestIndividual),5,37), 1:37, ...
    {'mean','median','std','min','max'}, 1, ...
'Colormap', 'money', 'Colorbar', true, 'GridLines', ':')

xlabel('feature')
ylabel('statistic')

%%

plot(sum(historyA.BestIndividual,2),'*-')
xlabel('generation')
ylabel('# of features')
title('Number of features in the best individual in the population')
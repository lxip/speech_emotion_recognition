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
ylabel('feature')
xlabel('generation')
% title('Frequency of feature appearance in each generation of the GA')

temp2 = history.BestIndividual;
figure
imagesc(temp2')
ylabel('feature')
xlabel('generation')
% title('Best individuals during each generation by feature')



figure

startpt = 1;

l = length(history.AvgScore);

plot(startpt:l,1-history.AvgScore(startpt:end),'o-')

%%

figure
hold on

for i = startpt:size(history.AllScores,2)
    %plot(i*ones(5,size(history.AllScores,1)),1-history.AllScores(:,i),'*b')
    plot(i*ones(1,size(history.AllScores,1)),1-history.AllScores(:,i),'.c')
end

% plot(1-history.BestScore,'-d')
% plot(1-history.WorstScore,'-p')

plot(startpt:l,1-history.BestScore(startpt:end),'b')
plot(startpt:l,1-history.WorstScore(startpt:end),'b')

xlabel('generation')
ylabel('Accuracy')
% title({['KNN classifier w/ initial pop. ' num2str(P) ', ' ...
% num2str(maxGens) ' generations'] ['elitism=' num2str(eliteCt) ...
% ', initializaiton rate ' num2str(R)]})


figure
heatmap(reshape(mean(history.BestIndividual),5,37), 1:37, ...
    {'mean','median','std','min','max'}, 1, ...
    'Colormap','hot','Colorbar',true,'UseLogColormap','true', 'GridLines',':');
colormap(flipud(colormap))
% 'Colormap', 'money', 'Colorbar', true, 'GridLines', ':')


xlabel('feature')
ylabel('statistic')


figure
plot(sum(history.BestIndividual,2),'*-')
xlabel('generation')
ylabel('# of features')
% title('Number of features in the best individual in the population')
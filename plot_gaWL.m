%%%%%%%%%%%% plotting file for the result of GA
%%%%%%%%%%%% work for chosen GA history file

emotionPair = 'WL';
load(['./history/history',emotionPair,'rerun.mat'])

%%%%% prepare data for feature change heatmap 
% ngens = size(history.popALL,3);
ngens = size(history.AllScores,2);
featureOn = zeros(ngens,185);
for i = 1:ngens
    popi = history.popALL(:,:,i);
    featureOn(i,:) = sum(popi) ./ size(popi,1);
end
%%
%%%%% FIGURE 1 %%%%%
fig1 = figure('units','normalized','position',[.1 .1 .4 .8]);

subplot(3,1,3) %%%%%>plot for # of feature in each generation
plot(sum(history.BestIndividual,2),'x-')
xlabel('generation')
ylabel('N_{feature}')
%%% axis setting
set(gca,'fontsize',14)
set(gca,'Xlim',[1,ngens]);
set(gca,'XTick',1:1:ngens);
set(gca,'XTickLabel',[]);
ymax = get(gca,'Ylim');
set(gca,'YTick',0:5:ymax(2)-5);
set(gca,'YTickLabel',0:5:ymax(2)-5);
set(gca, 'XTickLabelRotation', 90)
set(gca,'XGrid', 'on');
%%% margins setting
pos = get(gca, 'Position');
pos(1) = 0.12; pos(2) = 0.036;
pos(3) = 0.85; pos(4) = 0.22;
set(gca, 'Position', pos)
set(gca,'TickLabelInterpreter', 'tex');

subplot(3,1,2) %%%%%>plot for acurracy in each generation
plot(1:ngens,1-history.BestScore(1:end),'k+-')
ylabel('Acc_{highest}')

%%% axis setting
set(gca,'fontsize',14)
set(gca,'Xlim',[1,ngens]);
set(gca,'XTick',1:1:ngens);
set(gca,'XTickLabel',[]);
set(gca,'XGrid', 'on');
ylim = get(gca,'Ylim');
set(gca,'YTick',ylim(1)+.001:.002:ylim(2));
set(gca,'YTickLabel',ylim(1)+.001:.002:ylim(2));
set(gca,'TickLabelInterpreter', 'tex');

%%% margins setting
pos = get(gca, 'Position');
pos(1) = 0.12; pos(2) = 0.26;
pos(3) = 0.85; pos(4) = 0.22;
set(gca, 'Position', pos)

subplot(3,1,1) %%%%%>heatmap for feature change
heatmap(featureOn',[],1:ngens,[],'Colormap','hot','UseLogColormap','true');
ylabel('statistical features')
%%% axis setting
% colormap(flipud(colormap))
set(gca,'fontsize',14)
set(gca,'Xlim',[1,ngens]);
set(gca,'XTick',1:1:ngens);
set(gca,'XTickLabel',1:1:ngens);
set(gca,'YTick',5:20:185);
set(gca,'YTickLabel',5:20:185);
% set(gca, 'XTickLabelRotation', 90)
%%% margins setting
pos = get(gca, 'Position');
pos(1) = 0.12; pos(2) = 0.52;
pos(3) = 0.85; pos(4) = 0.42;
set(gca, 'Position', pos)
pos=get(gca,'pos');
hc=colorbar('location','northoutside','position',[pos(1) pos(2)+pos(4)+.006 pos(3) 0.03]);
set(hc,'xaxisloc','top');

savefig_pdf(fig1,'./figs/GAgeneration_WL')

%%
%%%%% FIGURE 2 %%%%%
fig2 = figure('units','normalized','position',[.1 .1 .4 .5]);
heatmap(reshape(mean(history.BestIndividual),5,37), 1:37, ...
    {'mean','median','std','min','max'}, 1, ...
    'Colormap','hot','UseLogColormap','true')

%%% axis setting
hAx1  = gca;   % get a handle to first axis
ylim = get(gca,'YLim');
xlim = get(gca,'Xlim');
hAx2  = axes('Position',get(hAx1,'Position'), ...% create a second transparent axis
    'Color','none', 'Box','on', ...
    'XTick',1:1:37, 'XTickLabel',1:1:37,  ...
    'XTickLabelRotation', 90,'fontsize',14,...
    'YTick',get(hAx1,'YTick'), 'YTickLabel',get(hAx1,'YTickLabel'),...
    'XLim',get(hAx1,'XLim'), 'YLim',get(hAx1,'YLim'));
set(hAx1, 'XColor','w', 'YColor','w', ...
    'XGrid','on', 'YGrid','on', ...
    'XTick',xlim(1):1:xlim(2), 'XTickLabel',[],  ...
    'XTickLabelRotation', 90,'fontsize',14,...
    'YTick',ylim(1):1:ylim(2), 'YTickLabel',[],...
    'LineWidth',3);
linkaxes([hAx1 hAx2],'xy');


%%% margins setting
xlabel('audio features')
ylabel('statistics')
pos=get(gca,'pos');
hc=colorbar('location','northoutside','position',[pos(1) pos(2)+pos(4)+.006 pos(3) 0.03]);
set(hc,'xaxisloc','top');

savefig_pdf(fig2,'./figs/GAfeaturefreq_WL')


%%
%%%%% FIGURE 3 %%%%%

fig3 = figure('units','normalized','position',[.1 .1 .4 .5]);
color = get(groot,'DefaultAxesColorOrder');
hold on

for i = 1:size(history.AllScores,2)
    plot(i*ones(1,size(history.AllScores,1)),1-history.AllScores(:,i),'.c')
end

f1=plot(1:ngens,1-history.BestScore(1:end), 'k','LineWidth',1);
f2=plot(1:ngens,1-history.AvgScore(1:end), '--','Color',color(2,:),'LineWidth',1);
f3=plot(1:ngens,1-history.WorstScore(1:end),'Color',color(1,:),'LineWidth',1);

xlabel('generation')
ylabel('Acc')

legend([f1,f2,f3],{'highest accuracy','average accuracy','lowest accuracy'},...
    'Location','southeast')
%%% axis setting
set(gca,'fontsize',17)
set(gca,'Xlim',[0,ngens+1])
set(gca,'XTick',0:2:ngens)
set(gca,'XTickLabel',0:2:ngens)
%%% margins setting
pos = get(gca, 'Position');
pos(1) = 0.12; pos(2) = 0.12;
pos(3) = 0.85; pos(4) = 0.8;
set(gca, 'Position', pos)

savefig_pdf(fig3,'./figs/GAfscorechange_WL')
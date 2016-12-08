%%%%%%%%%%%% plotting file for the accuracy-feature in descending order
%%%%%%%%%%%% work for chosen word pair


clear all;
load('featuresGerman37.mat') % data with 37 audio features
load('Features_names185.mat') %  names for all 185 feature fields

classPick = 'WL';% <---specify the pair of emotion
load(['./history/history',classPick,'rerun.mat']);


%%
%%%%%% GA result %%%%%%
Acc_ga = 1-history.BestScore(end);
gaIndiv = history.BestIndividual(end,:);

%%%%%% run KNN on every single feature k=2, iter=35, use Ac2 %%%%%%
emotions = [featuresALL.emotion]';
numfeatures = size([featuresALL.features],1); 
numstats = 5; 

for i = 1:length(classPick)
    featurePicked{i} = featuresALL(emotions==classPick(i));
    featureData{i}   = zeros(numfeatures*numstats, length(featurePicked{i}));
end

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

% KNN result for each feature
Acc_KNNsingle = zeros(1, numfeatures*numstats);
for j = 1:numfeatures*numstats
    for i = 1:length(featureData)
        featureSelect{i} = zeros(numfeatures*numstats, length(featurePicked{i}));
        featureSelect{i}(j,:) = featureData{i}(j,:);
    end
    [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
            evaluateClassifier(featureSelect, 2, 1, [0.8,35]);
    Acc_KNNsingle(1,j) = Ac2;
end

%%%%%% KNN result for all 185 feature %%%%%%
[CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
            evaluateClassifier(featureData, 2, 1, [0.8,35]);
Acc_KNNall = Ac2;

%%%%%% sorting and index matching %%%%%%
[Acc_sorted,Acc_sorted_idx] = sort(Acc_KNNsingle, 'descend');
gaIndiv_idx = find(gaIndiv==1);
gaIndiv_sorted_idx = find(ismember(Acc_sorted_idx,gaIndiv_idx));
    
save descendingFeature4plot_WL % <---specify filename

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Plotting %%%%%%

load('descendingFeature4plot_WL')

fg = figure('units','normalized','position',[.1 .1 .6 .4]);
color = get(groot,'DefaultAxesColorOrder');
hold on 

% f1=plot(linspace(1,185,185),repmat(Acc_ga,    1,185),'r-' ,'LineWidth',1.5);
% f3=plot(linspace(1,185,185),repmat(Acc_KNNall,1,185),'b-.','LineWidth',1);
f3=scatter(-7,Acc_KNNall,100,'b*');
f1=scatter(-15,Acc_ga,   200,'ro','filled');


f2=bar(gaIndiv_sorted_idx,Acc_sorted(gaIndiv_sorted_idx),...
    'BarWidth',0.4,'FaceColor',color(2,:),'EdgeColor',color(2,:),...
    'FaceAlpha',0.6,'EdgeAlpha',0.1);
f4=plot(Acc_sorted,'-*','Color',color(1,:),'MarkerSize',6);
% f4=plot(gaIndiv_sorted_idx,Acc_sorted(gaIndiv_sorted_idx),'o',...
%     'MarkerSize',15,'MarkerEdgeColor','r');

%%% legend and label
xlabel('ranked statistical feature');
ylabel('Acc');
legend([f1,f2,f3,f4],{'GA accuracy','GA chosen features',...
    'KNN all features accuracy','KNN single feature accuracy'})

%%% set axis
set(gca,'fontsize',18)
set(gca,'Ylim',[0.35,1.02]);
% set(gca,'Xlim',[0,numfeatures*numstats+3]);
% set(gca,'XTick',[])

set(gca,'Xlim',[-18,numfeatures*numstats+3]);
set(gca,'XTicklabel',{1,185})
set(gca,'XTick',[-15,-7,1,185])
set(gca,'XTicklabel',{'GA','KNN','',''})
set(gca, 'XTickLabelRotation', 50)

    
%%% set margins for the plot
pos = get(gca, 'Position');
pos(1) = 0.08; pos(2) = 0.14;
pos(3) = 0.88; pos(4) = 0.85;
set(gca, 'Position', pos)


%%% text annotation
% annotation('textarrow',[gaIndiv_sorted_idx(1) gaIndiv_sorted_idx(1)],...
%     [Acc_sorted(gaIndiv_sorted_idx(1)) ],...
%     'String','y = x');

    
savefig_pdf(fg,'./figs/descending_WL')
% A drive for running KNN classifier in the library.
% And plot for showing the result for different KNN iteration.
% Creator: Xipei Liu
% Last Edited: 2016-12-02


clc;
clear all;
load('featuresGerman37.mat')

% %%% prepare gender data
% gender = [featuresALL.gender]'; % gender info for all recordings
% genderPick = unique(gender);
% numfeatures = size([featuresALL.features],1); 
% numstats = 5; % mean,median,std,min,max
% 
% for i = 1:length(genderPick)
%     feature_emo{i} = featuresALL(gender==genderPick(i));
%     featureData{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
% end

%% prepare emotion data
emotions = [featuresALL.emotion]';
numfeatures = size([featuresALL.features],1); 
numstats = 5; % mean,median,std,min,max

emoPick = 'WF';% <---specify the pair of emotion
disp(['Emotion ',emoPick(1), ' and ',emoPick(2),' are picked for this run.']);


for i = 1:length(emoPick)
    feature_emo{i} = featuresALL(emotions==emoPick(i));
    featureData{i} = zeros(numfeatures*numstats, length(feature_emo{i}));
end


%%%% shared code for gender and emotion
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


%% Experiment 
% the performance for different reps: speed up KNN

iter = linspace(0,100,21);
iter(1) = 1;
rep = 100;

Ac_results = zeros(rep,length(iter));
Ft_results = zeros(rep,length(iter));
Elp_results = zeros(rep,length(iter));

for i = 1:rep
    for j = 1:length(iter)
        tic;
        [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
            evaluateClassifier(featureData, 10, 1, [0.8,iter(j)]);
        Ac_results(i,j) = Ac2;
        Elp_results(i,j) = toc;
%         Ft_results(i,j) = (Re1+Re2).*(Pr1+Pr2)/(Pr1+Pr2+Re1+Re2);
    end
end


mean_Ac_results = mean(Ac_results);
std_Ac_results = std(Ac_results);
mean_Elp_results = mean(Elp_results);
std_Elp_results = std(Elp_results);

save iteration_history_WF % <---specify the file name

%% Plotting
%%%% directly compute from saved data
iter=100;
iter_WF = load('iteration_history_WF');
iter_WL = load('iteration_history_WL');

fig = figure('units','normalized','position',[.1 .1 .4 .5]);% initialize figure and set size
color = get(groot,'DefaultAxesColorOrder');% get matlab default multiple colors, 7x3 matrix

subplot(2,1,2)
hold on
plot(iter_WF.iter,iter_WF.std_Ac_results,'*-')
plot(iter_WL.iter,iter_WL.std_Ac_results,'^-')
% plot(iter_WL.iter,iter_WL.std_Ac_results,'^-','MarkerEdgeColor',color(7,:),'Color',color(7,:))
legend('WF','WL')
xlabel('KNN iteration parameter')
ylabel('Std_{Acc}')

%%% some ax setting
set(gca,'fontsize',14)
set(gca,'XTick',0:5:iter)
set(gca, 'XTickLabel', [])
xlim([0,iter+1])
set(gca,'TickLabelInterpreter', 'tex');
%%% set margins for the plot
pos = get(gca, 'Position');
pos(1) = 0.12; pos(2) = 0.08;
pos(3) = 0.85; pos(4) = 0.3;
set(gca, 'Position', pos)


subplot(2,1,1)
hold on;
errorbar(iter_WF.iter, iter_WF.mean_Ac_results,iter_WF.std_Ac_results,'*-')
errorbar(iter_WL.iter, iter_WL.mean_Ac_results,iter_WL.std_Ac_results,'^-')
% errorbar(iter_WL.iter, iter_WL.mean_Ac_results,iter_WL.std_Ac_results,'^-','MarkerEdgeColor',color(2,:),'Color',color(2,:))
legend('WF','WL')
ylabel('classifier Acc')
% title('KNN: different accuracy for choosen iterations, use emotion W and N.')

%%% some ax setting
set(gca,'fontsize',14)
set(gca,'Xlim',[0,iter+1])
set(gca,'XTick',0:5:iter)
%%% set margins for the plot
pos = get(gca, 'Position');
pos(1) = 0.12; pos(2) = 0.45;
pos(3) = 0.85; pos(4) = 0.5;
set(gca, 'Position', pos)


%%% save fig
% savefig_pdf(fig,'./figs/iterationTest') 



%%%%%%%%%%%%%%%%%%%%%%%%%% add time ---> perfectly linear, no need to show
% fig = figure('units','normalized','position',[.1 .1 .4 .8]);% initialize figure and set size
% color = get(groot,'DefaultAxesColorOrder');% get matlab default multiple colors, 7x3 matrix

% subplot(3,1,3)
% hold on
% plot(iter_WF.iter,iter_WF.std_Ac_results,'*-')
% plot(iter_WL.iter,iter_WL.std_Ac_results,'^-')
% % plot(iter_WL.iter,iter_WL.std_Ac_results,'^-','MarkerEdgeColor',color(7,:),'Color',color(7,:))
% legend('WF','WL')
% xlabel('KNN iteration parameter')
% ylabel('Std_{Acc}')
% 
% %%% some ax setting
% set(gca,'fontsize',14)
% set(gca,'XTick',0:5:iter)
% set(gca, 'XTickLabel', [])
% xlim([0,iter+1])
% set(gca,'TickLabelInterpreter', 'tex');
% %%% set margins for the plot
% pos = get(gca, 'Position');
% pos(1) = 0.12; pos(2) = 0.08;
% pos(3) = 0.85; pos(4) = 0.2;
% set(gca, 'Position', pos)
% 
% 
% subplot(3,1,2)
% hold on;
% errorbar(iter_WF.iter, iter_WF.mean_Ac_results,iter_WF.std_Ac_results,'*-')
% errorbar(iter_WL.iter, iter_WL.mean_Ac_results,iter_WL.std_Ac_results,'^-')
% % errorbar(iter_WL.iter, iter_WL.mean_Ac_results,iter_WL.std_Ac_results,'^-','MarkerEdgeColor',color(2,:),'Color',color(2,:))
% legend('WF','WL')
% ylabel('classifier Acc')
% % title('KNN: different accuracy for choosen iterations, use emotion W and N.')
% 
% %%% some ax setting
% set(gca,'fontsize',14)
% set(gca,'Xlim',[0,iter+1])
% set(gca,'XTick',0:5:iter)
% %%% set margins for the plot
% pos = get(gca, 'Position');
% pos(1) = 0.12; pos(2) = 0.32;
% pos(3) = 0.85; pos(4) = 0.38;
% set(gca, 'Position', pos)
% 
% 
% subplot(3,1,1)
% hold on;
% errorbar(iter_WF.iter, iter_WF.mean_Elp_results,iter_WF.std_Elp_results,'*-')
% errorbar(iter_WL.iter, iter_WL.mean_Elp_results,iter_WL.std_Elp_results,'^-')
% % errorbar(iter_WL.iter, iter_WL.mean_Ac_results,iter_WL.std_Ac_results,'^-','MarkerEdgeColor',color(2,:),'Color',color(2,:))
% legend('WF','WL','location','southeast')
% ylabel('run time (s)')
% % title('KNN: different accuracy for choosen iterations, use emotion W and N.')
% 
% %%% some ax setting
% set(gca,'fontsize',14)
% set(gca,'Xlim',[0,iter+1])
% set(gca,'XTick',0:5:iter)
% %%% set margins for the plot
% pos = get(gca, 'Position');
% pos(1) = 0.12; pos(2) = 0.75;
% pos(3) = 0.85; pos(4) = 0.2;
% set(gca, 'Position', pos)
clear all;

allFiles = dir( './history' );
allNames = {allFiles(~[allFiles.isdir]).name};

for i=1:length(allNames)
    emoPairs{i} = allNames{i}(1,8:9);
end

for i=1:length(emoPairs)
    load(['./history/history',emoPairs{i},'rerun.mat']);
    score = 1-history.BestScore(end);
    disp(['Pair  ',history.emotions,'  BestAc  ',num2str(score)])
    clearvars history;
    gaPlots
end 

%%%%%%%%%%%%%%%%%%OUTPUT%%%%%%%%%%%%%%%%%%%
% % Pair  AF  BestAc  0.96737
% % Pair  AT  BestAc  0.98947
% % Pair  EA  BestAc  0.92044
% % Pair  EF  BestAc  0.95644
% % Pair  ET  BestAc  1
% % Pair  FT  BestAc  1
% % Pair  LA  BestAc  0.99161
% % Pair  LE  BestAc  0.99182
% % Pair  LF  BestAc  0.99301
% % Pair  LT  BestAc  0.96701
% % Pair  NA  BestAc  0.97819
% % Pair  NE  BestAc  0.99295
% % Pair  NF  BestAc  0.99075
% % Pair  NL  BestAc  0.86539
% % Pair  NT  BestAc  0.97195
% % Pair  NW  BestAc  1
% % Pair  WA  BestAc  0.94258
% % Pair  WE  BestAc  0.99615
% % Pair  WF  BestAc  0.84538
% % Pair  WL  BestAc  1
% % Pair  WT  BestAc  1
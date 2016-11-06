function [TestClassEst]=CounterProp(train,trainclasses,test,ncases)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Original Counterpropagation ANN as described by Hecht-Nielsen
% [TestClassEst]=CounterProp(train,test,ncases)
%
% INPUTS: 
%   train = matrix of training data
%       rows correspond to individuals
%       cols correspond to variables (each normalized to 0..1)
%
%   trainclasses = col vector of known binary classes for training data in train
%       rows correspond to individuals
%
%   test = matrix of data to test on
%       rows correspond to individuals
%       cols correspond to variables (each normalized to 0..1)
%
%   ncases: OPTIONAL input arg, saying how many cases (vs controls) are in
%   the training set.  IF THIS ARGUMENT IS PROVIDED, IT IS ASSUMED THAT ALL
%   CASES COME BEFORE ALL CONTROLS IN THE TRAINING SET!
%
% AUTHOR:Donna Rizzo
% MODIFIED BY: Maggie Eppstein

%%% USER SPECIFIED TRAINING COEFFICIENTS AND CONSTANTS %%%
alpha=0.7;     %% Kohonen weight layer learning constant
beta=0.1;     %% Grosberg weight layer learning constant
FACTOR = 1.5;  %% Multiplier to determine the number of hidden nodes

%%%%%%%%%%%% PREPOCESSING OF DATA AND WEIGHTS %%%%%%%%%%%%
%%   Further Normalize Data
[train,test]=safe_norm(train,test);    

[trn_pat trn_col]=size(train);    %train becomes training patterns
[test_pat test_col]=size(test); %test becomes interpolation patterns

%%  Define size of weight matrices
nclass=max(trainclasses)+1;      %number of classifications

%%  Create target classifications of zeros and ones
target=zeros(trn_pat,nclass);
if nargin == 4 %ASSUMES ALL CASES COME BEFORE ALL CONTROLS
    target(1:ncases,2)=1;
    target(ncases+1:end,1)=1;
else
    target(find(trainclasses==1),2)=1;
    target(find(trainclasses==0),1)=1;
end

%%   Create random weights for ANN
nh=round(FACTOR*trn_pat);     %% Number of hidden nodes
wij=rand(trn_col,nh);   %% Kohonen weights as non-linear mapping
[nrows nh]=size(wij);
wjk=rand(nh,nclass);    %% Grosberg weights

%%%%%%%%%%%% TRAINING PHASE of ANN %%%%%%%%%%%%
itt=1;
% iterate until "converged" (in this case, just do 30 its for efficiency)
maxit=30;
while itt <= maxit 
  
    % adjust weights in ANN
    for k=1:trn_pat
        vect=train(k,:);
        Sj = vect*wij;
        [maxval winner]=max(Sj,[],2); %% All or nothing activation function

        Sj(:)=0;   %%identify losers with zeros
        Sj(winner)=1;        %% identify the winner with a one
        wij(:,winner)=wij(:,winner)+alpha*(vect'-wij(:,winner)); %%adjust winning nodes

        Sk=Sj*wjk;              %% create output vector
        wjk(winner,:)=wjk(winner,:)+beta*(target(k,:)-Sk); %% adjust Grossberg weights
       
    end
    
    itt=itt+1;
end

%%%%%%%%%%%% Now use trained ANN to estimate Classes of Test Cases %%%%%%%%%%%%
TestClassEst=zeros(test_pat,1);
for k=1:test_pat
  
    distj = test(k,:)*wij; %which class is this test pattern closest to?

    [maxval winner]=max(distj,[],2);    %% All or Nothing activation function
    distj(:)=0;     % Identify losers with zeros
    distj(winner)=1; % Identify the winner with a one
 
    [maxval TestClassEst(k,1)]=max(distj*wjk);%% Final classification
end
TestClassEst=TestClassEst-1; %make classes start at 0 rather than 1




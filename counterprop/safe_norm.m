function [train,test] = safe_norm(train,test)
%% function normalizes by adding a dimension to matrices

%% Determine maximum length 
L_train=sqrt(sum(train.^2,2));
L_test=sqrt(sum(test.^2,2));
max_L=max([L_train;L_test]);

N=max_L+0.01*max_L ;     %add percent to largest length

% Add new dimension to original matrices
train(:,end+1)=sqrt(N^2-L_train.^2);
test(:,end+1)=sqrt(N^2-L_test.^2);

%% Divide new patterns by N to normalize
train=train/N;
test=test/N;

function [error]=fitnessCounterPropANN(pop,traindata,trainclasses,testdata,testclasses);
% [error]=fitnessCounterPropANN(pop,traindata,trainclasses,testdata,testclasses);
%
% fitness approximator (for minimization problem) 
%
%   INPUTS:
%       pop: rows are individuals, cols are binary chromosomes
%           (note: ncols in pop is same as ncols in table-1)
%       traindata,testdata: matrices of testing and training data
%           rows correspond to individuals
%           cols correspond to variables (already each normalized to 0..1)
%       trainclasses,testclasses: column vectors of known classes
%           for testing and trainins subsets of data
%
% OUTPUT:
%   error: classification error (proportion misclassified) on random test 20% of the data
%   (can be used as fitness to be minimized)
%
% ALGORITHM:
%   This trains a counter-propagation ANN on part of the data, and tests
%   on the remaining data.  Note that, for efficiency for embedding into the GA:
%   a) we only do one testing/training split (as opposed to averaging rmse's over a
%       number of reps) (i.e., this is a noisy fitness function)
%   b) the ANN is hardcoded to only train for 30 iterations, which
%       empirically seems to work pretty well, at least on this set of data
%       (this should be tested prior to applying to other data sets)
%
% AUTHOR: Maggie Eppstein

error=zeros(size(pop,1),1);
ncases=sum(trainclasses);

for p = 1:size(pop,1)

    features=find(pop(p,:)); % find which bits are on
    
    % use the ANN to estimate classes of test set using only the selected features
    [testclassEstimates]=CounterProp(traindata(:,features),trainclasses,testdata(:,features),ncases);   

    % use classification error as a measure of fitness to minimize 
    % (low error is better); note, when more than 2 classes you may want to
    % modify the following simple error metric
    error(p)=sum(abs(testclasses-testclassEstimates))/length(testclassEstimates); 
end






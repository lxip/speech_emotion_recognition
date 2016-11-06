function [traindata,trainclasses,testdata,testclasses]=TrainTestSet(data,classes,trainprop)
% [traindata,trainclasses,testdata,testclasses]=TrainTestSet(data,classes,trainprop)
%
% INPUTS:
%       data: matrix of raw input data (for use with expression trees)
%           rows correspond to individuals
%           cols correspond to variables (reals first, then binarys)
%       classes: column vector of class outcomes for each individual
%       trainprop: OPTIONAL (defaults to .8): proportion of data to use in training
%
% OUTPUT:
%       traindata,testdata: data split into training and testing portions
%       trainclasses,testclasses: class data split accordingly
%
% AUTHOR: Maggie Eppstein

if nargin < 4
    % split into 80% training and 20% testing
    trainprop = 0.8; % proportion of original data used to train ANN
end

% select random cases
cases=find(classes==true);
RNcases = rand(length(cases),1);
trainingrowscases=find(RNcases<=trainprop);
testingrowscases=find(RNcases>trainprop);

% select a random 80% of controls
controls=find(classes==false);
RNcontrols=rand(length(controls),1);
trainingrowscontrols=find(RNcontrols<=trainprop);
testingrowscontrols=find(RNcontrols>trainprop);

% now put them together to determine row indeces of training and testing sets
trainingrows=[cases(trainingrowscases);controls(trainingrowscontrols)];
testingrows=[cases(testingrowscases);controls(testingrowscontrols)];

% extract training and testing data from input
traindata=data(trainingrows,:);
trainclasses=classes(trainingrows);
testdata=data(testingrows,:);
testclasses=classes(testingrows);


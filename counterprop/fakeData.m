function [data,normdata,nBoolvars,nRealvars]=fakeData(npatients)
% create fake data of types similar to those to be collected for mental health patients
% [data,normdata,nBoolvars,nRealvars]=fakeData(npatients)
% 
% INPUTS:
%   npatients: number of fake patients to create
%
% OUTPUTS:
%   data: rows correspond to patients, cols correspond to their raw answers
%       Real variables all come first, followed by boolean variables
%       (use this data for evaluations of GP trees)
%   normdata: same as data but all cols have been normalized to 0..1 range
%       (use this normdata for training ANN)
%   nBoolvars, nRealvars: number of variables (columns) of each type
%
% AUTHOR: Maggie Eppstein

% specify max allowable values for each variable: NOTE: all real variables first,
% followed by all boolean variables
maxval=[5 4 6 2 3 3 3 9 6 5 8 6 8 6 6 1 3 3 7 9 6 5 6 4 6 2 3 4 3 9 6 5 5 5 4 6 1 3 4 3 9 6 5 ... %life skills
    zeros(1,9)+5 ... %quality of life : ranges 1-5
    6 ... %race (0 White; 1 Black or African America;3 Asian; 4 American Indian or Alaska Native; 5 Native Hawaiian or Other Pacific Islander; 6 other;
    2 ... %urban=2, suburban=1, rural=0;
    50000 ... % salary 0 to 50000 (or more)
    50 ... %age: 18-50 (truncated to bounds)
    ones(1,52)... %IV: Unacceptable community behaviors and V: symptoms and VI: Side effects of Medication
    1 ... %hispanic (1=T, 0=F)
    1]; %sex 0=M, 1=F
 
nquestions=length(maxval); %total number of variables

% specify min allowable values for each variable
minval=zeros(size(maxval));
minval(44:52)=1; %Quality of Life
minval(56)=18; %min age

% spread vectors into matrices for easy access
maxvals=maxval(ones(npatients,1),:);
minvals=minval(ones(npatients,1),:);

% determine number of real and boolean variables
range=maxval-minval;
realvars=find(range>1);
lastreal=realvars(end);
nRealvars=lastreal;
nBoolvars=length(maxval)-nRealvars;


%now, randomly create data within the above ranges
data=zeros(npatients,nquestions);
data=floor(rand(size(data)).*(maxvals+-minvals+1)+minvals);

% now, make new AD data to satisfy constraints; actually do (AD) must be <=can do (CD)
ADcols=[1:10 23:32];
CDcols=[13:22 34:43];

ratio=maxvals(:,ADcols)./maxvals(:,CDcols);
maxAD=min(maxvals(:,ADcols),floor(data(:,CDcols).*ratio));
data(:,ADcols)=floor(rand(npatients,length(ADcols)).*(maxAD+1));

normdata=max(min(data,maxvals),minvals); %truncate data to within expected range
normdata=(normdata-minvals)./(maxvals-minvals); %normalize all data to 0 to 1 range



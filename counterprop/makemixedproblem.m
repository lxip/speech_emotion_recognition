function [tree,classes,truevars] = makemixedproblem(nvars,data,nBoolvars,nRealvars,tol)
%  [tree,classes,truevars] = makemixedproblem(nvars,data,nBoolvars,nRealvars)
%
% Make a random "true problem" (as an expression tree) that has nvars variables and 
% at least a 1:3 or 3:1 ratio of cases:controls
%
% INPUTS:
%   nvars: number of variables in random problem
%   data: rows correspond to patients, cols correspond to their raw answers
%       Real variables all come first, followed by boolean variables
%       (use this data for evaluations of GP trees)
%   nBoolvars, nRealvars: number of variables (columns) of each type
%
% OUTPUTS:
%   tree: the expression tree corresponding to the problem
%   classes: binary class results (0=controls, 1=cases) for the "outcome"
%        specified by the expression tree generated
%       (you may want to mutate this output with random noise to test robustness to noise)
%   truevars: the column numbers in the data matrix that correspond to the
%       "true" features that are included in the expression tree.
%
% AUTHOR: Maggie Eppstein

if nargin < 5
    tol=0.1; %ensure that no boolean column matches the class data (or its complement) closer than this much
end

x=data(:,1:nRealvars); % all real variables come first
b=data(:,nRealvars+1:end); %followed by all boolean variables

global FReal FBool TReal TBool
FReal=1;
FBool=2;
TReal=3;
TBool=4;

% DEFINE THE FUNCTIONAL AND TERMINAL SETS ALLOWED FOR THE "REAL" PROBLEMS

%DEFINE OVERALL PROBLEM RETURN TYPE
problemreturntype=FBool;

% DEFINE FUNCTIONS THAT RETURN REALS
FRealSet={'plus'}; 
FRealSetArity=[2]; % arity of each function listed above
%(note that we assume that real valued function also take reals as inputs,
% so no need to specify this)

% DEFINE FUNCTIONS THAT RETURN BOOLEANS

FBoolSet={'and','or','not','lt','gt','eq'};
FBoolSetArity=[2 2 1 2 2 2]; %arity of each function listed above
FBoolSetInputTypes=[FBool FBool FBool FReal FReal FReal]; %input type of each function above
% (note that we assume that ALL inputs to boolean functions are of the same type)

%DEFINE NUMBER AND TYPES OF VARIABLES IN THE TERMINAL SET
NumRealTerminalVariables=nRealvars; %will automatically be named x(:,1), x(:,2)
NumBoolTerminalVariables=nBoolvars; %will automatically be names b(:,1), b(:,2)

% PRESPECIFIED CONSTANTS (INTEGERS OR REALS) ALLOWED AS TERMINALS
ConstantSet=[]; %can put any vector of real or integer numbers here, even using ranges, e.g. [1:10 20 pi]

% THE FOLLOWING THREE VECTORS MUST CONTAIN EITHER ZERO OR TWO VALUES!!!

% IF NORMALLY DISTRIBUTED RANDOM REAL TERMINALS CAN BE GENERATED
MeanStdRealNormalTerminalConstants=[]; % THEN SPECIFY THEIR MEAN AND STD OF DISTRIBUTION

% IF UNIFORMLY DISTRIBUTED RANDOM REAL TERMINALS CAN BE GENERATED
LowerboundUpperboundRealUniformTerminalConstants=[]; % THEN SPECIFY THE LOWER AND UPPER BOUNDS ON DISTRIBUTION

% IF UNIFORMLY DISTRIBUTED RANDOM INTEGER TERMINALS CAN BE GENERATED
LowerboundUpperboundIntegerUniformTerminalConstants=[1 3]; % THEN SPECIFY THE LOWER AND UPPER BOUNDS ON DISTRIBUTION

% THE FOLLOWING FUNCTION JUST PUTS ALL THIS DATA IN THE PROPER FORM 
% INTO THE OPTIONS STRUCTURE
o=[];
o = makenodeset(o,problemreturntype,FRealSet,FRealSetArity,...
        FBoolSet,FBoolSetArity,FBoolSetInputTypes,...
        NumRealTerminalVariables,NumBoolTerminalVariables,...
        ConstantSet,...
        MeanStdRealNormalTerminalConstants,...
        LowerboundUpperboundRealUniformTerminalConstants,...
        LowerboundUpperboundIntegerUniformTerminalConstants);


% NOW, find a random tree that has the desired number of unique variables
maxdepth=logbase(nvars*16,2);
D=1; %current depth is root
numvars=0;
while numvars~=nvars
    [tree,largestdepth,Boolvars,Realvars]=makerandomtree(o,D,maxdepth,FBool,1,[],[]);
    numvars=length(unique(Boolvars))+length(unique(Realvars));
    if numvars==nvars
        % see if there is at least a 3:1 or 1:3 ratio.
        tree.str = tree2strNEW(tree,o);
        classes=logical(eval(tree.str));
        if ~isempty(comparcol(classes,data,tol)) %make sure one column isn't equal to class!
            numvars=0;
        else
            cases=sum(classes);
            controls=length(classes)-cases;
            if min(cases,controls)<length(classes)/3
                numvars=0; % if not, keep looking
            end
        end
    end
end

% return col numbers of all variables used in the expression, for
% validation of your feature selector and also for testing GP alone
truevars=[unique(Realvars) unique(Boolvars)+nRealvars];

    

function [o] = makenodeset(o,returntype,FRnames,FRarity,FBnames,FBarity,FBinputtype,...
    TRnumber,TBnumber,ConstantSet,RnormalMS,RuniformLU,IuniformLU);
% store the function and terminal set info in the options structure as
% follows:
%
%   nodeset{1} holds all info about real functions
%   nodeset{2} holds all info about bool functions
%   nodeset{3} holds all info about real terminals
%   nodeset{4} holds all info about bool terminals
%
% Author: Maggie Eppstein

% The following checks are by no means exhaustive, but at least catch some
% obvious input errors

if length(RnormalMS)==1 | length(RnormalMS)>2 |...
    length(RuniformLU)==1 | length(RuniformLU)>2 |...
    length(IuniformLU)==1 | length(IuniformLU)>2 
    error('Error! When specifying random terminals you must provide exactly two values!');%abort
end
    
if length(FRnames)~= length(FRarity) |...
        length(FBnames)~=length(FBarity) |...
        length(FBnames)~=length(FBinputtype)
    error('Error!  Must provide arity and/or input type for each function!'); %abort
end

if TRnumber+TBnumber+length(ConstantSet)+length(RnormalMS)+length(RuniformLU)+length(IuniformLU)==0
    error('Error!  Must provide some terminals!');
end
    
global FReal FBool TReal TBool

o.problemreturntype=returntype;

o.nodeset{FReal}.names=FRnames;
o.nodeset{FReal}.arity=FRarity;
o.nodeset{FReal}.inputtype=zeros(size(FRarity))+FReal; %assume reals take reals

o.nodeset{FBool}.names=FBnames;
o.nodeset{FBool}.arity=FBarity;
o.nodeset{FBool}.inputtype=FBinputtype; %boolean functions can take reals or booleans

% real terminal variables are stored in matrix x, 
% where column corresponds to a different variable
for tr=1:TRnumber
    o.nodeset{TReal}.names{tr}=['x(:,',num2str(tr),')'];
end
o.nodeset{TReal}.arity=zeros(1,TRnumber);

% boolean terminal variables are stored in matrix b, 
% where column corresponds to a different variable
o.nodeset{TBool}.names=[]; %in case there are none
for tb=1:TBnumber
    o.nodeset{TBool}.names{tb}=['b(:,',num2str(tb),')'];
end
o.nodeset{TBool}.arity=zeros(1,TBnumber);

% see if any specific constants are allowed

if ~isempty(ConstantSet)
    tr=tr+1;
    o.nodeset{TReal}.names{tr}='CONSTANT';
    o.ConstSet=ConstantSet;
    o.nodeset{TReal}.arity(tr)=0;
end

% if normally and/or uniformly distributed real numbers are allowed
% add info to the real terminal set

if ~isempty(RnormalMS)
    tr=tr+1;
    o.nodeset{TReal}.names{tr}='MAKENORMAL';
    o.TRnormalMS=RnormalMS;
    o.nodeset{TReal}.arity(tr)=0;
end

if ~isempty(RuniformLU)
    tr=tr+1;
    o.nodeset{TReal}.names{tr}='MAKEUNIFORMREAL';
    o.TRuniformLU=RuniformLU;
    o.nodeset{TReal}.arity(tr)=0;
end

if ~isempty(IuniformLU)
    tr=tr+1;
    o.nodeset{TReal}.names{tr}='MAKEUNIFORMINTEGER';
    o.TIuniformLU=IuniformLU;
    o.nodeset{TReal}.arity(tr)=0;
end
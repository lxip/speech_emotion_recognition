function [tree largestdepth Boolvars Realvars] = makerandomtree(o,D,Dmax,returntype,largestdepth,Boolvars,Realvars)
% generate a random tree of depth UP TO Dmax
%
% author: Josh Payne
% Modified: Maggie Eppstein
global FReal FBool TReal TBool
if nargin < 5
    largestdepth=1;
end
tree.returntype=returntype;
if D < Dmax %if not at maximum depth yet

    % randomly choose a terminal or function node of correct type
    if isempty(o.nodeset{returntype}.names)
        returntype=returntype+2;
    elseif ~isempty(o.nodeset{returntype+2}.names)
%         returntype=returntype+2*randint(1,1,[0 1]);
        returntype=returntype+2*randi([0 1]);        
    end
    
    if returntype >2 %picked a terminal
%         termnum=randint(1,1,[1 length(o.nodeset{returntype}.names)]);
        termnum=randi([1 length(o.nodeset{returntype}.names)]);        
        tree.value=o.nodeset{returntype}.names{termnum};
           
        % if the terminal was a prespecified or random constant, pick one
        if strcmp(tree.value,'CONSTANT')
%             tree.value=num2str(o.ConstSet(randint(1,1,[1 length(o.ConstSet)])),14); %randomly pick a constant with 14 digits accuracy
            tree.value=num2str(o.ConstSet(randi([1 length(o.ConstSet)])),14); %randomly pick a constant with 14 digits accuracy
        elseif strcmp(tree.value,'MAKENORMAL')
            r=randn*o.TRnormalMS(2)+o.TRnormalMS(1); %make random number with specified mean and std
            tree.value=num2str(r); %defaults to 4 decimal places
        elseif strcmp(tree.value,'MAKEUNIFORMREAL')
            r=rand*(o.TRuniformLU(2)-o.TRuniformLU(1))+o.TRuniformLU(1);
            tree.value=num2str(r);
        elseif strcmp(tree.value,'MAKEUNIFORMINTEGER')
%             r=randint(1,1,[o.TIuniformLU(1) o.TIuniformLU(2)]);
            r=randi([o.TIuniformLU(1) o.TIuniformLU(2)]);
            tree.value=num2str(r);
        elseif returntype==TBool
            Boolvars=[Boolvars termnum];
        elseif returntype == TReal
            Realvars=[Realvars termnum];
        end
        tree.numkids=0;

        %we know this is a leaf
        tree.nodedepth = D;
        tree.maxdepth = 1;
        tree.kids = {}; %empty
        tree.numleaves = 1;
        tree.numinternal = 0;
    else %picked a nonterminal
%         tree.value=randint(1,1,[1 length(o.nodeset{returntype}.arity)]);
        tree.value=randi([1 length(o.nodeset{returntype}.arity)]);        
        tree.numkids=o.nodeset{returntype}.arity(tree.value);

        tree.nodedepth = D;
        tree.maxdepth = 1;
        tree.kids = cell(tree.numkids,1);
        tree.numleaves = 0;
        tree.numinternal = 1;


        for i = 1:tree.numkids
            [tree.kids{i} largestdepth Boolvars Realvars] = makerandomtree(o,D+1,Dmax,o.nodeset{returntype}.inputtype(tree.value),largestdepth,Boolvars,Realvars);
            tree.numleaves = tree.numleaves+tree.kids{i}.numleaves;
            tree.numinternal = tree.numinternal + tree.kids{i}.numinternal;
            if largestdepth > tree.maxdepth
                tree.maxdepth = largestdepth;
            end
        end
    end

else
    
    %pick a terminal
%     termnum=randint(1,1,[1 length(o.nodeset{returntype+2}.names)]);
    termnum=randi([1 length(o.nodeset{returntype+2}.names)]);    
    tree.value=o.nodeset{returntype+2}.names{termnum};
    
    % if the terminal was a prespecified or random constant, pick one
    if strcmp(tree.value,'CONSTANT')
%         tree.value=num2str(o.ConstSet(randint(1,1,[1 length(o.ConstSet)])),14); %randomly pick a constant with 14 digits accuracy
        tree.value=num2str(o.ConstSet(randi([1 length(o.ConstSet)])),14); %randomly pick a constant with 14 digits accuracy        
    elseif strcmp(tree.value,'MAKENORMAL')
        r=randn*o.TRnormalMS(2)+o.TRnormalMS(1); %make random number with specified mean and std
        tree.value=num2str(r); %defaults to 4 decimal places
    elseif strcmp(tree.value,'MAKEUNIFORMREAL')
        r=rand*(o.TRuniformLU(2)-o.TRuniformLU(1))+o.TRuniformLU(1);
        tree.value=num2str(r);
    elseif strcmp(tree.value,'MAKEUNIFORMINTEGER')
%         r=randint(1,1,[o.TIuniformLU(1) o.TIuniformLU(2)]);
        r=randi([o.TIuniformLU(1) o.TIuniformLU(2)]);        
        tree.value=num2str(r);
    elseif returntype+2==TBool
        Boolvars=[Boolvars termnum];
    elseif returntype+2==TReal
        Realvars=[Realvars termnum];
    end
    tree.numkids=0;

    %we know this is a leaf
    tree.nodedepth = D;
    tree.maxdepth = 1;
    tree.kids = {}; %empty
    tree.numleaves = 1;
    tree.numinternal = 0;


    if D > largestdepth
        largestdepth = D;
    end
end


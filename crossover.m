function children = crossover( parents, options, N, ~, ~, thisPopulation )
%function xoverKids  = crossoversinglepoint(parents,options,GenomeLength,~,~,thisPopulation)
% CROSSOVER: Given a population of P possible solutions to the N-queens
% problem (see createPop function for description of data representation 
% of individuals), and a m X 2 vector of parent indicies (m =< P), return a
% m X N vector of children resulting from the cut and crossfill crossover
% of the given parents.
%
% INPUTS:
% pop: A population of possible solutions to the N-queens problem
% parents: A m X 2 vector of parent indicies (m =< P)
%
% OUTPUTS:
% m X N matrix of children resulting from the cut and crossfill crossover 
% of the m parent pairs
% 
% SAMPLE CALLS:
%   crossover( [1 2 3; 2 1 3; 1 2 3; 3 2 1], [1 4; 1 2; 2 3] )
%
% AUTHOR: Larry Clarfeld 9/11/16

P = size(thisPopulation,2);
children = zeros((size(parents,1)*size(parents,2))/2,P);

for i = 1:size(children,1)
    %child = zeros(1,P);
    p1 = thisPopulation(parents(i),:);
    p2 = thisPopulation(parents(i+1),:);

    crsvrPT = randi(P-1);
    
    child = [p1(1:crsvrPT) p2(crsvrPT+1:end)];
    
%     child(1:crsvrPT) = p1(1:crsvrPT);
%     child(crsvrPT+1:end) = p2(~ismember(p2,p1(1:crsvrPT)));
    
    children(i,:) = child;
    
end


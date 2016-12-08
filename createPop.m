function pop = createPop(P, N, R)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% A function for population creation (pass in the population size P and the 
% number of queens N and return a P × N matrix, where each row is a permutation 
% of N numbers); hint: see randperm


pop = rand(P,N) < R;

end


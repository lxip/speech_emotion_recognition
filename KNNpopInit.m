function pop = KNNpopInit(popsize, Nfeatures, Rate)
% A function for population creation 

pop = zeros(popsize,Nfeatures);

for i = 1:popsize
    
     temp = rand(1,Nfeatures) < Rate;
     if sum(temp) ~= 0 % make sure some features turned on at the beginning
        pop(i,:) = temp;
     end
end
end

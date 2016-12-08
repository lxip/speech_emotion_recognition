function fitness = KNNfitness(pop)

global featureData

fitness = zeros(size(pop,1),1);

for i = 1:size(pop,1)
    disp(['starting ' num2str(i)])
    for j = 1:length(featureData)
        featuresSUB{j} = featureData{j}(logical(pop(i,:)),:);
    end
    
    %%%% KNN classification
    %%%% parameter setting: k = 3, iteration = 20
    [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                    evaluateClassifier(featuresSUB, 2, 1, [0.8,35]);
                
    %%%% calculating fitness    
%     fitness(i) = 1-(Re1+Re2).*(Pr1+Pr2)/(Pr1+Pr2+Re1+Re2); % fitness based on the formula from book
%     fitness(i) = 1-(Ac1+Ac2)/2; % fitness based on accuracy
end
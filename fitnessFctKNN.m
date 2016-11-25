function fitness = fitnessFctKNN( pop )

% global data
% global emotions_raw
global featureData

fitness = zeros(size(pop,1),1);

for i = 1:size(pop,1)
    disp(['starting ' num2str(i)])
    
    featuresSUB{1} = featureData{1}(logical(pop(i,:)),:);
    featuresSUB{2} = featureData{2}(logical(pop(i,:)),:);
    
    [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                    evaluateClassifier(featuresSUB, 2, 1, [0.8,500]);
    fitness(i) = 1 - (Ac1+Ac2)/2;

end
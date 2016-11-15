function fitness = fitnessFct( pop )

global data
global emotions_raw

mask = rand(size(data,1),1) < 0.8;

traindata = data(mask,:);
testdata = data(~mask,:);

trainclasses = emotions_raw(mask);
testclasses = emotions_raw(~mask);

trainclasses = trainclasses == 'F';
testclasses = testclasses == 'F';

fitness = fitnessCounterPropANN(pop,traindata,trainclasses,testdata,testclasses)';

end
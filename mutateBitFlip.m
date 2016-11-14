function mutprnts = mutateBitFlip(parents, options, N, FitnessFct, state, thisScore, thisPopulation, mutationRate) 
%feval(options.MutationFcn,  parents((1 + 2 * nXoverKids):end), options,GenomeLength,FitnessFcn,state,thisScore,thisPopulation,options.MutationFcnArgs{:});

mutprnts = thisPopulation(parents,:)


mask = rand(size(mutprnts));



mutprnts(mask < mutationRate) = ~mutprnts(mask < mutationRate);

end
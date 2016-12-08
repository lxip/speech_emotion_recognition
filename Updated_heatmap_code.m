figure
heatmap(temp,[],1:nngens,[],'Colormap','hot','Colorbar',true,'UseLogColormap','true');
%colormap(flipud(colormap))
xlabel('feature')
ylabel('generation')
title('Frequency of feature appearance in each generation of the GA')
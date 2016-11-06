function [str] = tree2strNEW(tree,o)
%convert tree into evaluable string
% author: Josh Payne
% Modified: Maggie Eppstein

if ~isempty(tree.kids)
    str=o.nodeset{tree.returntype}.names{tree.value};
else
    str=tree.value;
end
args=[];
for k=1:length(tree.kids)
    if ~isempty(tree.kids{k})
        args{k} = tree2strNEW(tree.kids{k},o);
    end
end
if ~isempty(args)
	str=strcat(str,'(',implode(args,','),')');
end

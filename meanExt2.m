function avg = meanExt2(cellArr)

maxlen = 0;

for i = 1:length(cellArr)
    if size(cellArr{i},2) > maxlen
        maxlen = size(cellArr{i},2);
    end
end

dim = size(cellArr{1},1);

avg = zeros(dim,maxlen);

for i = 1:maxlen
    ct = 0;
    for j = 1:length(cellArr)
        if length(cellArr{j}) >= i
            ct = ct + 1;
            avg(:,i) = avg(:,i) + cellArr{j}(:,i);
        end
    end
    avg(:,i) = avg(:,i)./ct;
end
end
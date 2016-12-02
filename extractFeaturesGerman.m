win = 0.02; % Window/frame size at 20 ms
step = win - win/4; % Overlap by 25%

male = [3 10 11 12 15];

dirpath = 'archive';
listing = dir(dirpath);
ct = 0;

for i = 1:length(listing)
    filename = listing(i).name;
    
    if length(filename) > 3 && isequal(filename(end-3:end), '.wav')
    ct = ct + 1;
    
        [signal,fs] = audioread([dirpath '/' filename]);
        featuresALL(ct).features = stFeatureExtraction(signal, fs, win, step);
        featuresALL(ct).filename = filename;
        featuresALL(ct).speaker = str2double(filename(1:2));
        featuresALL(ct).textcode = filename(3:5);
        featuresALL(ct).emotion = filename(6);
        
        if sum(ismember(male,featuresALL(ct).speaker))
            featuresALL(ct).gender = 'm';
        else
            featuresALL(ct).gender = 'f';
        end

        if filename(7) ~= '.'
            featuresALL(ct).vers = filename(7);
        else
            featuresALL(ct).vers = [];
        end
    end
end

save('featuresGerman_addFeature.mat','featuresALL')
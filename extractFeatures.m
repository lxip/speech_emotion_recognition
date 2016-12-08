win = 0.02; % Window/frame size at 20 ms
step = win - win/4; % Overlap by 25%

dirpath = 'archive/Speaker3';
listing = dir(dirpath);
ct = 0;

for i = 1:length(listing)
    filename = listing(i).name;
    
    if length(filename) > 3 && isequal(filename(end-3:end), '.wav')
        ct = ct + 1;
        
        [signal,fs] = audioread([dirpath '/' filename]);
        Speaker3(ct).features = stFeatureExtraction(signal, fs, win, step);
        Speaker3(ct).filename = filename;
        
        if filename(1) == 's'
            Speaker3(ct).type = filename(1:2);
        else
            Speaker3(ct).type = filename(1);
        end
    end
end
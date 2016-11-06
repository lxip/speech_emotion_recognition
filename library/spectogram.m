[d,sr] = audioread('filename.wav');
% Plot the spectrogram
subplot(211)
specgram(d(:,1),1024,sr);
% Read in a different format
[d2,sr] = audioread('filname.m4a');
subplot(212)
specgram(d2(:,1),1024,sr);
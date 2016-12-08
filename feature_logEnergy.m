function logE = feature_logEnergy(window)

% function E = feature_energy(window);
%
% This function calculates the log-energy of an audio frame.
% Log-energy indicates the total squared amplitude in a segment of speech.
% The feature is simply the amount of normalized power in the signal
% ARGUMENTS:
% - window: 	an array that contains the audio samples of the input frame
% 
% RETURN:
% - E:		the computed log-energy value
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

logE = log10((1/(length(window))) * sum(abs(window.^2)));

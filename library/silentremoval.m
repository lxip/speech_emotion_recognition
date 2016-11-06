%program to remove the silences from a speech.

%step 1 -break the signal into frames of 0.1 seconds
FS=44100;
frame_duration=0.1;
frame_len = frame_duration*FS;
N = length(Y)
num_frames = floor(N/frame_len)

new_sig = zeros(N,1);
count=0;
for k = 1: num_frames
    %extract a frame of speech
    frame=Y((k-1)*frame_len+1:frame_len*k);
    %step 2 -identify silence by finding frames with max amplitide 0.02
    max_val=max(frame);
  %step 2 -identify silence by finding frames with max amplitide 0.002  
if(max_val>0.002)
    %this frame is not silent
    count = count+1
    %create a new signal which does not contain a silent frames

    new_sig( (count-1)*frame_len+1:frame_len*count)=frame;
end
end



%T=[1/FS:1/FS:length(Y)/FS]
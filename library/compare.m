function compare(wfeat,mfeat,f)
if nargin < 3
for f=1:size(wfeat,1)
    figure(f)
    [cts,bins]=hist(wfeat(f,:),50);
    [ctsm]=hist(mfeat(f,:),bins);
    plot(bins,cts,'r-',bins,ctsm,'b');
    legend('wav','mpeg')
    pause
end
else

    figure(f)
    [cts,bins]=hist(wfeat(f,:),50);
    [ctsm]=hist(mfeat(f,:),bins);
    plot(bins,cts,'r-',bins,ctsm,'b');
    legend('wav','mpeg')
end

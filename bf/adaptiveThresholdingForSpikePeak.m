function [peaks] = adaptiveThresholdingForSpikePeak(data, peakToRMS )
%ADAPTIVETHRESHOLDINGFORSPIKEPEAK gives the maximum peaks of the data
%vector, if they have a peak to root-mean-square relative of more than the
%given value. If more than one consecutive point fullfils the criterion, only the
%highest point is taken, that is the peak.
% If no point fullfills the criterion, the output will be empty ( [] )

if size(data,1)==1
    data=data';
end

datarms=rms(data);

data=data-peakToRMS*datarms;

%now find points above 0

[~, peaks]=findpeaks(data, 'MinPeakHeight', 0);




end
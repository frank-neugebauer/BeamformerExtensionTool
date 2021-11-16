function [trl] = given_list(cfg)
%given_list takes a list with event-eventname instead of reading it in a
%file
% and call this function as trialfun in ft_definetrial
% as    cfg.trialfun= 'given_list';
%       cfg.trialdef.events=listOfEvents 
%       cfg.is_trl=1 or 0 wether the list is a 4*x trl matrix or a 2*x
%       list
%


% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);

% 
if cfg.is_trl %the timepoint 0 is the start + the offset
    event(:,1)=cfg.trialdef.events(:,1)+cfg.trialdef.events(:,3);
    event(:,2)=cfg.trialdef.events(:,4); %label of the events
else
event=cfg.trialdef.events;
end
%


% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);


% check wether we want all events or a subgroup
trl=[];

allEvents=~isfield(cfg.trialdef, 'eventvalue');



i=1;
%for i=1:size(event,1)
while i<=size(event,1) && event(i,1) <= hdr.nSamples %check wether the events happen after the measurement ended, or after the data was cut into trials. Curry will handle this the same
    
    if allEvents  ||  ismember(event(i,2), cfg.trialdef.eventvalue)
        
        trlbegin = event(i,1) + pretrig;
        trlend   = event(i,1) + posttrig;
        offset   = pretrig;
        
        newtrl   = [trlbegin trlend offset event(i,2)];
        trl      = [trl; newtrl];
        
    end
    i=i+1;
end

if ~(i==size(event,1)) %
    warning('there are events that are timed beyond or before the data limit. They will be ignored');
end



end


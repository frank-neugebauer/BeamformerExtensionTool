function [list] = cutEvents(cfg)
%cutEvents can sort besa-events defined on a continous dataset to cutted pieces
% of that dataset.
%The dataset should be named 'name_number.ds' with number beeing specified in 
%cfg.numbers. 
%cfg.dataset= './P0857/P0857_EpilSEFTonotopy_20171113_0' basic name of dataset
% cfg.numbers
%cfg.eventfile='./P0857/p0857_all_spikes.txt';
% Use later with the 'given_list' trialfun and list{number} for the
% corresponding events.




%% read the header information and the events from the data
name=strcat(cfg.dataset,num2str(cfg.numbers(1)),cfg.endString); 
hdr   = ft_read_header(name);

% read curry events
event=readtable(cfg.eventfile);

% for i=1:size(event,3)
%     if 


eventtime=round(table2array(event(1:end,1))*10^(-6)*hdr.Fs); %original time is 
%in mu-seconds, so convert it to seconds in then to the frame rate
eventlabel=table2array(event(1:end,3));

event=[eventtime, eventlabel]; % event is now in sample_eventname


%%

for i=cfg.numbers
list{i}=[];
end



i=1;
j=1;
while i<=size(event,1)
    
    if event(i,1) > hdr.nSamples %check wether the events happen after the measurement ended, or after the data was cut into trials. Curry will handle this the same
        j=j+1;
        event(:,1)=event(:,1)-hdr.nSamples;
        name=strcat(cfg.dataset,num2str(cfg.numbers(j)),cfg.endString);
        hdr=ft_read_header(name);
        
    end
    
    list{cfg.numbers(j)}= [list{cfg.numbers(j)}; event(i,:)];
    
  i=i+1;  
  
  
end














end


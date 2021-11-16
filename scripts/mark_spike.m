function [list] = mark_spike(cfg)
% mark_spike readjusts marked events with an objective criterion, default
% the maximum value in the time frame. 
% This can be used to compare events marked by different means, to see
% wether they are "essentially" the same, with small differences due to
% marking by hand, different filters, or source localization differences.
% cfg must have the fields
% cfg.dataset
% cfg.eventlist
% cfg.maxdistance (in seconds default 0.8)
% and optionally
% filter and other preprocessing settings (see ft_preprocessing)
% cfg.trialdef.eventvalue
% cfg.criterion (default maximum across channels)

hdr   = ft_read_header(cfg.dataset);

cfg.criterion=ft_getopt(cfg, 'criterion','maximum');

maxdistance=ft_getopt(cfg, 'maxdistance', 0.8);

cfg.trialdef.events=cfg.eventlist;
cfg.trialfun             = 'given_list';
cfg.trialdef.prestim        = maxdistance/2;
cfg.trialdef.poststim       = maxdistance/2;
cfg = ft_definetrial(cfg);

data= ft_preprocessing(cfg);


%list=cfg.eventlist;
for i=1:size(cfg.trl,1)
    
   switch cfg.criterion
    
       case 'maximum'
       [~,~,time]=max_matrix(abs(data.trial{i}));
       timeReal=time-1+data.sampleinfo(i,1);
       
       otherwise
       error('criterion is unknown, sorry :( ')
   end
   
    list(i,1)=timeReal;
    list(i,2)=cfg.trl(i,4);
    
    
    
end
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



























































































end
dataset = 'P0764_EpilSEFTonotopy_20160201_02.ds';

% 
% cfg = [];
%  cfg.dataset = dataset;
% cfg.trialdef.eventtype  = '?';
% ft_definetrial(cfg);

cfg = [];
cfg.dataset              = dataset;
cfg.trialfun             = 'ft_trialfun_general';
cfg.trialdef.triallength = 20;                      % duration in seconds
cfg.trialdef.ntrials     = inf;                    % number of trials, inf results in as many as possible
cfg                      = ft_definetrial(cfg);






% 
% % find the interesting segments of data
% cfg = [];    
% cfg.dataset   = dataset;
%                                      
% cfg.trialdef.eventtype      = 'frontpanel trigger';
% cfg.trialdef.prestim        = 0.2;
% cfg.trialdef.poststim       = 0.4;
% cfg.trialdef.eventvalue     = 1;                    % trigger value for fully congruent (FC)
% cfg = ft_definetrial(cfg);



cfg.hpfilter  = 'yes';
cfg.hpfreq    = 5;
cfg.lpfilter  = 'yes';
cfg.lpfreq    = 100;
cfg.demean='yes';
cfg.channel   = {'meg', 'eeg', '-ECG', '-BP1', '-BP2',    '-BP3',    '-P11',    '-P12',    '-P13',    '-P22',    '-P23',    '-BG1',    '-BG2',    '-BG3',    '-BR1',    '-BR2',    '-BR3',    '-G11',    '-G12',    '-G13',    '-G22',    '-G23',    '-Q11',    '-Q12',    '-Q13','-Q22',    '-Q23', '-R12', '-R13', '-R23'};


%cfg.continous='yes';
cfg.datatype = 'continuous';
data = ft_preprocessing(cfg);














































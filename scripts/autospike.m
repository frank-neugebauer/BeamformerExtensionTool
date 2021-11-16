


%automated spike detection


%read data in 2 min segments
dataset='./P0857/P0857_EpilSEFTonotopy_20171113_03.ds';
channel={'meg'}


%%

cfg = [];
cfg.dataset   = dataset;

cfg.trialdef.triallength = 1;                      % duration in seconds
cfg.trialdef.ntrials     = inf;                    % number of trials, inf results in as many as possible
cfg                      = ft_definetrial(cfg);


cfg.hpfilter  = 'yes';
cfg.hpfreq    = 10;
cfg.lpfilter  = 'yes';
cfg.lpfreq    = 70;
cfg.demean='yes';
cfg.dftfilter='yes'; %default freq is 50
cfg.channel   = channel;
%cfg.continuous='yes';
cfg.datatype = 'continuous';
data=ft_preprocessing(cfg);
%%

cfg=[];
cfg.method='singlesphere';
 head = ft_prepare_headmodel(cfg,data.grad);
 
 

cfg                 = [];
cfg.headmodel       = head;
cfg.reducerank      = 2;
cfg.grid.resolution = 0.7;   % use a 3-D grid with a 1 cm resolution
cfg.grid.unit       = 'cm';
cfg.channel={'meg'};

%cfg.channel=channel;
lead = ft_prepare_leadfield(cfg, data.grad);


%%

highg2=10;

numberTrials=size(data.trial, 2);


list=[];

%tic;
for trial=1:13

cfg.dataset   = dataset;
%look for voxel with high g2
cfg=[];
%cfg.regparameter=regparameter;
%cfg.regparameter=100;
cfg.regparameter=1;
cfg.timer=0;
cfg.plot=0;
cfg.keepFilter=1;
cfg.filtermethod='unit_noise_gain';
cfg.orimethod=cfg.filtermethod;
cfg.analysismethod='g2';
%cfg.latency =[0 0.05];
cfg.trial=trial;
cfg.keepCovarianceMatrix=1;
beam=beamformer(cfg, data, lead);


% in the voxel with max kurtosis, look for peaks with high peak-to-rms
% ratio
listnew=adaptiveThresholdingForSpikePeak(beam.filter{beam.index}'*data.trial{trial},3);
listnew=listnew+(trial-1)*size(data.trial{1},2);
list=[list; listnew]; 



end
display('computed the list');






%% 
covM=beam.covarianceMatrix;
regparameter=100;
regparameter=regparameter*min(eig(covM));
 covMI=inv(covM+regparameter*eye(size(covM,1)));

'fin'

%%
figure
plot(data.time{1},data.trial{trial}')

%%



wave=beam.filter{beam.index}'*data.trial{trial};
num=round(23209*rand());
wave=beam.filter{num}'*data.trial{trial};

plot(data.time{1},wave);






%% change the list to match the sensor space
% 
% cfg = [];
% cfg.dataset   = './P0484/P0484_20120713_SingTrial_Runs_2to7_3rdOrd.ds';
 list(:,2)=ones(size(list));
% 
% cfg.eventlist=list;
% cfg.maxdistance=0.7;
% cfg.is_trl=0;
% cfg.hpfilter  = 'yes';
% cfg.hpfreq    = 1;
% cfg.lpfilter  = 'yes';
% cfg.lpfreq    = 80;
% cfg.demean='yes';
% cfg.dftfilter='yes'; %default freq is 50
% cfg.channel   = channel;
% 
% list_bf=mark_spike(cfg);
% 
% 
% %niceTime(toc);
% 
% 
% 
% [~, diff1]=knnsearch(list_bf(:,1), list_stefan(:,1));
% 
% [~, diff2]=knnsearch(list_stefan(:,1), list_bf(:,1));



%%
cfg=[];
cfg.dataset   = dataset;
cfg.is_trl=0;
cfg.trialfun             = 'given_list';
cfg.trialdef.events=list;
cfg.trialdef.prestim        = 0.2;
cfg.trialdef.poststim       = 0.2;
cfg=ft_definetrial(cfg);


cfg = ft_redefinetrial(cfg, data);


cfg.hpfilter  = 'yes';
cfg.hpfreq    = 10;
cfg.lpfilter  = 'yes';
cfg.lpfreq    = 70;
cfg.demean='yes';
cfg.dftfilter='yes'; %default freq is 50
%cfg.channel   = channel;
%cfg.channel=channel;
databf= ft_preprocessing(cfg, data);

cfg=[];
%cfg.trials=a;

avgdata=ft_timelockanalysis(cfg, databf);
figure;
plot(avgdata.time, avgdata.avg);





%%
for i=1:size(data.trial,2)
    plot(data.time{i},data.trial{i});
    title(strcat('Trial number...',num2str(i))); 
    i
    waitforbuttonpress
end

display('end')


























































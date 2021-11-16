
%pipeline1826;
%%
cfg=[];
% cfg.covarianceMatrixInverse=pinv(C);
%cfg.regparameter=regparameter;
%cfg.regparameter=100;
%cfg.regparameter=min(eig(C))*eye(size(C,1));
cfg.timer=1;
%cfg.covarianceMatrix=C;
cfg.plot=1;
cfg.keepFilter=1;
cfg.filtermethod='unit_noise_gain';
%cfg.orimethod=cfg.filtermethod;
%cfg.analysismethod='scaled_residual_variance';
cfg.analysismethod='variance';
%cfg.windowlength=1200;
cfg.outputstyle=0;
%cfg.latency =lat;
%cfg.trial=trial;
cfg.keepCovarianceMatrix=0;
beamMEG=beamformer(cfg, dataMEGtr.trial{4}, lead);

hold on;
bplot_mark(beamMEG);




locError=norm(beamAVG.pos(beamAVG.index,:)-beamMEG.pos(beamMEG.index,:));



wave1=beamAVG.filter{beamAVG.index}'*avgFull.avg;
wave2=beamMEG.filter{beamMEG.index}'*avgdataMEG.avg;

%wave2=beamMEG.filter{2435}'*avgdataMEG.avg;

waveError=norm(wave1-wave2)/sqrt(norm(wave1)*norm(wave2));

disp(locError);
disp(waveError);




figure;
plot(avgdataMEG.time, wave1)
hold on;
plot(avgdataMEG.time, wave2)



%%

% %reading the events and data

dataset='./A1826/EMEG/A1826_comparisonSEF_20161212_02_signletrial.ds';


channel={'meg', '-MLC24', '-MLO12', '-MLT51'};

%channel={'meg'};

% cfg = [];
% cfg.dataset = dataset;
% cfg.trialdef.eventtype  = '?';
% ft_definetrial(cfg);


cfg = [];
cfg.dataset   = dataset;
% 
cfg.trialdef.triallength=60;
% cfg.trialdef.eventtype      = 'frontpanel trigger';
% cfg.trialdef.prestim        = 0.3;
% cfg.trialdef.poststim       = 0.3;
% cfg.trialdef.eventvalue     = 2;                  
 cfg = ft_definetrial(cfg);


cfg.hpfilter  = 'yes';
cfg.hpfreq    = 10;
cfg.lpfilter  = 'yes';
cfg.lpfreq    = 120;
cfg.demean='yes';
cfg.dftfilter='yes'; %default freq is 50
cfg.channel   = channel;
cfg.continuous='yes';
cfg.datatype = 'continuous';


 dataMEGtr= ft_preprocessing(cfg);


















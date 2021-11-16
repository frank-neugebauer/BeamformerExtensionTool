

% cfg=[];
% % cfg.covarianceMatrixInverse=pinv(C);
% %cfg.regparameter=regparameter;
% %cfg.regparameter=100;
% %cfg.regparameter=min(eig(C))*eye(size(C,1));
% cfg.timer=1;
% cfg.covarianceMatrix=C;
% cfg.plot=1;
% cfg.keepFilter=1;
% cfg.filtermethod='unit_array_gain_vector';
% %cfg.orimethod=cfg.filtermethod;
% %cfg.analysismethod='scaled_residual_variance';
% cfg.analysismethod='computed_variance';
% %cfg.windowlength=1200;
% cfg.outputstyle=0;
% %cfg.latency =lat;
% %cfg.trial=trial;
% cfg.keepCovarianceMatrix=0;
% beamMEG=beamformer(cfg, avgdataEEG, leadEEG);
% 
% hold on;
% bplot_mark(beamMEG);


%%
doiTime=avgdataMEG.time;
doi=avgdataMEG.avg;
beam=beamMEG;

%%
doiTime=avgMEG.time; %1:146
doi=avgMEG.avg(:,:);
beam=beamMEG;

%%
dataG2=zeros(1, size(doi, 2)); 
dataPow=zeros(1, size(doi, 2)); 
dataExp=dataG2;

data1=zeros((size(beam.filter, 1)), size(beam.filter{1},2));

for t=1:size(dataG2, 2)
    
    for f=1:size(beam.filter, 1)
    
        data1(f,:)=beam.filter{f}'*doi(:,t);
    end
    dataG2(t)=g2(data1);
    dataPow(t)=max(abs(data1));
    
    
end
dataG2Pow=(dataG2).*dataPow;

%%
figure('position', [200, 900, 800, 500]);

subplot(3,1,1);
plot(dataG2');
title('g2');

subplot(3,1,2)
plot(doiTime, dataPow');
title('Power');

subplot(3, 1, 3)
plot(doiTime, dataG2Pow');
title('G2*Power');

return;

%%
figure('position', [200, 900, 800, 500]);


subplot(3,1,1);
plot( doi', 'color', 'blue');
title('Data');

subplot(3,1,2)
plot(doiTime, dataPow');
title('Source Power');


subplot(3,1,3);
plot(dataG2');
title('Source focality (kurtosis)');


%%
figure('position', [200, 900, 800, 500]);


subplot(2,1,1);
plot(doiTime, doi, 'color', 'blue');
title('Data');


subplot(2,1,2);
plot(doiTime, dataG2Pow);
title('combined power&focality');

%%



figure('position', [200, 900, 800, 500]);


subplot(4,1,1);
plot(doiTime, doi, 'color', 'blue');
title('Data');


subplot(4,1,2);
plot(doiTime, resv);
title('strength of dipole scan');


subplot(4,1,3);
plot(doiTime, str);
title('strength of dipole scan');


subplot(4,1,4);
plot(doiTime, str.*resv);
title('strength*resVar of dipole scan');

%%
beamPl=beam;
beamPl=rmfield(beamPl, 'value');
for i=1:size(beamPl.pos, 1)
    beamPl.value(i)=abs(beam.filter{i}'*doi(:,481));
end
beamPl.value=beamPl.value';
[beamPl.maximum beamPl.index]=max(beamPl.value);

figure;
bplot_sub(beamPl);

hold on;
%bplot_mark(beamPl);

%%

figure( 'Position', [200 900 800 500]);
bplot_sub(beamPl);
hold on;
col=[1 0 0];

for i=1:size(resection, 1)
    
          
    %c=col+[0 i/size(dipscanMEG,2) 0];
    c=col;
    %c=col*i/size(dipscan,2),
    
    subplot(2,2,1);
    hold on;
    scatter(resection(i,2), resection(i,1), 50, c, 'filled' );
    %text(dipscanMEG{i}.dip.pos(2), dipscanMEG{i}.dip.pos(1), num2str(i));
    subplot(2,2,2);
    hold on;
    scatter(resection(i,1), resection(i,3), 50,c, 'filled');
    %text(dipscanMEG{i}.dip.pos(1), dipscanMEG{i}.dip.pos(3), num2str(i));
    
    subplot(2,2,3);
    hold on;
    scatter(resection(i,2), resection(i,3), 50,c,'filled');
    %text(dipscanMEG{i}.dip.pos(2), dipscanMEG{i}.dip.pos(3), num2str(i));
    
    subplot(2,2,4);
    hold on;
    scatter3(resection(i,1),resection(i,2), resection(i,3), 100,  '.', 'red');
    xticklabels('');
    yticklabels('');
    zticklabels('');
    
end





%%

index100=find(beamPl.value>=beamPl.value(beamPl.index))
index90=find(beamPl.value>=0.9*beamPl.value(beamPl.index))
index80=find(beamPl.value>=0.8*beamPl.value(beamPl.index))
index70=find(beamPl.value>=0.7*beamPl.value(beamPl.index))

index60=find(beamPl.value>=0.6*beamPl.value(beamPl.index))


beamPlC=beam2Curry(beamPl, source_grid);

beamPlCInd=beamPlC(index90,:);

%%


lat=0.002;
    
    cfg = [];
    cfg.latency = [-0.046 , -0.046];  % specify latency window around M50 peak
    cfg.numdipoles = 1;
    cfg.headmodel=headMEG;
    cfg.feedback = 'textbar';
    cfg.grid.pos=leadMEG.pos;
    cfg.grid.inside=leadMEG.inside;
    cfg.grid.unit = 'cm';
    cfg.nonlinear='no';
    cfg.channel=channelMEG;
    %cfg.elec=dataPost.elec;
    cfg.grid.leadfield=leadMEG.leadfield;
    dipscanMEG= ft_dipolefitting(cfg, avgMEG);

%%
index=0;
for i=1:size(beam.pos, 1)
    
    if(beam.pos(i,:)==dipscanMEG.dip.pos)
        index=i;
        break;
    end
end

  dipCurry=[1,  source_grid(index, :)];







































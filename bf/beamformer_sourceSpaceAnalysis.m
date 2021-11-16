function [ out ] = beamformer_sourceSpaceAnalysis(cfg, beam, dataOrig)
%beamformer_waveAnalysis applies
%different methods to analyze the waveform produced by the filters of beam
%and the given data. 
% These methods are
%     'max_power'
%     'g2_focality'
%     
%     and combinatios thereof 
% 
% 



%% set defaults provided cfg

methods=cfg.methods; %array of strings
%check wether methods are known

numberMethods=max(size(methods));


trial=ft_getopt(cfg, 'trial', 1);
avg=ft_getopt(cfg, 'avg', 1);
%% set defaults given data

%check wether data is numeric or array
if isnumeric(dataOrig)
    data=dataOrig;
    dataTime=1:size(data, 2);
    disp('numeric input. Data array is assumed');
    disp('no time information given');
else
    disp('Input data is not numeric. Assuming FieldTrip processed data');
    if isfield(dataOrig, 'avg') && avg
        data=dataOrig.avg;
        dataTime=dataOrig.time;
        disp('Data is averaged. Using the avg data for analysis');
    else
        if isfield(dataOrig, 'trial') && isnumeric(trial)
            data=dataOrig.trial{trial};
            dataTime=dataOrig.time{trial};

            display(strcat('Using trial ', num2str(trial)));
        else
            error('bad luck. Please check again later for updates in our methods');
        end
    end
end



%% set defaults given beam


%%
dataMethod=cell(numberMethods, 1);


space=zeros(size(beam.filter,1),size(beam.filter{1},2));


for t=1:size(data, 2)
    for p=1:size(beam.filter, 1)
        space(p,:)=beam.filter{p}'*data(:,t);
    end
    
    
    for m=1:numberMethods
        
        switch methods{m}
            
            case 'g2_focality'
                dataMethod{m}(t)=g2(space);
                     
            case 'g2_focality_3d'
                dataMethod{m}(t)=g2_3d(space); 
                
            case 'g2_focality_pca'
                [~, wave]=pca(space);
                dataMethod{m}(t)=g2(wave(:,1));
                
            case 'max_abs'
                dataMethod{m}(t)=max(abs(space));
                
            case 'max_norm'
                dataMethod{m}(t)=max(vecnorm(space, 1));
                
            case 'max_power'
                dataMethod{m}(t)= max(space.^2);
                
            case 'spatial_dispersion'
                dataMethod{m}(t)=spatialDispersion(space.^2);
                
            case 'maximum_movement'
                if t==1
                dataMethod{m}(t)=NaN;
                [~, indext0]=max(space.^2);
                
                else
               [~, indext1]=max(space.^2);

                dataMethod{m}(t)=norm(beam.pos(indext0,:)-beam.pos(indext1,:));
                indext0=indext1;
                end
                
            case 'difference'
          [~, indext]=max(space.^2);

            dataMethod{m}(t)=norm(beam.pos(cfg.index,:)-beam.pos(indext,:));

                
                
                
        end
        
    end
    
    
    
end



%% combine methods



for m=1:numberMethods
    
    switch methods{m}
        
        case {'quality', 'abs*g2'}
            dataMethod{m}=dataMethod{1}.*dataMethod{2};
            
    end
    
end



%% output

out.dataMethod=dataMethod;
out.cfg=cfg;

%% plot

figure('position', [200, 900, 800, 500]);

subplot(numberMethods+1, 1, 1);
plot(dataTime, data);
title(data);

for i=1:numberMethods
    
    subplot(numberMethods+1, 1, i+1);
    plot(dataTime, dataMethod{i});
    title(methods{i});
    
end





















































































end


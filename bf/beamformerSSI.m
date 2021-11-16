function [ output ] = beamformerSSI(cfg, dataOrig, leadfield)



output=[];
output.cfg=cfg;


filtermethod=ft_getopt(cfg, 'filtermethod', 'unit_array_gain');
analysismethod=ft_getopt(cfg, 'analysismethod', 'variance');
orimethod=ft_getopt(cfg, 'orimethod', filtermethod);
windowlength=ft_getopt(cfg,'windowlength','empty');
covariancematrix=ft_getopt(cfg,'covarianceMatrix','C');
covariancematrixI=ft_getopt(cfg,'covarianceMatrixInverse','CI');
regparameter=ft_getopt(cfg,'regparameter', 0);
keepFilter=ft_getopt(cfg,'keepFilter',1);
keepCovarianceMatrix=ft_getopt(cfg,'keepCovarianceMatrix',0);
timer=ft_getopt(cfg, 'timer', 'no');
plotOut=ft_getopt(cfg, 'plot', 0);
normalizeLeadfield=ft_getopt(cfg, 'normalizeLeadfield', 0);
ftoutputstyle=ft_getopt(cfg, 'outputstyle', 0); %0 for my default, 1 for fieldtrip
channel=ft_getopt(cfg, 'channel', 'all');

numberRuns=ft_getopt(cfg, 'numberOfRuns', 50);

statistic=ft_getopt(cfg, 'statistic', 0);
statisticNumber=ft_getopt(cfg, 'statisticRuns', 100);




%see if data is in Fieldtrip-format or just a numeric array.
%FT data trial is converted to numeric array
if isnumeric(dataOrig)
    error('need trial data');
else
    if isfield(dataOrig, 'trial')
        data=horzcat(dataOrig.trial{:});
        trialLength=size(dataOrig.trial{1},2);
        numberTrials=max(size(dataOrig.trial));
        disp('assuming the same length for all trials');
    end
end





%compute covariance matrix and its inverse, if not precomputed
% in case of non-adaptiv filtering, this is unnecessary
if strcmp(covariancematrix, 'C')
    covariancematrix=cov(data');
    %     gramMatrix=cell2mat(leadfield.leadfield);
    %     gramMatrix=gramMatrix*gramMatrix';
    %     gramMatrixI=inv(gramMatrix);
else
    disp('Using precimputed CovarianceMatrix');
end



if strcmp(covariancematrixI, 'CI')
    %regparameter=regparameter*min(eig(covariancematrix))
    covariancematrixI=inv(covariancematrix+regparameter*eye(size(covariancematrix,1)));
    %display('Using precomputed matrixInverse for the Covariancemarix');
end





leadfield.leadfield=leadfield.leadfield(leadfield.inside);
leadfield.pos=leadfield.pos(leadfield.inside,:);

%leadfield=leadfieldChannel(channel, leadfield);
%TODO this gives a problem if no channel labels are given








if timer
    tic;
end



if normalizeLeadfield
    for n=1:size(leadfield.leadfield,2)
        leadfield.leadfield{n}=leadfield.leadfield{n}/norm(leadfield.leadfield{n}, 'fro');
        %display('normalizing leadfield');
    end
end


%compute filter for every point
numberPos=size(leadfield.pos,1);
filter=cell(numberPos,1);

valueSSI=zeros(numberPos,numberRuns);

if statistic
valueMax=-ones(statisticNumber, 1);
valueSK=zeros(numberPos, numberRuns);

signValueA=ones(floor(numberTrials/2), 1);
signValueA(randsample( floor(numberTrials/2) , floor(numberTrials/4)))=-1;
signValueB=ones(ceil(numberTrials/2), 1);
signValueB(randsample( ceil(numberTrials/2) , floor(numberTrials/4)))=-1;

end
                for n=1:numberPos
                    
                    if mod(n, 100)==0
                        disp(n);
                    end

                  filter{n}=covariancematrixI*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
                    wave=filter{n}'*data;
                    wavePCA=pca(wave');
                    wave=wavePCA(:,1)'*wave;
                    
                    %now cut the wave into the trials again
                   index=repmat(1:trialLength, numberTrials, 1);
                   index=index+[0:trialLength:(numberTrials*trialLength-1)]';
                   wave=wave(index);
                    
                    
                    valueK=zeros(numberRuns,1);
                    for k=1:numberRuns
                        wave=wave(randperm(numberTrials), :); %is it ok to shuffle wave every time?
                        A=wave(1:floor(numberTrials/2),:);
                        B=wave(floor(numberTrials/2)+1:end,:);
                        
                        covAB=cov(mean(A), mean(B)); %2x2 cov-matrix
                        covAB=covAB(1,2);
                        valueK(k)=covAB/sqrt(var(mean(A))*var(mean(B)));
                        valueSSI(n, k)=mean(valueK(1:k));


                    end
                    
                    
                    if statistic
                        for s=1:statisticNumber
                            for k=1:numberRuns
                                wave=wave(randperm(numberTrials), :); %is it ok to shuffle wave every time?
                                A=diag(signValueA(randperm(size(signValueA,1))))*wave(1:floor(numberTrials/2),:);
                                B=diag(signValueB(randperm(size(signValueB,1))))*wave(floor(numberTrials/2)+1:end,:);
                                
                                covAB=cov(mean(A), mean(B)); %2x2 cov-matrix
                                covAB=covAB(1,2);
                                valueK(k)=covAB/sqrt(var(mean(A))*var(mean(B)));
                            end
                            valueSK(s)=mean(valueK);
                            valueMax(s)=max(valueMax(s), valueSK(s));
                        end
                    end
                    
                end
                
                
                
                
                
                
                
                
                
value=valueSSI(:,numberRuns);
                
                
                
                
                
                
                
%collect all data for the output
if ~ftoutputstyle
    output.pos=leadfield.pos;
    output.inside=leadfield.inside;
    
    
    % if ~strcmp(analysismethod,'all')
    output.value=value;
    output.valueSSI=valueSSI;
    
    if statistic
    output.statistic=valueMax;
    end
    % else
    %     output.value_var=value_var;
    % end
    
    
    if keepFilter
        output.filter=filter;
    end

    
    if keepCovarianceMatrix
        output.covarianceMatrix=covariancematrix;
    end
    
    
    if timer
        output.timer=toc;
        display(strcat('Computing time was ', niceTime(output.timer)));
    end
    
    [val, ind]= max(value);
    output.maximum=val;
    output.index=ind;
    
else %fieldtripStyle
    %we need the output of ft_sourceanalysis and the beamformer output in
    %the avg fieldbeam
    
   
    output.method = 'average';
    
    output.inside=true(size(leadfield.pos));
    output.pos=leadfield.pos;

    
    
    avgout.ori=orientation;
    avgout.pow=value;
    avgout.filterdimord='{pos}_ori_chan';%??
    output.avg = avgout;
    
    
end

if plotOut
    %bplot_3d(output);
    bplot_inside(output);
end






























                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                

end






























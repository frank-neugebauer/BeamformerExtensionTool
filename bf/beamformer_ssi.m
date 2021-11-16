function [ output ] = beamformer_ssi(cfg, dataTrials, leadfield)

filtermethod=ft_getopt(cfg, 'filtermethod', 'unitgain');
analysismethod=ft_getopt(cfg, 'analysismethod', 'variance');
%orimethod=ft_getopt(cfg, 'orimethod', '3d');
windowlength=ft_getopt(cfg,'windowlength','empty');
covarianceMatrix=ft_getopt(cfg,'covarianceMatrix','C');
covarianceMatrixI=ft_getopt(cfg,'covarianceMatrixInverse','CI');
noiseCovarianceMatrix=ft_getopt(cfg, 'noiseCovarianceMatrix', 'NC');
noiseCovarianceMatrixI=ft_getopt(cfg, 'noiseCovarianceMatrixI', 'NCI');
covariancePower=ft_getopt(cfg, 'covariancePower', 3);
regparameter=ft_getopt(cfg,'regparameter', 0);
%keepFilter=ft_getopt(cfg,'keepFilter','yes');
keepCovarianceMatrix=ft_getopt(cfg,'keepCovarianceMatrix','no');
timer=ft_getopt(cfg, 'timer', 'no');
plotOut=ft_getopt(cfg, 'plot', 0);
waveform=ft_getopt(cfg, 'waveform', 0);
noiseData=ft_getopt(cfg, 'noiseData', 0);


leadfield.leadfield=leadfield.leadfield(leadfield.inside);
leadfield.pos=leadfield.pos(leadfield.inside,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%
%leadfield.leadfield=leadfield.leadfield(1:5:end);
%leadfield.pos=leadfield.pos(1:5:end,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

data=horzcat(dataTrials{:,:});
numberTrials=max(size(dataTrials));


if timer
    tic;
end





% If no windowlength is chosen for a method with one, error.
% If a windowlength is chosen for a method without window, warn.

if (strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2'))&&strcmp(windowlength,'empty')
    error('cfg.windowlength cannot be empty for chosen analysismethod')
end

if (~(strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')))&&~strcmp(windowlength,'empty')
    warning('windowlength is soecified but not considered for the chosen analysismethod. It will be ignored');
end



%compute covariance matrix and its inverse, if not precomputed
% in case of non-adaptiv filtering, this is unnecessary
if strcmp(covarianceMatrix, 'C')
    covarianceMatrix=cov(data');
else
    display('Using precomputed CovarianceMatrix');
end

if strcmp(noiseCovarianceMatrix, 'NC')
    if ~noiseData
    noiseCovarianceMatrix=eye(size(covarianceMatrix));
    display('using white-Noise-CovarianceMatrix');
    else 
        noiseCovarianceMatrix=cov(noiseData');
    end
else
    display('Using precomputed NoiseCovarianceMatrix');
end



if strcmp(covarianceMatrixI, 'CI')
    covarianceMatrixI=inv(covarianceMatrix+regparameter*eye(size(covarianceMatrix,1)));
end

if strcmp(noiseCovarianceMatrixI, 'NCI')
    noiseCovarianceMatrixI=inv(noiseCovarianceMatrix+regparameter*eye(size(covarianceMatrix,1)));
end


% gramMatrix=cell2mat(leadfield.leadfield);
% gramMatrix=gramMatrix*gramMatrix';
% gramMatrixI=inv(gramMatrix+regparameter*eye(size(gramMatrix)));



numberPos=size(leadfield.leadfield,2);
value=zeros(numberPos,1);


                for n=1:numberPos
                    for t=1:numberTrials
                    
                    
                    W=covarianceMatrixI*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n});
                    wave=W'*data;
                    wavePCA=pca(wave);
                    wavePCA=wavePCA(:,1);
                    %waveH=hilbert(wavePCA);
                    valueK=zeros(50,1);
                    for k=1:50
                        A=zeros(floor(numberTrials/2),1);
                        B=ones(ceil(numberTrials/2),1);
                        index=randsample(numberTrials, floor(numberTrials/2));
                        A(index)=1;
                        B(index)=0;
                        
                        A=dataTrials{A};
                        B=dataTrials{B};
                        
                        valueK(k)=cov(mean(A), mean(B))/sqrt(var(mean(A))*var(mean(B)));
                                              
                    end
                    value(n)=mean(valueK);
                end





end


function [ output] = beamformer_huang(cfg, data, leadfield)

%this constructs three 1d filter as described in Commonalities and
%Differences Among Vectorized Beamformers in Electromagnetic Source Imaging
%by M-X Huang et al









%{
data is the (filtered, not avereaged) data
leadfield is the struct containing the sourcepositions and appropriate
leadfields, made with ft_prepare_leadfield

cfg is a struct with
cfg.filtermethod =  type 1
                    type 1 alt
                    type 2
                    type 3
                    type 4

cfg.analysismethod = 'variance' default g2
                    'g2' excess kurtosis of the voxels
                    'max_g2'
                    'sum_g2'

cfg.orimethod = max_pseudo_z default
                max_g2

and can optionaly contain

cfg.windowlength=x integer describing the length of the sliding window for
                    the max_g2 and sum_g2 method. The shorter the window, the more frequent spikes are
                    favoured, but the analysis gets more blurried. (default
                    none)

cfg.covarianceMatrix=C  contains the precomputed covariance matrix (default:
                        none)

cfg.covarianceMatrixInverse=CI contains the precomputed inverse covariance
                                matrix (default none)

cfg.keepCovarianceMatrix='yes' or 'no'


cfg.regparameter=a regularisation parameter for the filter computation
                        (default=0). Can cause problems when cfg.covarianceMatrixInverse is precomputed.
                        

% cfg.method= 'sam'
%             'samg2'
%             'lcmv'
%             Sets default configuration for the methods (not implemented
%             yet)
cfg.keepFilter='yes' or 'no' default: 'yes'

%}





%configure the defaults

%   val = ft_getopt(s, key, default, emptymeaningful)
% where the input values are
%   s               = structure or cell-array
%   key             = string
%   default         = any valid MATLAB data type
%  emptymeaningful = boolean value (optional, default = 0)


filtermethod=ft_getopt(cfg, 'filtermethod', 'unitgain');
analysismethod=ft_getopt(cfg, 'analysismethod', 'variance');
%orimethod=ft_getopt(cfg, 'orimethod', '3d');
windowlength=ft_getopt(cfg,'windowlength',2400);
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
normalizeLeadfield=ft_getopt(cfg, 'normalizeLeadfield', 0);

leadfield.leadfield=leadfield.leadfield(leadfield.inside);
leadfield.pos=leadfield.pos(leadfield.inside,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%


%leadfield.leadfield=leadfield.leadfield(1:5:end);
%leadfield.pos=leadfield.pos(1:5:end,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#





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
        noiseCovarianceMatrixI=noiseCovarianceMatrix;
    else
        noiseCovarianceMatrix=cov(noiseData');
    end
else
    display('Using precomputed NoiseCovarianceMatrix');
end

regparameter=regparameter*min(eig(covarianceMatrix));

if strcmp(covarianceMatrixI, 'CI')
    covarianceMatrixI=inv(covarianceMatrix+regparameter*eye(size(covarianceMatrix,1)));
end

if strcmp(noiseCovarianceMatrixI, 'NCI')
    noiseCovarianceMatrixI=inv(noiseCovarianceMatrix+regparameter*eye(size(covarianceMatrix,1)));
end


if normalizeLeadfield
    for n=1:size(leadfield.leadfield,2)
        leadfield.leadfield{n}=leadfield.leadfield{n}/norm(leadfield.leadfield{n});
    end
end
%gramMatrix=cell2mat(leadfield.leadfield);
%gramMatrix=gramMatrix*gramMatrix';
%gramMatrixI=inv(gramMatrix+regparameter*eye(size(gramMatrix)));



numberPos=size(leadfield.leadfield,2);
%compute waveforms and the analysis-output for every point
value=zeros(numberPos,1);
valueE=value;
valueEN=value;
%waveform=filter{n}'*data;
switch analysismethod
    
    case 'variance'
        switch filtermethod
            
            case 'type1'
                for n=1:numberPos
                    value(n)=trace(inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n}))/trace(inv(leadfield.leadfield{n}'*noiseCovarianceMatrixI*leadfield.leadfield{n}));
                end
                
            case 'type1_alt'
                for n=1:numberPos
                    valueX=inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3));
                    value(n)=valueX+valueY+valueZ;
                    
                end
                
            case 'type1_alt_T'
                for n=1:numberPos
                    valueX=inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*leadfield.leadfield{n}(:,3));
                    
                    
                    valueXn= inv(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*leadfield.leadfield{n}(:,1));
                    valueYn=inv(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*leadfield.leadfield{n}(:,2));
                    valueZn=inv(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*leadfield.leadfield{n}(:,3));
                    
                    
                    value(n)=valueX+valueY+valueZ-(valueXn+valueYn+valueZn);
                    
                    
                end
                
                
                
                
                
                
            case 'type2'
                covarianceMatrixI2=covarianceMatrixI*covarianceMatrixI;
                for n=1:numberPos
                    valueX=inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixI2*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixI2*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixI2*leadfield.leadfield{n}(:,3));
                    value(n)=valueX+valueY+valueZ;
                end
                
            case 'type3'
                for n=1:numberPos
                    valueX=inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixI*noiseCovarianceMatrixI*covarianceMatrixI*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixI*noiseCovarianceMatrixI*covarianceMatrixI*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixI*noiseCovarianceMatrixI*covarianceMatrixI*leadfield.leadfield{n}(:,3));
                    value(n)=valueX+valueY+valueZ;
                end
                
            case 'type4'
                covarianceMatrixIn=covarianceMatrixI^covariancePower;
                noiseCovarianceMatrixIn=noiseCovarianceMatrixI^(covariancePower);
                for n=1:numberPos
                    valueX=inv(leadfield.leadfield{n}(:,1)'*covarianceMatrixIn*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixIn*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*covarianceMatrixIn*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixIn*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*covarianceMatrixIn*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixIn*leadfield.leadfield{n}(:,3));
                    value(n)=valueX+valueY+valueZ;
                    
                end
                
                
            case 'dual'
                for n=1:numberPos
                    Kdual=inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n})*(leadfield.leadfield{n}'*noiseCovarianceMatrixI*noiseCovarianceMatrix*noiseCovarianceMatrixI*leadfield.leadfield{n});
                    value(n)=trace(Kdual);
                end
                
                
                
            case 'sLORETA'
                for n=1:numberPos
                    filter=gramMatrixI*leadfield.leadfield{n}/sqrt(trace(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
                    value(n)=trace(filter'*gramMatrix*filter);
                end
                
            case 'sLORETA_alt'
                for n=1:numberPos
                    filterX=gramMatrixI*leadfield.leadfield{n}(:,1)/sqrt(trace(leadfield.leadfield{n}(:,1)'*gramMatrixI^2*leadfield.leadfield{n}(:,1)));
                    filterY=gramMatrixI*leadfield.leadfield{n}(:,2)/sqrt(trace(leadfield.leadfield{n}(:,2)'*gramMatrixI^2*leadfield.leadfield{n}(:,2)));
                    filterZ=gramMatrixI*leadfield.leadfield{n}(:,3)/sqrt(trace(leadfield.leadfield{n}(:,3)'*gramMatrixI^2*leadfield.leadfield{n}(:,3)));
                    valueX=filterX'*gramMatrix*filterX;
                    valueY=filterY'*gramMatrix*filterY;
                    valueZ=filterZ'*gramMatrix*filterZ;
                    value(n)=valueX+valueY+valueZ;
                end
                
                
            case 'mn'
                filter=cell2mat(leadfield.leadfield)'*gramMatrixI;
                % wave=filter*data; %braucht zuviel Platz
                for n=1:numberPos
                    wave=filter(n,:)*data;
                    value(n)=var(wave);
                    valueE(n)=entropy(wave);
                    % valueEN(n)=value(n)/entropy(Nwave);
                end
                
                
            case 'mn_single'  %macht nicht so richtig viel Sinn
                for n=1:numberPos
                    % filter=inv(leadfield.leadfield{n}'*leadfield.leadfield{n})*leadfield.leadfield{n}';
                    %leadfield.leadfield{n}=leadfield.leadfield{n}/norm(leadfield.leadfield{n});
                    filter=pinv(leadfield.leadfield{n});
                    %filter=filter/norm(filter);
                    %value(n)=norm(filter*data);
                    wave=filter*data;
                    Nwave=filter*noiseData;
                    value(n)=trace(cov(wave'))/trace(cov(Nwave'));
                    valueE(n)=entropy(wave);
                    valueEN(n)=value(n)/entropy(Nwave);
                end
                
            case 'kurtosis'
                kurt=kurtosisMatrix(data,0.1);
                kurtI=inv(kurt);
                %kurtN=eye(270);
                kurtN=kurtosisMatrix(noiseData, 0.1);
                kurtNI=inv(kurtN);
                
                for n=1:numberPos
                    valueX=inv(leadfield.leadfield{n}(:,1)'*kurtI*leadfield.leadfield{n}(:,1))/inv(leadfield.leadfield{n}(:,1)'*kurtNI*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*kurtI*leadfield.leadfield{n}(:,2))/inv(leadfield.leadfield{n}(:,2)'*kurtNI*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*kurtI*leadfield.leadfield{n}(:,3))/inv(leadfield.leadfield{n}(:,3)'*kurtNI*leadfield.leadfield{n}(:,3));
                    value(n)=valueX+valueY+valueZ;
                end
                
                
            case 'alt_1'
                parfor n=1:numberPos
                    Wx=noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1));
                    Wy=noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2));
                    Wz=noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3));
                    
                    
                    valueX=inv(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1));
                    valueY=inv(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2));
                    valueZ=inv(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3));
                    value(n)=valueX+valueY+valueZ;
                    
                    
                    value(n)=var(Wx'*data)+var(Wy'*data)+var(Wz'*data)-value(n);
                end
                
            case 'type2_T'
                covarianceMatrixI2=covarianceMatrixI*covarianceMatrixI;
                noiseCovarianceMatrixI2=noiseCovarianceMatrixI*noiseCovarianceMatrixI;
                for n=1:numberPos
                    valueX=leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*covarianceMatrixI2*leadfield.leadfield{n}(:,1));
                    valueY=leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*covarianceMatrixI2*leadfield.leadfield{n}(:,2));
                    valueZ=leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*covarianceMatrixI2*leadfield.leadfield{n}(:,3));
                    
                    valueXn=leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI2*leadfield.leadfield{n}(:,1));
                    valueYn=leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI2*leadfield.leadfield{n}(:,2));
                    valueZn=leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI2*leadfield.leadfield{n}(:,3));
                    
                    value(n)=valueX+valueY+valueZ-(valueXn+valueYn+valueZn);
                end
                
                %             case 'type3_T'  reverts to type2_T
                %                 covarianceMatrixI2=covarianceMatrixI*covarianceMatrixI;
                %                 noiseCovarianceMatrixI2=noiseCovarianceMatrixI*noiseCovarianceMatrixI;
                %                 for n=1:numberPos
                %                     valueX=leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*covarianceMatrixI2*leadfield.leadfield{n}(:,1));
                %                     valueY=leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*covarianceMatrixI2*leadfield.leadfield{n}(:,2));
                %                     valueZ=leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*covarianceMatrixI2*leadfield.leadfield{n}(:,3));
                %
                %                     valueXn=leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI2*leadfield.leadfield{n}(:,1));
                %                     valueYn=leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI2*leadfield.leadfield{n}(:,2));
                %                     valueZn=leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI2*leadfield.leadfield{n}(:,3));
                %
                %                     value(n)=valueX+valueY+valueZ-(valueXn+valueYn+valueZn);
                %                 end
                %
                
                
            case 'type4_T'
                covarianceMatrixIn=covarianceMatrixI^covariancePower;
                noiseCovarianceMatrixIn=noiseCovarianceMatrixI^covariancePower;
                covarianceMatrixI2n=covarianceMatrixIn^2;
                noiseCovarianceMatrixI2n=noiseCovarianceMatrixIn^2;
                
                for n=1:numberPos
                    
                    valueX=leadfield.leadfield{n}(:,1)'*covarianceMatrixIn*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*covarianceMatrixI2n*leadfield.leadfield{n}(:,1));
                    valueY=leadfield.leadfield{n}(:,2)'*covarianceMatrixIn*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*covarianceMatrixI2n*leadfield.leadfield{n}(:,2));
                    valueZ=leadfield.leadfield{n}(:,3)'*covarianceMatrixIn*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*covarianceMatrixI2n*leadfield.leadfield{n}(:,3));
                    
                    valueXn=leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixIn*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI2n*leadfield.leadfield{n}(:,1));
                    valueYn=leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixIn*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI2n*leadfield.leadfield{n}(:,2));
                    valueZn=leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixIn*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI2n*leadfield.leadfield{n}(:,3));
                    
                    value(n)=valueX+valueY+valueZ-(valueXn+valueYn+valueZn);
                    
                end
                
            case 'unit_gain_vector'
                for n=1:numberPos
                    value(n)=trace(inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n}));
                end
                
            case 'array_gain_vector' %array_gain with W*L=||L||*I
                for n=1:numberPos
                    value(n)=trace(inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n}))/norm(leadfield.leadfield(n))^2;
                end
                
            case 'array_gain_vector_ind' %array_gain with w_i*L_i=||L_i|| and w_i*L_j=0  for j!=i, i=x,y,z.  
                for n=1:numberPos
                    arrayMatrix=vertcat([norm(leadfield.leadfield{n}(:,1)) ,0,0], [norm(leadfield.leadfield{n}(:,2)) ,0,0], [norm(leadfield.leadfield{n}(:,3)) ,0,0]);
                    
                    value(n)=trace(arrayMatrix*inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n}))*arrayMatrix;
                end

            
            case 'unit_gain_vector_g2p'
                for n=1:numberPos
                    W=covarianceMatrixI*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n});
                    value(n)=g2p(W'*data);
                end










                
                
            otherwise
                error('method is unknown');
                
        end
        
        %
        %
        %
        %         case 'g2'
        %             value(n)=g2(waveform);
        %
        %         case 'max_g2'
        %             value(n)=g2max(waveform, cfg.windowlength);
        %
        %         case 'sum_g2'
        %             value(n)=g2sum_plus(waveform, cfg.windowlength);
        %
        %         case 'online_g2'
        %             value(n)=online_kurtosis(waveform);
        
    otherwise
        error('Analysismethod is unknown');
        
end


































%unnötig, dies von der normalen Analysis zu trennen!

if waveform
    %wave=cell(numberPos,1);
    numberMeas=size(data,2);
    display('waveform analysis started, this might take a while');
    switch analysismethod
        case 'variance'
            switch filtermethod
                
                case 'type1'
                    for n=1:numberPos
                        wave{n}=zeros(1,numberMeas);
                        
                        W=covarianceMatrixI*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covarianceMatrixI*leadfield.leadfield{n});
                        denominator=1/trace(inv(leadfield.leadfield{n}'*noiseCovarianceMatrixI*leadfield.leadfield{n}));
                        for m=1:numberMeas
                            wave{n}(m)=trace(W'*data(:,m)*data(:,m)'*W)*denominator;
                        end
                    end
                    
                case 'type1_alt'
                    
                    
                    parfor n=1:numberPos
                        Wx=covarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*covarianceMatrixI*leadfield.leadfield{n}(:,1));
                        Wy=covarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*covarianceMatrixI*leadfield.leadfield{n}(:,2));
                        Wz=covarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*covarianceMatrixI*leadfield.leadfield{n}(:,3));
                        
                        
                        WxN=noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1)/(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1));
                        WyN=noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2)/(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2));
                        WzN=noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3)/(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3));
                        
                        %                             denX=1/inv(leadfield.leadfield{n}(:,1)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,1));
                        %                             denY=1/inv(leadfield.leadfield{n}(:,2)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,2));
                        %                             denZ=1/inv(leadfield.leadfield{n}(:,3)'*noiseCovarianceMatrixI*leadfield.leadfield{n}(:,3));
                        
                        %wave=(Wx'+Wy'+Wz')*data;
                        %waveN=(WxN'+WyN'+WzN')*data;
                        
                        %                         [xsum, xmax]=g2_win(Wx'*data, windowlength);
                        %                         [ysum, ymax]=g2_win(Wy'*data, windowlength);
                        %                         [zsum, zmax]=g2_win(Wz'*data, windowlength);
                        %
                        %                         [xnsum, xnmax]=g2_win(WxN'*data, windowlength);
                        %                             [ynsum, ynmax]=g2_win(WyN'*data, windowlength);
                        %                             [znsum, znmax]=g2_win(WzN'*data, windowlength);
                        
                        %                         valueE(n)=xsum+ysum+zsum;%-(xnsum+ynsum+znsum);
                        %                         valueEN(n)=xmax+ymax+zmax;%-(xnmax-ynmax+znmax);
                        
                        valueE(n)=g2(Wx'*data)+g2(Wy'*data)+g2(Wz'*data);
                        valueEN(n)=valueE(n)-g2(Wx'*noiseData)+g2(Wy'*noiseData)+g2(Wz'*noiseData);
                        
                        %valueEN(n)=g2((Wx'+Wy'+Wz')*data);
                        %valueEN(n)=valueEN(n)-g2((Wx'+Wy'+Wz')*noiseData);
                        
                        %valueEN(n)=g2sum_plus(Wx'*data, 1200)+g2sum_plus(Wy'*data, 1200)+g2sum_plus(Wz'*data, 1200);
                        
                    end
                    
                    
                    
                    
                case 'type2'
                    for n=1:numberPos
                        
                    end
                    
                case 'type3'
                    for n=1:numberPos
                        
                    end
                    
                case 'type4'
                    
                    
                    
            end
            
            
            
        otherwise
            error('... sorry');
    end
end



















output=[];
output.pos=leadfield.pos;

output.value=value;
output.unscaledValue=value;
output.valueE=valueE;
output.valueEN=valueEN;

output.filtermethod=filtermethod;
output.analysismethod=analysismethod;
output.inside=ones(numberPos,1);

if strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')
    output.windowlength=windowlength;
end

if strcmp(keepCovarianceMatrix,'yes')
    cfg.covarianceMatrix=covariancematrix;
end

if waveform
    %  output.waveform=wave;
end

[val, ind]= max(value);
output.maximum=val;
output.index=ind;



output.oldcfg=cfg;



if timer
    output.timer=toc;
    display(strcat({'Computing time was '}, niceTime(output.timer)));
end

if plotOut
    %bplot_3d(output);
    bplot_inside(output);
    
    if waveform
        output.value=valueE;
        bplot_inside(output);
        output.value=valueEN;
        bplot_inside(output);
        
    end
    
end






































































end
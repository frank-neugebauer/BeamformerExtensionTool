function [ output ] = beamformer(cfg, dataOrig, leadfield)
% BEAMFORMER
%
% data is the (filtered, not avereaged) data
% leadfield is the struct containing the sourcepositions and appropriate
% leadfields, made with ft_prepare_leadfield
%
% cfg is a struct with
% cfg.filtermethod =  'unit_gain' default unit_noise_gain
%                     'unit_noise_gain'
%                     'unit_array_gain'
%                     'sam_robinson'
%
% cfg.analysismethod = 'variance' default g2
%                     'g2' excess kurtosis of the voxels
%                     'max_g2'
%                     'sum_g2'
%                     'none'  used to compute only the filters
%
%
% cfg.orimethod = max_pseudo_z default
%                 max_g2
%
% and can optionaly contain
%
% cfg.windowlength=x integer describing the length of the sliding window for
%                     the max_g2 and sum_g2 method. The shorter the window, the more frequent spikes are
%                     favoured, but the analysis gets more blurried. (default
%                     none)
%
% cfg.covarianceMatrix=C  contains the precomputed covariance matrix (default:
%                         none)
%
% cfg.covarianceMatrixInverse=CI contains the precomputed inverse covariance
%                                 matrix (default none)
%
% cfg.keepCovarianceMatrix='yes' or 'no'
%
%
% cfg.regparameter=a regularisation parameter for the filter computation
%                         (default=0). Can cause problems when cfg.covarianceMatrixInverse is precomputed.
%
%
% cfg.keepFilter='yes' or 'no' default: 'yes'







%configure the defaults

%   val = ft_getopt(s, key, default, emptymeaningful)
% where the input values are
%   s               = structure or cell-array
%   key             = string
%   default         = any valid MATLAB data type
%  emptymeaningful = boolean value (optional, default = 0)





output=[];
output.cfg=cfg;


filtermethod=ft_getopt(cfg, 'filtermethod', 'unit_noise_gain');
analysismethod=ft_getopt(cfg, 'analysismethod', 'variance');
orimethod=ft_getopt(cfg, 'orimethod', filtermethod);
oriNumber=ft_getopt(cfg, 'oriNumber', 20);
cfg.oriNumber=oriNumber; %for the orientation submethod

windowlength=ft_getopt(cfg,'windowlength','empty');
covariancematrix=ft_getopt(cfg,'covarianceMatrix','C');
covariancematrixI=ft_getopt(cfg,'covarianceMatrixInverse','CI');
regparameter=ft_getopt(cfg,'regparameter', 0);


keepFilter=ft_getopt(cfg,'keepFilter',1);
keepOrientation=ft_getopt(cfg,'keepOrientation',1);
keepInside=ft_getopt(cfg,'keepInside',0);



keepSourceSpace=ft_getopt(cfg, 'keepSourceSpace',1);
keepCovarianceMatrix=ft_getopt(cfg,'keepCovarianceMatrix',0);
timer=ft_getopt(cfg, 'timer', 'no');
plotOut=ft_getopt(cfg, 'plot', 0);
normalizeLeadfield=ft_getopt(cfg, 'normalizeLeadfield', 0);
ftoutputstyle=ft_getopt(cfg, 'outputstyle', 0); %0 for my default, 1 for fieldtrip


trial=ft_getopt(cfg, 'trial', 1);
avg=ft_getopt(cfg, 'avg', 1);

latency=ft_getopt(cfg, 'latency', 'all'); %in seconds
latencyInSeconds=ft_getopt(cfg, 'latencyInSeconds', true);








%see if data is in Fieldtrip-format or just a numeric array.
%FT data trial is converted to numeric array
if isnumeric(dataOrig)
    data=dataOrig;
    disp('numeric input. Data array is assumed');
else
    disp('Input data is not numeric. Assuming FieldTrip processed data');
    if isfield(dataOrig, 'avg') && avg
        data=dataOrig.avg;
        disp('Data is averaged. Using the avg data for analysis');
    else
        if isfield(dataOrig, 'trial') && isnumeric(trial)
            data=dataOrig.trial{trial};
            display(strcat('Using trial ', num2str(trial)));
        else
            error('bad luck. Please check again later for updates in our methods');
        end
    end
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




% If no windowlength is chosen for a method with one, error.
% If a windowlength is chosen for a method without window, warn.

if (strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2'))&&strcmp(windowlength,'empty')
    error('cfg.windowlength cannot be empty for chosen analysismethod')
end

if (~(strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')))&&~strcmp(windowlength,'empty')
    warning('windowlength is soecified but not considered for the chosen analysismethod. It will be ignored');
end


if ~strcmp(latency, 'all')
    if  latencyInSeconds %need to estimate the points in the array
        display('Using specific latency');
        tbeg = nearest(dataOrig.time, cfg.latency(1));  %TODO this gives an error when a trial is specified, or now when no trial is specified
        tend = nearest(dataOrig.time, cfg.latency(end));
        data=data(:, tbeg:tend);
    else
        data=data(:, latency(1):latency(2));
    end
end




%compute covariance matrix and its inverse, if not precomputed
% in case of non-adaptiv filtering, this is unnecessary
if strcmp(covariancematrix, 'C')
    %covariancematrix=cov(data');
    covariancematrix=1/size(data,2)*(data*data'); %not actual the covariancematrix, but what we want to use ¯\_(ツ)_/¯

    %     gramMatrix=cell2mat(leadfield.leadfield);
    %     gramMatrix=gramMatrix*gramMatrix';
    %     gramMatrixI=inv(gramMatrix);
else
    display('Using precimputed CovarianceMatrix');
end
    disp('covariance matrix condition is');
    disp(round(cond(covariancematrix)));

%regparameter=0;%regparameter*min(eig(covariancematrix));


if strcmp(covariancematrixI, 'CI')
    %regparameter=regparameter*min(eig(covariancematrix))
    covariancematrixI=inv(covariancematrix+regparameter*trace(covariancematrix)*eye(size(covariancematrix,1))/size(covariancematrix,1));
    %display('Using precomputed matrixInverse for the Covariancemarix');
end

cfg.covariancematrixI=covariancematrixI;


%compute orientations for every point
if ~strcmp(filtermethod,'given')
    ocfg=cfg;
    ocfg.leadfield=leadfield;
    ocfg.covariancematrix=covariancematrix;
    ocfg.orimethod=orimethod;
    orientation=beamformer_orientation(ocfg);
else
    display('using precomputed filter');
    orientation=[];
end
%compute filter for every point
numberPos=size(leadfield.pos,1);
filter=cell(numberPos,1);
switch filtermethod
    
    case 'unit_gain'
        for n=1:numberPos
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            filter{n}=covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO);
        end
        
    case 'unit_noise_gain'
        covariancematrixI2=covariancematrixI*covariancematrixI;
        for n=1:numberPos
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            filter{n}=covariancematrixI*leadfieldO/sqrt(leadfieldO'*covariancematrixI2*leadfieldO);
        end
        
    case 'unit_array_gain'
        for n=1:numberPos
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            normedLeadfield=leadfieldO/norm(leadfieldO);
            filter{n}=covariancematrixI*normedLeadfield/(normedLeadfield'*covariancematrixI*normedLeadfield);
        end
        
    case 'uag_adapt'
        for n=1:numberPos
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            normedLeadfield=leadfieldO/norm(leadfieldO);
            
            noisematrix=zeros(size(covariancematrix));
            for i=[1:n-1, n+1:numberPos]
                noisematrix=noisematrix+(leadfield.leadfield{i}*leadfield.leadfield{i}')/trace(leadfield.leadfield{i}'*covariancematrix*leadfield.leadfield{i});
            end
            noisematrix=noisematrix/(numberPos-1);
            noisematrixI=inv(noisematrix);
            
            filter{n}=noisematrixI*normedLeadfield/(normedLeadfield'*noisematrixI*normedLeadfield);
        end
        
    case 'lcmv'
        for n=1:numberPos
            filter{n}=covariancematrixI*leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
        end
        
    case 'sharp_unit_array_gain'
        for n=1:numberPos
                        oriOrth=null(orientation{n}');
            orientationMatrix=[orientation{n}, oriOrth];
            leadfieldO=leadfield.leadfield{n}*orientationMatrix;
           lf_norm=norm(leadfieldO(:,1));
 

            
            filter{n}=(covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO))*([lf_norm, 0, 0]');
        end
        
        case 'supp_unit_array_gain'
        for n=1:numberPos

            leadfieldS=[leadfield.leadfield{n}*orientation{n}, cfg.supp];
           lf_norm=norm(leadfield.leadfield{n}*orientation{n});
 

           filter{n}=(covariancematrixI*leadfieldS/(leadfieldS'*covariancematrixI*leadfieldS))*([lf_norm, zeros(1,size(cfg.supp,2))]');
        end
        
        
        case 'supp_unit_noise_gain'
        for n=1:numberPos

            leadfieldS=[leadfield.leadfield{n}*orientation{n}, cfg.supp];

           filter{n}=(covariancematrixI*leadfieldS/(leadfieldS'*covariancematrixI*leadfieldS))*([1, zeros(1,size(cfg.supp,2))]');
           filter{n}=filter{n}/norm(filter{n});
        end
        
    case 'unit_array_gain_vector'
        %lcmv normalized by the leadfieldnorm for each direction
        
        for n=1:numberPos
            filter{n}=covariancematrixI*leadfield.leadfield{n}/(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
            normMatrix=diag([norm(leadfield.leadfield{n}(:,1)),norm(leadfield.leadfield{n}(:,2)),norm(leadfield.leadfield{n}(:,3))]);
            filter{n}=filter{n}*normMatrix;
        end
        
    case 'unit_array_gain_vector2'
        %lcmv normalized by the leadfieldnorm in all directions
        for n=1:numberPos
            filter{n}=norm(leadfield.leadfield{n})*covariancematrixI*leadfield.leadfield{n}/(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
        end
        
        
    case 'unit_noise_gain_vector'
        covariancematrixI2=covariancematrixI*covariancematrixI;
        
        for n=1:numberPos
            gamma=inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n})*leadfield.leadfield{n}'*covariancematrixI2*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
            
            filter{n}=covariancematrixI*leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n})*diag(sqrt(diag(gamma).^-1));
        end
        
        
    case 'unit_noise_gain_vector_suppression'
        
        covariancematrixI2=covariancematrixI*covariancematrixI;
        L0=cfg.suppression;
        for n=1:numberPos
            leadV=[leadfield.leadfield{n}, L0];
            
            gamma=inv(leadV'*covariancematrixI*leadV)*leadV'*covariancematrixI2*leadV*inv(leadV'*covariancematrixI*leadV);
            
            filter{n}=covariancematrixI*leadV*pinv(leadV'*covariancematrixI*leadV)*diag(diag(gamma).^-1);
        end
        
    case 'minimum_norm'
        gramMatrix=cell2mat(leadfield.leadfield');
        gramMatrix=gramMatrix*gramMatrix';
        gramMatrixI=inv(gramMatrix+regparameter*trace(gramMatrix)*eye(size(gramMatrix,1))/size(gramMatrix,1));
        for n=1:numberPos
            filter{n}=gramMatrixI*leadfield.leadfield{n};
        end
        
        
    case 'sLORETA'
        gramMatrix=cell2mat(leadfield.leadfield');
        gramMatrix=gramMatrix*gramMatrix';
        gramMatrixI=inv(gramMatrix+regparameter*trace(gramMatrix)*eye(size(gramMatrix,1))/size(gramMatrix,1));
        for n=1:numberPos
            filter{n}=gramMatrixI*leadfield.leadfield{n}/sqrt(trace(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
        end
        
    case 'wnmn'
        gramMatrix=cell2mat(leadfield.leadfield');
        gramMatrix=gramMatrix*gramMatrix';
        gramMatrixI=inv(gramMatrix+regparameter*trace(gramMatrix)*eye(size(gramMatrix,1))/size(gramMatrix,1));
        for n=1:numberPos
            filter{n}=gramMatrixI*leadfield.leadfield{n}*inv(sqrt(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
        end
        
        
    case 'given'
        filter=cfg.filter;
        
    case 'given2'
        for n=1:numberPos
            filter{n}=cfg.filter{n}';
        end
        
    case 'givenOri'
         for n=1:numberPos
            filter{n}=cfg.filter{n}*orientation{n};
        end
        
       
    case 'gsc_reduced'
         for n=1:numberPos
             
            %
           W0=leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*leadfield.leadfield{n});
           % W0=covariancematrixI*leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
            lead_normal=null(leadfield.leadfield{n}');
             id=eye(size(W0, 1));
             
            filter{n}=(id-lead_normal*pinv(lead_normal'*covariancematrix*lead_normal)*lead_normal'*covariancematrix)*W0;
            filter{n}=filter{n}*diag([norm(leadfield.leadfield{n}(:,1)),norm(leadfield.leadfield{n}(:,2)),norm(leadfield.leadfield{n}(:,3))]);
         end
        
         case 'gsc_reduced_ung'
         for n=1:numberPos
             
            %
           W0=leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*leadfield.leadfield{n});
           % W0=covariancematrixI*leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
            lead_normal=null(leadfield.leadfield{n}');
             id=eye(size(W0, 1));
             
            filter{n}=(id-lead_normal*pinv(lead_normal'*covariancematrix*lead_normal)*lead_normal'*covariancematrix)*W0;
            filter{n}=filter{n}/norm(filter{n});
         end
         
    case 'projection'
        for n=1:numberPos
            filter{n}= leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*leadfield.leadfield{n});
        end
        
        
    case 'mi-single'
        
        
    case 'entropy'
        costf=@(W) entropyKernel(W'*data);
        opt = optimoptions('fmincon'); 
        opt.Display = 'none';
 
        
        
        for n=1:numberPos

            w1=fmincon(costf, pinv(leadfield.leadfield{n}(:,1))', [], [], (leadfield.leadfield{n})', [1, 0, 0], [],[],[], opt);
            w2=fmincon(costf, pinv(leadfield.leadfield{n}(:,2))', [], [], (leadfield.leadfield{n})', [0, 1, 0], [],[],[], opt);
            w3=fmincon(costf, pinv(leadfield.leadfield{n}(:,3))', [], [], (leadfield.leadfield{n})', [0, 0, 1], [],[],[], opt);
            
            filter{n}=horzcat(w1,w2,w3);
        end
            
        
    case 'entropyOri'
        costf=@(W) entropyNeighbour(W'*data);
        %costf=@(W) entropyKernel(W'*data);  
        %costf=@(W) 1/length(data)*(W'*(data*data')*W);
        %costf=@(W) entropy(W'*data);  

        opt = optimoptions('fmincon');
        opt.Display = 'none';
        
        
        numberOri=50;
        ori=distr_sphere(numberOri);
      %  orient=orient(orient(:,1)>=0, :);
       % orient=orient(orient(:,2)>=0, :);
        numberOri=length(ori);

      %  orient=cell(numberPos, 1);
        parfor n=1:numberPos

            w=cell(numberOri,1);
            ve=zeros(numberOri,1);
           % vv=ve;
            for i=1:numberOri
            %    [w{i}, ve(i)]=fmincon(costf, pinv(leadfield.leadfield{n}*orient(i,:)')'/norm(pinv(leadfield.leadfield{n}*orient(i,:)')'), [], [], (leadfield.leadfield{n}*orient(i,:)')', 1, [],[],@(W) mycon(W), opt);
           [w{i}, ve(i)]=fmincon(costf, pinv(leadfield.leadfield{n}*ori(i,:)')', [], [], (leadfield.leadfield{n}*ori(i,:)')', norm((leadfield.leadfield{n}*ori(i,:)')'), [],[],[], opt);
          %            [w{i}, ve(i)]=fmincon(costf, pinv(leadfield.leadfield{n}*orient(i,:)')', [], [], (leadfield.leadfield{n}*orient(i,:)')', 1, [],[],@(W) mycon(W), opt);
            %vv(i)=w{i}'*(data*data')*w{i};

            end
            
            [~,  in]=max(ve);
            filter{n}=w{in};
            orientation{n}=ori(in, :)'; %save direction for output
            
        end
        
       % orientation=orient;
        
        
        
        
        
        
    case 'test'
        %filt=@(W) (W'*covariancematrix*W);
        
       
        filt=@(W) (entropyNeighbour([], W'*data));
        
        
        
        
        gramMatrix=cell2mat(leadfield.leadfield');
        gramMatrix=gramMatrix*gramMatrix';
        gramMatrixI=inv(gramMatrix);
    
                for n=1:numberPos

        
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            normedLeadfield=leadfieldO/norm(leadfieldO);
            
         %   filter{n}=covariancematrixI*normedLeadfield/(normedLeadfield'*covariancematrixI*normedLeadfield);
        
        
       % filter{n}=fmincon(filt,gramMatrixI*normedLeadfield, [],[], normedLeadfield', 1);
           %     Wnum=fmincon(filt,filter{n}, [],[], normedLeadfield', 1);

           filter{n}=gramMatrixI*normedLeadfield;
           
                end
        
%                 
%     case 'entropy_vector'
%         
%         n=1;
%                 filt=@(W) (entropyKernel([], W'*data));
%              
%                 
%                 
%       normMatrix=diag([norm(leadfield.leadfield{n}(:,1)),norm(leadfield.leadfield{n}(:,2)),norm(leadfield.leadfield{n}(:,3))]);
% 
%         
%       filter{n}=fmincon(filt,leadfield.leadfield{n}'*pinv(leadfield.leadfield{n}*leadfield.leadfield{n}'), [],[],[], [], );
%                 
                
%     case 'mi2'
%         
%         n1=cfg.n1;
%         n2=cfg.n2;
%         
%         filt=@(W) 
%         
                
                
                
                
                
                
                
                
                

        
        
    case 'bayes'
        oriNumber=size(orientation, 1);
        pData=zeros(oriNumber,1);
        sigma2=zeros(oriNumber,1);
        p=zeros(oriNumber,1);
        y=zeros(oriNumber,1);
        w=cell(oriNumber,1);
        prob=cell(oriNumber, 1);
        
        
        %covariancematrixI2=covariancematrixI*covariancematrixI;
        % sigma2Noise=eig(covariancematrixI);%quantile(eig(covariancematrix), 0.25);
        % sigma2Noise=sigma2Noise(end);
        sigma2Noise=1;
        
        for n=1:numberPos
            
            for d=1:oriNumber
                
                oriOrth=null(orientation(d,:));
                orientationMatrix=[orientation(d,:)', oriOrth];
                leadfieldO=leadfield.leadfield{n}*orientationMatrix;
                lf_norm=norm(leadfieldO(:,1));
                
                w{d}=(covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO))*([lf_norm*signumVector(orientation(d,:)), 0, 0]');
                sigma2(d)=w{d}'*covariancematrix*w{d};
                
                
                
                
                
                %estimate the constant y and the probability
                %[N, T]=size(data); %N sensors T samples
                
                
                
                
                %  y(d)=N/sigma2Noise*(N*sigma2(d)/sigma2Noise)/(sigma2Noise*(1+N*sigma2(d)/sigma2Noise));
                %y(d)=1/(leadfieldO'*leadfieldO);
                
                y(d)=40;%40;%cfg.oriNumber;
                
                % p(d)=1/oriNumber; %uniformly distributed
                
                p(d)=cfg.probability{n}(d);
                
                
                
            end
            
            
            for d=1:oriNumber
                pData(d)=p(d)*exp(y(d)*sigma2(d)/median(sigma2));
            end
            
            
            
            
            
            
            %             for d=1:oriNumber
            %                 pData(d)=0;
            %                 for k=1:oriNumber
            %                     pData(d)=pData(d)+p(k)*exp(T*y(k)*sigma2(k)-T*y(d)*sigma2(d));  %when sigma is either very small or high, exp()=1 or exp=Inf
            %                 end
            %                 pData(d)=p(d)/pData(d);
            %             end
            %
            
            %estimate constant so pData*c is a probability
            c=0;
            for d=1:oriNumber
                c=c+pData(d);
            end
            pData=pData/c; %for pdata=c=Inf, this will give NaN
            
            
            
            
            filter{n}=pData(1)*w{1};
            for d=2:oriNumber
                filter{n}=filter{n}+pData(d)*w{d};
            end
            prob{n}=pData;
            
            [v, i]=max(sigma2);
            fil{n}=w{i};
            val{n}=v;
            
            
            bayesFilter{n}=w;
            
            if n==4
                disp('lets rock');
            end
            
        end
        output.prob=prob;
        
    case 'cost'
%         for n=1:numberPos
%         matrix=leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n};
%         
%         [eigenVector,eigenValue] = eig(matrix);
%         eigenValue=diag(eigenValue);
%         [minEigenValue, indexMinEigenValue]=min(eigenValue);
%         orientation{n}=eigenVector(:,indexMinEigenValue);
% 
%         end
        
         for n=1:numberPos
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            normedLeadfield=leadfieldO/norm(leadfieldO);
            W1=normedLeadfield/(normedLeadfield'*normedLeadfield);
            
            B=null(W1');
            
            %log(var(waveform))+2*(1+log(2*pi))-entropyKernel(waveform);
            
            costfun=@(W2) -negentropyN(W1'*data-W2'*B'*data);
            
           % mycon=@(W) [norm(W)-1, norm(W)-1];
            
           % W2=fmincon(costfun, ones(size(B,2), 1)/norm(ones(size(B,2),1)), [],[], [], [], [],[],  mycon);
            
            
            filter{n}=W1-B*W2;
            
            
            
        end
        
        
    case 'bayesian'
        oriNumber=size(orientation, 1);
        pApriori=zeros(oriNumber,1);
        angle=zeros(numberPos,1);
        pAposteriori=zeros(oriNumber,1);
        assumedVar=cfg.var;

        ori=cell(numberPos, 1);
        prob=cell(numberPos);
        
        oriPrior=cfg.oriPrior;
        
        %covariancematrixI2=covariancematrixI*covariancematrixI;
        % sigma2Noise=eig(covariancematrixI);%quantile(eig(covariancematrix), 0.25);
        % sigma2Noise=sigma2Noise(end);
        covariancematrixI2=covariancematrixI*covariancematrixI;
        
        for n=1:numberPos
            
       
            gamma=inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n})*leadfield.leadfield{n}'*covariancematrixI2*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
            
            filter{n}=covariancematrixI*leadfield.leadfield{n}*pinv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n})*diag(diag(gamma).^-1);
                waveform=filter{n}'*data;
                        v=1/size(waveform,2)*trace(waveform*waveform');

                
                
            for d=1:oriNumber
                theta = acosd(min(1,max(-1, oriPrior{n}(:)' * orientation(d,:)'/norm(oriPrior{n})/norm(orientation(d,:)) )));
                %pApriori(d)=1/(2*pi*assumedVar)*exp(-(theta/100)^2/(2*assumedVar)^2);
                
                pApriori(d)=1/oriNumber;
                
                pAposteriori(d)=1/size(waveform,2)*trace(orientation(d,:)*waveform*(orientation(d,:)*waveform)');
                pAposteriori(d)=exp((pAposteriori(d)/(v/2))^2); %add some constants, think about this
                pAposteriori(d)=pApriori(d)*pAposteriori(d);
            end
        
              c=0;
            for d=1:oriNumber
                c=c+pAposteriori(d);
            end
            pAposteriori=pAposteriori/c;
            prob{n}=pAposteriori;
            
            
            ori{n}=[0 0 0]';
            for d=1:oriNumber
                ori{n}=ori{n}+pAposteriori(d)*orientation(d,:)';
            end
            
            [~, oriIndex]=max(pAposteriori);
            ori{n}=orientation(oriIndex,:)';
            
            %ori{n}=ori{n}/norm(ori{n});
            
            theta = acosd(min(1,max(-1, oriPrior{n}(:)' * ori{n}/norm(oriPrior{n})/norm(ori{n}) )));
           % disp(theta);
            
            
            filter{n}=filter{n}*ori{n};
            
            filter{n}=filter{n}/norm(filter{n}); %reestablish the unit noise gain constrain

            
            angle(n)=theta;
            
        
        end
      %          output.prob=prob;
        output.oriDiff=angle;
        orientation=ori;
        
        
        
        
        case 'bayesian2'
        oriNumber=size(orientation, 1)+1;
        
        
        
        
        pApriori=zeros(oriNumber,1);
        angle=zeros(numberPos,1);
        pAposteriori=zeros(oriNumber,1);
        assumedVar=cfg.var;

        ori=cell(numberPos, 1);
      %  prob=cell(numberPos);
        
        oriPrior=cfg.oriPrior;
        
        %covariancematrixI2=covariancematrixI*covariancematrixI;
        % sigma2Noise=eig(covariancematrixI);%quantile(eig(covariancematrix), 0.25);
        % sigma2Noise=sigma2Noise(end);
        covariancematrixI2=covariancematrixI*covariancematrixI;
        orientation(end+1,:)=oriPrior{1};

        for n=1:numberPos
   
            orientation(end,:)=oriPrior{n};
            for d=1:oriNumber
                
                leadfieldO=leadfield.leadfield{n}*orientation(d,:)';
            filter{n}=covariancematrixI*leadfieldO/sqrt(leadfieldO'*covariancematrixI2*leadfieldO);
                
             waveform=filter{n}'*data;
                        v=1/size(waveform,2)*trace(waveform*waveform');

                angle=min(1,max(-1, oriPrior{n}(:)' * orientation(d,:)'/norm(oriPrior{n})/norm(orientation(d,:)) ));
                if abs(angle-1)<2*eps  %this helps for very small assumedVar to enforce the prior
                    angle=1;
                end
                
                theta = acosd(angle);
                pApriori(d)=1/(2*pi*assumedVar)*exp(-(theta/100)^2/(2*assumedVar)^2); %+eps so this is not NaN?
                
                %pApriori(d)=1/oriNumber;
                
                %pAposteriori(d)=1/size(waveform,2)*trace(orientation(d,:)*waveform*(orientation(d,:)*waveform)');
                %pAposteriori(d)=exp((pAposteriori(d)/(v/2))^2); %add some constants, think about this
                pAposteriori(d)=pApriori(d)*v;
            end
        
              c=0;
            for d=1:oriNumber
                c=c+pAposteriori(d);
            end
            pAposteriori=pAposteriori/c;
          %  prob{n}=pAposteriori;
            

          
%             ori{n}=[0 0 0]';
%             for d=1:oriNumber
%                 ori{n}=ori{n}+pAposteriori(d)*orientation(d,:)';
%             end
            
            [~, oriIndex]=max(pAposteriori);
            ori{n}=orientation(oriIndex,:)';
            
            %ori{n}=ori{n}/norm(ori{n});
            
            theta = acosd(min(1,max(-1, oriPrior{n}(:)' * ori{n}/norm(oriPrior{n})/norm(ori{n}) )));
           % disp(theta);
            
           
           leadfieldO=leadfield.leadfield{n}*ori{n};
            filter{n}=covariancematrixI*leadfieldO/sqrt(leadfieldO'*covariancematrixI2*leadfieldO);
           
            
%             filter{n}=filter{n}*ori{n};
%             
%             filter{n}=filter{n}/norm(filter{n}); %reestablish the unit noise gain constrain

            
            angleDiff(n)=theta;
            
        
        end
         %       output.prob=prob;
        output.oriDiff=angleDiff;
        orientation=ori;
        
        
    otherwise
        error('method is unknown');
end



%compute waveforms and the analysis-output for every point
value=zeros(numberPos,1);

%    retval=zeros(size(data,2), numberPos);



for n=1:numberPos
    %waveform=filter{n}'*data;
    switch analysismethod
        
        case 'variance'
            value(n)=trace(filter{n}'*covariancematrix*filter{n});
            
            if value(n)<0
                disp('variance is below 0');
            end
            
        case 'computed_variance'
            waveform=filter{n}'*data;
            %value(n)=var(waveform);
            value(n)=1/size(waveform,2)*trace(waveform*waveform');
            
        case 'computed_variance2'
            waveform=filter{n}'*data;
            waveform=waveform-mean(waveform);
            %value(n)=var(waveform);
            value(n)=1/size(waveform,2)*trace(waveform*waveform');
            
            
        case 'computed_variance_plus'
            waveform=filter{n}'*data;
            waveform=subplus(waveform);
            value(n)=1/size(waveform,2)*trace(waveform*waveform');
            
            
            
        case 'pca_computed_variance'
            waveform=filter{n}'*data;
            [~, waveform]=pca(waveform');
            waveform=waveform';
            waveform=waveform(1,:);
            value(n)=1/size(waveform,2)*trace(waveform*waveform');

            
            
            
        case 'bayes_variance'
            waveform=subplus((output.prob{n}(d)*bayesFilter{n}{d})'*data);
            
            for d=2:oriNumber
                waveform=subplus((output.prob{n}(d)*bayesFilter{n}{d})'*data);
            end
            value(n)=1/size(waveform,2)*trace(waveform'*waveform);
            
        case 'bayes_bestFilter'
                waveform=fil{n}'*data;
            %value(n)=var(waveform);
            value(n)=1/size(waveform,2)*trace(waveform'*waveform);
            
        case 'bayes_max'
            value(n)=val{n};
            
            
        case 'power'
            waveform=filter{n}'*data;
            
            value(n)=1/size(waveform,2)*trace(waveform*waveform');
            
        case 'g2'
            waveform=filter{n}'*data;
            value(n)=g2(waveform);
            
        case 'g2_3d'
            waveform=filter{n}'*data;
            value(n)=g2_3d(waveform);
            
            
        case 'max_g2'
            waveform=filter{n}'*data;
            value(n)=g2max(waveform, cfg.windowlength);
            
        case 'sum_g2'
            waveform=filter{n}'*data;
            value(n)=g2sum_plus(waveform, cfg.windowlength);
            
        case 'g2_win'
            waveform=filter{n}'*data;
            [value_g2sum(n), value_g2max(n)]= g2_win(waveform, windowlength);
            value=value_g2sum;
            
        case 'online_g2'
            waveform=filter{n}'*data;
            value(n)=online_kurtosis(waveform);
            
        case 'entropy'
            waveform=filter{n}'*data;
            value(n)=entropy(waveform*10^15);
            
        case 'negentropy'
            waveform=filter{n}'*data;
            waveform=waveform*10^15;
            
            value(n)=log(var(waveform))+2*(1+log(2*pi))-entropyKernel(waveform);

             case 'negentropyN'
            waveform=filter{n}'*data;
            waveform=waveform*10^15;
            
            value(n)=log(var(waveform))+2*(1+log(2*pi))-entropyNeighbour(waveform);

            
        case 'plus_entropy'
            waveform=(filter{n}(:,1)+filter{n}(:,2)+filter{n}(:,3))'*data;
            value(n)=entropy(waveform);
            
            
            
        case 'pca_entropy'
            waveform=filter{n}'*data;
            [~, waveform]=pca(waveform');
            waveform=waveform';
            waveform=waveform(1,:);
            value(n)=entropy(waveform*10^15);
            
            
        case 'explained_variance'
            waveform=filter{n}'*data;
            
             if n==1
                disp(max(waveform));
                disp(max(data));
                disp(max(leadfield.leadfield{n}));
            end
            
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            
            val1=rv(data, leadfieldO*waveform);
            val2=rv(data, -leadfieldO*waveform);

            value(n)=1-min(val1, val2);
            
            
        case 'scaled_residual_variance'
            waveform=filter{n}'*data;
            
           
            
            leadfieldO=leadfield.leadfield{n}*orientation{n};
            scale=max_matrix(data)/max_matrix(leadfieldO*waveform);
            value(n)=norm(scale*leadfieldO*waveform-data);
            
        case 'min_residual_variance'
            waveform=filter{n}'*data;
            
            for t=1:size(data, 2)
                retval(t,n) = sum((data(:,t)-leadfield.leadfield{n}*orientation{n}*waveform(t)).^2) ./ sum(data(:,t).^2);
            end
            value(n)=1-min(retval(:,n));
            
            
        case 'norm'
            value(n)=trace(filter{n}'*gramMatrix*filter{n});
            
            
        case 'all'
            waveform=filter{n}'*data;
            value_var(n)=trace(filter{n}'*covariancematrix*filter{n});
            value_g2(n)=g2(waveform);
            [value_g2sum(n), value_g2max(n)]= g2_win(waveform, windowlength);
            
        case 'none'
            if n==1
                disp('Does not apply a localizer. All output-power values are set to 0');
            end
            
            
        otherwise
            error('Analysismethod is unknown');
            
            
            
    end
end




%collect all data for the output
if ~ftoutputstyle
    
    if keepInside
        output.inside=leadfield.inside;
    end
    
    % if ~strcmp(analysismethod,'all')
    output.value=value;
    if exist('retval')
        output.retval=retval;
    end
    % else
    %     output.value_var=value_var;
    % end
    
    
    if keepFilter
        output.filter=filter;
    end
    output.filtermethod=filtermethod;
    output.analysismethod=analysismethod;
    
    if keepOrientation
        output.orientation=orientation;
    end
    
    if strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')
        output.windowlength=windowlength;
    end
    
    if keepCovarianceMatrix
        output.covarianceMatrix=covariancematrix;
    end
    
    if keepSourceSpace
        output.pos=leadfield.pos;
    end
    
    if timer
        output.timer=toc;
        display(strcat('Computing time was ', niceTime(output.timer)));
    end
    
    [val, ind]= max(value);
    output.maximum=val;
    output.index=ind;
    output.cfg=cfg;
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
        output.cfg=cfg;

    
end

if plotOut
    %bplot_3d(output);
    figure;
    bplot_sub(output);
    subplot(2,2,4);
    bplot_3d(output);
end

























































end


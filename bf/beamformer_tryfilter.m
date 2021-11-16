function [output ] = beamformer_tryfilter(cfg, data, leadfield)

%sammle Variablen ein

filtermethod=ft_getopt(cfg, 'filtermethod', 'unitgain');
analysismethod=ft_getopt(cfg, 'analysismethod', 'g2');
orimethod=ft_getopt(cfg, 'orimethod', 'max_pseudo_z');
windowlength=ft_getopt(cfg,'windowlength','empty');
covariancematrix=ft_getopt(cfg,'covarianceMatrix','C');
covariancematrixI=ft_getopt(cfg,'covarianceMatrixInverse','CI');
regparameter=ft_getopt(cfg,'regparameter', 0);
keepFilter=ft_getopt(cfg,'keepFilter','yes');
keepCovarianceMatrix=ft_getopt(cfg,'keepCovarianceMatrix','no');
timer=ft_getopt(cfg, 'timer', 'no');


% If no windowlength is chosen for a method with one, error.
% If a windowlength is chosen for a method without window, warn.
if timer
    'starting timer'
    tic;
end


if (strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2'))&&strcmp(windowlength,'empty')
    error('cfg.windowlength cannot be empty for chosen analysismethod')
end

if (~(strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')))&&~strcmp(windowlength,'empty')
    warning('windowlength is soecified but not considered for the chosen analysismethod. It will be ignored');
end

%compute covariance matrix and its inverse, if not precomputed
if strcmp(covariancematrix, 'C')
    covariancematrix=cov(data');
end

if strcmp(covariancematrixI, 'CI')
    covariancematrixI=inv(covariancematrix+regparameter*eye(size(covariancematrix,1)));
end


%für jede Position im Hirn
numberpos=size(leadfield.pos,1);
filter=cell(numberpos,1);
orientation=cell(numberpos,1);
value=zeros(numberpos,1);
for k=1:numberpos
    if leadfield.inside(k)
        
        sigma=1;
        point=kugelwinkel(1/4*sigma*randn,sigma*randn); %1/4 richtig?
        point=sphereToKart(1,point(1), point(2));
        leadfieldO=leadfield.leadfield{k}*point;
        filter{k}=covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO);
        
        v=g2(filter{k}'*data);
        steps=10;
        for j=2:steps
            snew=kugelwinkel(1/4*sigma*randn,sigma*randn);
            snew=kugelwinkel(snew(1),snew(2));
            snew=point+sphereToKart(1,snew(1), snew(2));
            leadfieldO=leadfield.leadfield{k}*snew;
            filterNew=covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO);
            
            vnew=g2(filter{k}'*data);
            if v>vnew
                point=snew;
                v=vnew;
                filter{k}=filterNew;
            end
            sigma=1-j/steps;
        end
        
        orientation{k}=point;
        value(k)=v;
        
        
        
        
        
    end
end


output=[];
output.pos=leadfield.pos;
output.inside=leadfield.inside;
output.value=value;
if strcmp(keepFilter,'yes')
    output.filter=filter;
end
output.filtermethod=filtermethod;
output.analysismethod=analysismethod;
output.orientation=orientation;

if strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')
    output.windowlength=windowlength;
end

if strcmp(keepCovarianceMatrix,'yes')
    cfg.covarianceMatrix=covariancematrix;
end


output.oldcfg=cfg;

if timer
    output.timer=toc;
        display(strcat({'Computing time was '}, niceTime(output.timer)));
end


end










































%
% switch filtermethod
%
%     case 'unit_gain'
%         for k=1:numberPos
%             if leadfield.inside(k)
%                 leadfieldO=leadfield.leadfield{k}*orientation{k};
%                 filter{k}=covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO);
%             end
%         end
%
%     case 'unit_noise_gain'
%         covariancematrixI2=inv(covariancematrixI);
%         for k=1:numberPos
%             if leadfield.inside(k)
%                 leadfieldO=leadfield.leadfield{k}*orientation{k};
%                 filter{k}=covariancematrixI*leadfieldO/sqrt(leadfieldO'*covariancematrixI2*leadfieldO);
%             end
%         end
%
%     case 'unit_array_gain'
%         for k=1:numberPos
%             if leadfield.inside(k)
%                 leadfieldO=leadfield.leadfield{k}*orientation{k};
%                 normedLeadfield=leadfieldO/norm(leadfieldO);
%                 filter{k}=covariancematrixI*normedLeadfield/(normedLeadfield'*covariancematrixI*normedLeadfield);
%             end
%         end
%
%     case 'lcmv'
%         error('not implemented yet');
%
%     otherwise
%         error('method is unknown');
% end
%
%




































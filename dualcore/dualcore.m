function [output] = dualcore(cfg, data, leadfield)


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

numberSeeds=ft_getopt(cfg, 'numberSeeds', 1);

leadfield.leadfield=leadfield.leadfield(leadfield.inside);
leadfield.pos=leadfield.pos(leadfield.inside,:);


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
if strcmp(covarianceMatrix, 'C')
    covarianceMatrix=cov(data');
else
    display('Using precomputed CovarianceMatrix');
end

if strcmp(noiseCovarianceMatrix, 'NC')
    noiseCovarianceMatrix=eye(size(covarianceMatrix));
    display('using white-Noise-CovarianceMatrix');
else
    display('Using precomputed NoiseCovarianceMatrix');
end



if strcmp(covarianceMatrixI, 'CI')
    covarianceMatrixI=inv(covarianceMatrix+regparameter*eye(size(covarianceMatrix,1)));
end

if strcmp(noiseCovarianceMatrixI, 'NCI')
    noiseCovarianceMatrixI=inv(covarianceMatrix+regparameter*eye(size(covarianceMatrix,1)));
end



numberPos=size(leadfield.leadfield,2);
%compute waveforms and the analysis-output for every point


taboo=ones(numberPos,1);



value=zeros(numberPos,1);

for seed=1:numberSeeds
    voxelFix=floor(1+numberPos*rand());
    
    while taboo(voxelFix)
        valueFix=zeros(numberPos,1);
        taboo(voxelFix)=0;
        for n=1:numberPos
            if n~=voxelFix
                leadFix=horzcat(leadfield.leadfield{voxelFix}/norm(leadfield.leadfield{voxelFix}), leadfield.leadfield{n}/norm(leadfield.leadfield{n}));
               
                 Kdual=pinv(leadFix'*covarianceMatrixI*leadFix)*(leadFix'*covarianceMatrixI*noiseCovarianceMatrix*covarianceMatrixI*leadFix);
                valueFix(n)=trace(Kdual);
%                 valueFix(n)=1/min(eig(Kdual));
                
                Wd=covarianceMatrixI*leadFix*pinv(leadFix'*covarianceMatrixI*leadFix);  %enhanced version
                %valueFix(n)=trace(Wd'*covarianceMatrix*Wd);
                dataFix=Wd'*data;
                valueFix(n)=g2(dataFix(1,:))+g2(dataFix(2,:))+g2(dataFix(3,:))+g2(dataFix(4,:))+g2(dataFix(5,:))+g2(dataFix(6,:));
                
%                 valueFix(n)=trace(pinv(leadFix'*covarianceMatrixI*leadFix))/trace(pinv(leadFix'*noiseCovarianceMatrixI*leadFix));
            end
        end
        
        [val, ind]=max(valueFix);
        value(voxelFix)=val;
        voxelFix=ind;
        
    end
    
    
    
    
end






output=[];
output.pos=leadfield.pos;
output.value=value;
output.filtermethod=filtermethod;
output.analysismethod=analysismethod;
output.inside=ones(numberPos,1);

if strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')
    output.windowlength=windowlength;
end

if strcmp(keepCovarianceMatrix,'yes')
    cfg.covarianceMatrix=covariancematrix;
end


output.oldcfg=cfg;
output.taboo=taboo;

if timer
    output.timer=toc;
        display(strcat({'Computing time was '}, niceTime(output.timer)));
end

if plotOut
    bplot_3d(output);
    bplot_inside(output);
end































end














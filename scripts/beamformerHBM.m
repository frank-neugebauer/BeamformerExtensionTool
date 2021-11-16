
function [ output ] = beamformerHBM(cfg, data, leadfield)
%uses a physiological constraint, but balances it with a
%normally distributed error
% Use brute force to find the best direction


filtermethod=ft_getopt(cfg, 'filtermethod', 'unit_array_gain');
analysismethod=ft_getopt(cfg, 'analysismethod', 'g2');
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

leadfield.leadfield=leadfield.leadfield(leadfield.inside);
leadfield.pos=leadfield.pos(leadfield.inside,:);



if timer
    tic;
end





    numberpos=size(leadfield.pos,1);

    orientation=cell(numberpos,1);






if ~isfield(cfg, 'phys_ori')
    error('No constraint given for constrained orientation method');
end
s=30; %set variance level. Should be determined by data later on ...

ocfg=cfg;
ocfg.leadfield=leadfield;
ocfg.covariancematrix=covariancematrix;
mori=beamformer_orientation(ocfg);



for n=1:numberpos
    
    oriphys=cfg.phy_orientation{n};
    value1=normpdf(0,0,s);
    filter=cfilter(cfg, leadfield, ori, n);
    valuephys=filter*covariancematrix*filter;
    
    
    
    ori2=mori{n};
    d=acosd(oriphys'/norm(oriphys)*ori2/norm(ori2));
    filter=cfilter(cfg, leadfield, ori2, n);
    value2=filter*covariancematrix*filter/valuephys*normpdf(d, 0, s);
    
    if value2>value1
        value1=value2;
        ori=ori2;
    end
    
    
    for k=1:300
        ori2=randn(3,1);
    d=acosd(oriphys'/norm(oriphys)*ori2/norm(ori2));
    filter=cfilter(cfg, leadfield, ori2, n);
    value2=filter*covariancematrix*filter/valuephys*normpdf(d, 0, s);
    
    if value2>value1
        value1=value2;
        ori=ori2;
    end
    
    end
    
    orientation{n}=ori;
    
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
        
    case 'lcmv'
        for n=1:numberPos
            filter{n}=covariancematrixI*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
        end
        
    case 'minimum_norm'
        for n=1:numberPos
            filter{n}=gramMatrixI*leadfield.leadfield{n};
        end
        
        
    case 'sLORETA'
        for n=1:numberPos
            filter{n}=gramMatrixI*leadfield.leadfield{n}/sqrt(trace(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
        end
        
    case 'wnmn'
        for n=1:numberPos
            filter{n}=gramMatrixI*leadfield.leadfield{n}*inv(sqrt(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
        end
        
        
    case 'given'
        filter=cfg.filter;
        
    case 'given2'
        for n=1:numberPos
            filter{n}=cfg.filter{n}';
        end
        
    otherwise
        error('method is unknown');
end



%compute waveforms and the analysis-output for every point
value=zeros(numberPos,1);
for n=1:numberPos
    %waveform=filter{n}'*data;
    switch analysismethod
        
        case 'variance'
            value(n)=trace(filter{n}'*covariancematrix*filter{n});
            
        case 'g2'
            waveform=filter{n}'*data;
            value(n)=g2(waveform);
            
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
            
            
        otherwise
            error('Analysismethod is unknown');
            
            
            
    end
end




%collect all data for the output
if ftoutputstyle
    output=[];
    output.pos=leadfield.pos;
    output.inside=leadfield.inside;
    
    
    % if ~strcmp(analysismethod,'all')
    output.value=value;
    % else
    %     output.value_var=value_var;
    % end
    
    
    if keepFilter
        output.filter=filter;
    end
    output.filtermethod=filtermethod;
    output.analysismethod=analysismethod;
    output.orientation=orientation;
    
    if strcmp(analysismethod,'max_g2') ||strcmp(analysismethod,'sum_g2')
        output.windowlength=windowlength;
    end
    
    if keepCovarianceMatrix
        output.covarianceMatrix=covariancematrix;
    end
    
    
    output.oldcfg=cfg;
    
    if timer
        output.timer=toc;
        display(strcat({'Computing time was '}, niceTime(output.timer)));
    end

    [val, ind]= max(value);
    output.maximum=val;
    output.index=ind;
    
else %fieldtripStyle
    %we need the output of ft_sourceanalysis and the beamformer output in
    %the avg fieldbeam
    
    output=[];
    
    output.method = 'average';
    
    output.inside=true(size(leadfield.pos));
    output.pos=leadfield.pos;
    output.cfg=cfg;
    
    
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










function [filter]= cfilter(cfg, leadfield, orientation, n)

covariancematrixI=inv(cfg.covariancematrix);

switch cfg.filtermethod
    
    case 'unit_gain'
        leadfieldO=leadfield.leadfield{n}*orientation;
        filter=covariancematrixI*leadfieldO/(leadfieldO'*covariancematrixI*leadfieldO);
        
    case 'unit_noise_gain'
        covariancematrixI2=covariancematrixI*covariancematrixI;
        leadfieldO=leadfield.leadfield{n}*orientation;
        filter=covariancematrixI*leadfieldO/sqrt(leadfieldO'*covariancematrixI2*leadfieldO);
        
        
    case 'unit_array_gain'
        leadfieldO=leadfield.leadfield{n}*orientation;
        normedLeadfield=leadfieldO/norm(leadfieldO);
        filter=covariancematrixI*normedLeadfield/(normedLeadfield'*covariancematrixI*normedLeadfield);
        
        
    case 'lcmv'
        filter=covariancematrixI*leadfield.leadfield{n}*inv(leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n});
        
        
    case 'minimum_norm'
        filter=gramMatrixI*leadfield.leadfield{n};
        
        
        
    case 'sLORETA'
        filter=gramMatrixI*leadfield.leadfield{n}/sqrt(trace(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
        
        
    case 'wnmn'
        filter=gramMatrixI*leadfield.leadfield{n}*inv(sqrt(leadfield.leadfield{n}'*gramMatrixI^2*leadfield.leadfield{n}));
        
    otherwise
        error('method is unknown');
end

end







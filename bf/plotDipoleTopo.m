function [] = plotDipoleTopo(dip, data, lead)

lf=lead.leadfield{dip.index};

[U,S,V]=svd(lf, 'econ');
    
        lf=lf*V(:, 1:2); %columns of V are the right singular vectors
        [U,S,V]=svd(lf, 'econ');
        
    

    lead.leadfield{dip.index}=lf;

data.avg=lead.leadfield{dip.index}*dip.orientation(dip.index,:)'*ones(size(data.time));





cfg = [];
cfg.xlim = [-0.015 -0.015];
%cfg.xlim = [0 0];
cfg.layout = 'CTF275.lay';
cfg.parameter = 'avg'; % the default 'avg' is not present in the data
figure; ft_topoplotER(cfg,data); colorbar




end


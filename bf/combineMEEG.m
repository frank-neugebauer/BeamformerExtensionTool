function [dataMEEG, leadMEEG] = combineMEEG(cfg, leadMEG, leadEEG, dataMEG, dataEEG)
%dataEEG and dataMEG should be data-arrays, the leadfields should come in
%fieldtrip format

% methods include:
%-'empirical_global normalisation'  see "Beamformer for simultaneous ...
%       magnetoencephalography and electroencephalography analysis",...
%       Ko, Seokha; Jun, Sung Chan
%
%-'noise*, see Improving source reconstructions by combining bioelectric and biomagnetic data
% Fuchs, Manfred, ... Buchner, Helmut
%
%
%
%
%'noise variance' needs 2 parameters, cfg.noiseE and cfg.noiseM NE*1 and NM*1 parameters for EEG
%channels and MEG channels




switch cfg.method
    
        
    case 'global_normalisation'
        par=cfg.parameter;

        normEEG=norm(dataEEG);
        vEEG=par*normEEG*ones(size(dataEEG,1),1);
        
        normMEG=norm(dataMEG);
        vMEG=normMEG*ones(size(dataMEG,1),1);
        
        vMEEG=vertcat(vEEG,vMEG);
        S=diag(vMEEG);

        
        
    case 'noise_par'
        vMEEG=vertcat(cfg.noiseM, cfg.noiseE);
        S=diag(vMEEG);
        
    case 'noise'
        cfg.method=cfg.noiseMethod;
        noiseM=estimate_noise(cfg, dataMEG).^-1;
        noiseE=estimate_noise(cfg, dataEEG).^-1;
        
        vMEEG=vertcat(noiseM, noiseE);
        S=diag(vMEEG);
        
        
    case 'nothing'
        S=1;
        vMEEG=1;

end



dataMEEG=S*vertcat(dataMEG, dataEEG);

leadMEEG=leadMEG;

for i=1:size(leadMEG.leadfield,1)
leadMEEG.leadfield{i}=S*vertcat(leadMEG.leadfield{i}, leadEEG.leadfield{i});
end

leadMEEG.label=vertcat(leadMEG.label, leadEEG.label);

leadMEEG.Scalecfg=cfg;
leadMEEG.scale=vMEEG;







end


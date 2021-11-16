
Contrast = (sourcepst.pow - sourcepre.pow)./sourcepre.pow*100 ;

addpath(genpath('/home/nasser/Desktop/linux_desktop/A1857/MRI'));
MRI = ft_read_mri('o20160912_150738t1mpragesagiso1mmwselnfp2s003a1001.nii');
MRI_segmented = ft_read_mri('mri_segmented_final_spm_seg3d_final.nii');

MRI.inside = false(size(MRI_segmented.anatomy));
MRI.inside(MRI_segmented.anatomy==5)=true;

cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
CONTRAST=[];
CONTRAST.pow = Contrast;
CONTRAST.pos = source_grid;
% CONTRAST.inside = true(size(source_grid, 1));
source_int  = ft_sourceinterpolate(cfg, CONTRAST, MRI);

cfg               = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';
cfg.location = 'center';
cfg.funcolormap = 'jet';
ft_sourceplot(cfg, source_int);

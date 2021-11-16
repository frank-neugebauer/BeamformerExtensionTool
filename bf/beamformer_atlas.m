function [] = beamformer_atlas(cfg, dataOrig, leadfield, atlas)
%beamformer_atlas performs a beamformer (see beamformer.m) algorithm specified in cfg
% in every region of the atlas, choosing a representative point for each
% region by the criterion specified in the cfg. 
%
% A fuzzy atlas will test if all points in a region show similar behaviour
% and will mark and/or move points to neighbouring regions. 
%
% Input variables are:
% dataOrig      data as data array or fieldtrip format
% leadfield     is the struct containing the sourcepositions and appropriate
%               leadfields, made with ft_prepare_leadfield
% atlas         is a fieldtrip atlas in the same coordinate system as the positions
%               in the leadfield
% cfg           struct with options, including
% 
% criterion ?
% outlier   ? 
% 
% includeUnknown 0 or 1, wether to include points that are not labeled in the
%               atlas (due to registration error, etc.)
%                default 1 (include)

% For options for the beamformer analysis, see beamformer.m
% 
% 

%% settings

if ~isfield(atlas, 'tissuelabel') %freesurfer atlas is named differently, correct this
    if isfield(atlas, 'aparclabel')
        atlas.tissuelabel=atlas.aparclabel;
        atlas.tissue=atlas.aparc;
        atlas=rmfield(atlas, 'aparc');
        atlas=rmfield(atlas, 'aparclevel');
    else
        error('Atlas.tissuelabel not found');
    end
end

if max(size(unique(atlas.tissue)))~=max(size(atlas.tissuelabel)) %regions start with 1, tissue can be 0
    atlas.tissuelabel=vertcat({'unkown'}, atlas.tissuelabel); 
    atlas.tissue=atlas.tissue+1;
end
    
includeUnknown=ft_getopt(cfg, 'includeUnknown',1);

    
numberRegions=max(size(atlas.tissuelabel));

%% atlas regions
%find nearest atlas points for the beamformer source space

s=atlas.dim;
[grid(:,1), grid(:,2), grid(:,3)] =ind2sub(s, 1:(s(1)*s(2)*s(3)));

IndexNextPoint=knnsearch(grid, leadfield.pos);
leadfield.pointLabel=atlas.tissuelabel(atlas.tissue(IndexNextPoint));
leadfield.tissue=atlas.tissue(IndexNextPoint);

%now every point in the leadfield has an atlas label


for region=(2-includeUnknown):numberRegions % 2 for registered regions, 1 to include unknown regions
    index=find((leadfield.tissue)==region);
    
    leadRegion=leadfield;
    leadRegion.pos=leadfield.pos(index,:);
    leadRegion.inside=leadfield.inside(index);
    leadRegion.leadfield=leadfield.leadfield(index);
    
    
    
    
    
    
    
    
end








































































end
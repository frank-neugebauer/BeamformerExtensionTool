function [nii omega m] = loadnii(file,volume)
% function [nii omega m] = loadnii(file,volume)
%
%created 2009-08-01 (lars)
%
% loads the nii struct
%
% INPUT : 
% file : absolute or relative filename 
% volume: just open a specific volume of a 4D dataset (default [])
%
% OUTPUT :
% nii struct 
if not(exist('volume','var'))
    volume = [];
end
[dir name ext] = fileparts(file);
bZipped = strcmp(ext,'.gz');
if bZipped
    %unzip file first
    gunzip(file)
    file = regexprep(file,'.gz','');
end
if not(exist(file,'file'))
    error(['Cannot find : ' file]);
end


nii = load_nii(file,volume,[],[],[],0,1);

if bZipped
    %unix(['gzip ' file]);
    gzip(file)
end
omega = [0 0 0;nii.hdr.dime.pixdim(2:4).*nii.hdr.dime.dim(2:4)]; omega = omega(:)';
m = nii.hdr.dime.dim(2:4);
end

function [ CTF ] = crossTalkFunction( filter, leadfield )
%crossTalkFuntion calculates the N_sources*N_sources cross talk function between different sources.
% filter:  (3)N_source*N_channel times filter or N_source*1 cell with
%           1*N_channel filter, or beamformer-structure
% leadfield: N_channel*3N_sources leadfield or cell or ft-leadfield struct




% check the format of the leadfield

%fieldtrip

if isstruct(leadfield)
    if isfield(leadfield, 'leadfield')
        leadfield=leadfield.leadfield;
    end
end

% is cell

if iscell(leadfield)
    leadfield=cell2mat(leadfield');
end

%should be a matrix
if ~ismatrix(leadfield)
    error('leadfield could not be resolved'); 
end


%repeat the same for the filter

if isstruct(filter)
    if isfield(filter, 'filter')
        filter=filter.filter;
    end
end

if iscell(filter)
    filter=cell2mat(filter');
end

if ~ismatrix(filter)
    error('filter could not be resolved'); 
end



CTF=filter'*leadfield;











end


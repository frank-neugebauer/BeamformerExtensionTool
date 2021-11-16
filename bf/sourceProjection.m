function [ source ] = sourceProjection(cfg, beam, dataArray)
%sourceProjection uses the beam.filter to project the data to the source
%domain.
% Cfg can include
% 
% filterIndex array, indeces of filters to use (default all)
% labels, cellarray of strings with names, default filter-index
% criterions, different options, not implemented yet %TODO
% 
% 
% 



source=[];

index=ft_getopt(cfg, 'filterIndex', 1:size(beam.filter,1));
if size(index,1)~=1
    index=index';
end

source.label=ft_getopt(cfg, 'label', cellstr(num2str(index'))); %works for 1:N index, but nor for (1:N)' ....




if max(size(index))~=max(size(source.label)) && min(size(index))~=1 && min(size(source.label))~=1  
    % avoid error due to transposition
    error('Index and label size do not match');
end

%source.trial=cell(size(index,2),1);

%write the trial in order, but without empty trials


j=1;
for i=index
    source.trial{1}(j,:)=beam.filter{i}'*dataArray; 
    j=j+1; 
end




source.time=ft_getopt(cfg, 'time', {1:size(dataArray,2)});

source.cfg=cfg;


source.fsample=ft_getopt(cfg, 'fsample', 1200);




end


function [curry] = beam2Curry(beam, grid, percentageOfPower)
%beam2Curry gives a table that can be copied into Curry8 as a pointcloud
%with strength

if nargin==2

s=size(beam.pos,1);

label=1:s;

curry=horzcat(label', grid, beam.value);

else
    index=find(beam.value>beam.max*percentageOfPower);
    beam.value=beam.value(index);
    grid=grid(index, :);
    curry=beam2curry(beam, grid);
end
    


end


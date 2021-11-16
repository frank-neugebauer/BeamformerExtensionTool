function [] = bplot_mark(beam, color)

if nargin==1
    color='red';
end

scatter3(beam.pos(beam.index, 1),beam.pos(beam.index, 2),beam.pos(beam.index, 3),10000, '*', color);



end


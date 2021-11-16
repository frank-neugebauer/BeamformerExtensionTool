function [map] = colorScale(color1, color2, numberOfSteps)
%colorScale gives a rgb-colormap scaling from color1 to color2 in
%numberOfSteps steps
step=(color2-color1)/numberOfSteps;

map=color1;
for i=1:numberOfSteps
    map=vertcat(map, color1+step*i);
end

end


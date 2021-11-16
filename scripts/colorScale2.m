function [ map ] = colorScale2( color1, color2, color3, numberOfSteps)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here


map1=colorScale(color1, color2, ceil(numberOfSteps/2));
map2=colorScale(color2, color3, ceil(numberOfSteps/2));

map=vertcat(map1, map2(2:end,:));














end
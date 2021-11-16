function [] = bplot_3d( beamout )


%figure;

x=beamout.pos(:,1);
y=beamout.pos(:,2);
z=beamout.pos(:,3);
werte=beamout.value;



scatter3(x,y,z,40,werte, '.');







end


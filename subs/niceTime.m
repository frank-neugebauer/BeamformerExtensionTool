function [out] = niceTime(time )

hours=floor(time/3600);
time=time-hours*3600;
minu=floor(time/60);
time=floor(time-minu*60);

out=strcat(num2str(hours), ' hours, ',num2str(minu), ' min, ' ,num2str(time), ' sec ' );



end



%wert=squeeze(mean(samWert(:,:)));
ind=find(beamout_sum.inside);
wert=beamout_sum.value(ind);
%wert=samg2Wert(8,:);
%wert=squeeze(mean(samMaxWert(:,1,:)));
%wert=squeeze(mean(samSum3Wert(:,4,:)));

%wert=zeros(8694,1);
%wert(4227)=1;

name=strcat('g23N6');

r2=1;


if ~exist('gb')
    warning('keine Koordinaten. Berechne sie selbst')
    sortGitter;
end

pixg=100;
close all;
grb=size(gb,2);
wb=zeros(grb,1);
x=wb;
y=wb;
for i=1:grb
    wb(i)=max(wert(gb{i}));
    k=g5(gb{i},1);
    x(i)=k(1);
     k=g5(gb{i},2);
    y(i)=k(1);
end

figure;


scatter(x,y,pixg,wb,'filled');
title('View from above');
hold on;
%scatter(dipLoc(1,1), dipLoc(1,2),100,'red','filled','v');

% r=1/norm(dipMom(1,1:2))*r2;
% %scatter(dipLoc(3,1), dipLoc(3,2),100,'red','filled','v');
% qb=quiver(dipLoc(1,1)-r*dipMom(1,1), dipLoc(1,2)-r*dipMom(1,2), r*dipMom(1,1),r*dipMom(1,2),0,'red');
% qb.MaxHeadSize=3000;
% %vekplot2(dipLoc(1,1)-r*dipMom(1,1), dipLoc(1,2)-r*dipMom(1,2), r*dipMom(1,1),r*dipMom(1,2),1,'red');
% 
% 
% r=1/norm(dipMom(3,1:2))*r2;
% qb3=quiver(dipLoc(3,1)-r*dipMom(3,1), dipLoc(3,2)-r*dipMom(3,2), r*dipMom(3,1),r*dipMom(3,2),0,'magenta');
%  qb3.MaxHeadSize=3000;
% xlabel('Position in mm')
% ylabel('Position in mm')




figure; 

grc=size(gc,2);
wc=zeros(grc,1);
x=wc;
y=wc;
for i=1:grc
    wc(i)=max(wert(gc{i}));
    k=g5(gc{i},1);
    x(i)=k(1);
     k=g5(gc{i},3);
    y(i)=k(1);
end

scatter(x,y,pixg,wc,'filled');
title('View from the front');
hold on;

% r=1/norm(dipMom(1,[1,3]))*r2;
% qc=quiver(dipLoc(1,1)-r*dipMom(1,1), dipLoc(1,3)-r*dipMom(1,3), r*dipMom(1,1),r*dipMom(1,3),0,'red');
% qc.MaxHeadSize=3000;
% 
% r=1/norm(dipMom(3,[1,3]))*r2;
% qb3=quiver(dipLoc(3,1)-r*dipMom(3,1), dipLoc(3,3)-r*dipMom(3,3), r*dipMom(3,1),r*dipMom(3,3),0,'magenta');
% qb3.MaxHeadSize=3000;
% 

xlabel('Position in mm')
ylabel('Position in mm')



gra=size(ga,2);
wa=zeros(gra,1);
x=wa;
y=wa;
for i=1:gra
    wa(i)=max(wert(ga{i}));
    k=g5(ga{i},2);
    x(i)=k(1);
     k=g5(ga{i},3);
    y(i)=k(1);
end


figure; 
scatter(x,y,pixg,wa,'filled');
title('View from side');
hold on;
% r=1/norm(dipMom(1,2:3))*r2;
% qa=quiver(dipLoc(1,2)-r*dipMom(1,2), dipLoc(1,3)-r*dipMom(1,3), r*dipMom(1,2),r*dipMom(1,3),0,'red');
% qa.MaxHeadSize=3000;
% 
% r=1/norm(dipMom(3,2:3))*r2;
%qb3=quiver(dipLoc(3,2)-r*dipMom(3,2), dipLoc(3,3)-r*dipMom(3,3), r*dipMom(3,2),r*dipMom(3,3),0,'magenta');
%qb3.MaxHeadSize=3000;

xlabel('Position in mm')
ylabel('Position in mm')


saveas(gcf,name,'epsc')




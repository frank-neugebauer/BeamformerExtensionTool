
num=size(beamMEG.filter,1);
%plotdata=zeros(num, 1);
col=[1 0 0];

figure;
for n=1:size(peakMEG,2)
    
for i=1:num
beamMEG.value(i)=beamMEG.filter{i}'*avgdataMEG.avg(:,peakMEG(n))/beamPre.value(i);
end

bplot_sub(beamMEG);
pause(0.3);
subplot(2,2,4);
plot(avgdataMEG.time, avgdataMEG.avg);
hold on;
plot(peakMEGinData(n), peakstrMEG(n), '*', 'color', 'black');
plot(peakMEGinData(n), -peakstrMEG(n), '*', 'color', 'black');
hold off;


    c=col+[0 n/size(dipscan,2) n/size(dipscan,2)];
    %c=col;

    %c=col*n/size(dipscan,2);
    
    subplot(2,2,1);
    hold on;
    scatter(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(1), 50, c, 'filled' );
    text(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(1), num2str(n));
    subplot(2,2,2);
    hold on;
    scatter(-dipscan{n}.dip.pos(1), dipscan{n}.dip.pos(3), 50,c, 'filled');
    text(-dipscan{n}.dip.pos(1), dipscan{n}.dip.pos(3), num2str(n));
    
    subplot(2,2,3);
    hold on;
    scatter(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(3), 50,c,'filled');
    text(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(3), num2str(n));



drawnow;








end













































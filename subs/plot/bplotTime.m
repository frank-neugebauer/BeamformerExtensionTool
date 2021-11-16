function [] = bplotTime(cfg, beam, data)


dataArray=data.avg;

dipscan=ft_getopt(cfg, 'dipscan', []);
scale=ft_getopt(cfg,'scale', ones(size(beam.value)));
interactive=ft_getopt(cfg, 'interactive', 'no');

plotTimes=ft_getopt(cfg, 'plotTimes', [1 size(data, 2)]);
pauseTime=ft_getopt(cfg, 'pauseTime', 0);

plot3d=ft_getopt(cfg, 'plot3d', 0);
power=ft_getopt(cfg, 'power', 2);
color=ft_getopt(cfg, 'colormap', 'parula');
method=ft_getopt(cfg, 'method', 'var');

peak=ft_getopt(cfg,'peak', plotTimes);
peakstr=ft_getopt(cfg,'peakstr', ones(size(peak)));




num=size(beam.filter,1);
%plotdata=zeros(num, 1);

col=[1 0 0];

value=zeros(num, size(peak,2));
for n=1:size(peak,2)
    
    for i=1:num
        if strcmp(method, 'var')
        value(i,n)=trace((beam.filter{i}'*dataArray(:,peak(n)))*dataArray(:,peak(n))'*beam.filter{i})/scale(i);
        end
        
        if strcmp(method,'gof')
            t=peak(n);
            waveform=beam.filter{i}'*dataArray(:,:);
            sensorWave=cfg.leadfield.leadfield{i}*beam.orientation{i}*waveform(t);
        value(i,n) = 1- rv(dataArray(:,t), sensorWave);
       
        end
         
        
    end
end
 %cmax=max_matrix(value);
    %cmin=-max_matrix(-value);
% cmin=cmax/3;




beam.value=value(:,1);
bplot_sub(beam);


 subplot(2,2,1);
    colormap(color);
 subplot(2,2,2);
        colormap(color);

 subplot(2,2,3);
    colormap(color);





for n=1:size(peak,2)
    
    if pauseTime
        pause(pauseTime);
    end
    
    if strcmp(interactive, 'yes')
        
        disp('Interactive mode activated. Press t to go to the next time point. Press n to stop interactive mode');
        
        while(true)
            w = waitforbuttonpress;
            if w==1
                key = get(gcf,'currentcharacter');
                if strcmp(key, 't')
                    break;
                else
                    if strcmp(key, 'n')
                        interactive='no';
                        break;
                    end
                end
            end
        end
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
beam.value=value(:,n);
    
bplot_sub(beam);


%rescale the colors

 subplot(2,2,1);
    caxis([min(beam.value), max(beam.value)]);
   % colormap(color);
 subplot(2,2,2);
    caxis([min(beam.value), max(beam.value)]);
       % colormap(color);

 subplot(2,2,3);
    caxis([min(beam.value), max(beam.value)]);
    %colormap(color);







    








if ~isempty(dipscan)
    c=col+[0 n/size(dipscan,2) n/size(dipscan,2)];
    %c=col;

    %c=col*n/size(dipscan,2);
    
    subplot(2,2,1);
    hold on;
    scatter(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(1), 50, c, 'filled' );
    caxis([min(beam.value), max(beam.value)]);
    text(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(1), num2str(n));
    
    subplot(2,2,2);
    hold on;
    scatter(-dipscan{n}.dip.pos(1), dipscan{n}.dip.pos(3), 50,c, 'filled');
    caxis([min(beam.value), max(beam.value)]);
    text(-dipscan{n}.dip.pos(1), dipscan{n}.dip.pos(3), num2str(n));
    
    subplot(2,2,3);
    hold on;
    scatter(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(3), 50,c,'filled');
    caxis([min(beam.value), max(beam.value)]);
    text(-dipscan{n}.dip.pos(2), dipscan{n}.dip.pos(3), num2str(n));
end


    subplot(2,2,4);
     
    
    
    %plot(data.time(cfg.peak(1):cfg.peak(end)), dataArray(:,cfg.peak(1):cfg.peak(end))');
    plot(data.time(plotTimes(1):plotTimes(2)), dataArray(:,plotTimes(1):plotTimes(2)));
    
    %xaxis(data.time);
   hold on;
    %plot(data.time(peak(n)), peakstr(n), '*', 'color', 'black');
    %plot(data.time(peak(n)), -peakstr(n), '*', 'color', 'black');
    
    line([data.time(peak(n)), data.time(peak(n))], [peakstr(n), -peakstr(n)], 'color', 'black');
    
    hold off;
    
    
    if plot3d
        bplot_3d(beam);
        caxis([min(beam.value), max(beam.value)]);
    end
    
    
    
    
    title(data.time(peak(n)));
    
    
    
    
    
    
drawnow;


































end


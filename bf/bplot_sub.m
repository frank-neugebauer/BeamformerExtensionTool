function [] = bplot_sub(beamout)
% plots the output of the beamformer(.) or beamformer_tryfilter(.) function

%wert=samg2Wert(8,:);
%wert=squeeze(mean(samMaxWert(:,1,:)));
%wert=squeeze(mean(samSum3Wert(:,4,:)));

%wert=zeros(8694,1);
%wert(4227)=1;






g5=beamout.pos;
 j=1;
 werte=unique(g5(:,1));
 
 for k=1:max(size(werte)) %f�r jeden Wert
     ia{j}=[];
     for m=1:max(size(g5),1) %f�r jeden Wert in der x-Spalte
         if g5(m,1)==werte(k)
             ia{j}=horzcat(ia{j},m);
         end
         
     end
     j=j+1;
     
 end


 gb{1}=[];
 j=1;
 for i=1:size(ia,2) %f�r alle verschiedene x-werte
     
     %sortiere die y-Werte
     werte=unique(g5(ia{i},2));
     
     for k=1:max(size(werte)) %f�r jeden Wert
         gb{j}=[];
         for m=1:max(size(g5(ia{i},2))) %f�r jeden Wert in der y-Spalte
             if g5(ia{i}(m),2)==werte(k)
                 gb{j}=horzcat(gb{j}, ia{i}(m));
             end
             
         end
         j=j+1;
         
     end
 end
    
 gc{1}=[];
 j=1;
for i=1:size(ia,2) %f�r alle verschiedene x-werte
    
   %sortiere die z-Werte
    werte=unique(g5(ia{i},3)); 
    
    for k=1:max(size(werte)) %f�r jeden Wert
        gc{j}=[];
        for m=1:max(size(g5(ia{i},3))) %f�r jeden Wert in der z-Spalte
        if g5(ia{i}(m),3)==werte(k)
            gc{j}=horzcat(gc{j}, ia{i}(m));
        end
        
        end
        j=j+1;
        
    end
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 j=1;
 werte=unique(g5(:,2));
 
 for k=1:max(size(werte)) %f�r jeden Wert
     ib{j}=[];
     for m=1:max(size(g5),2) %f�r jeden Wert in der x-Spalte
         if g5(m,2)==werte(k)
             ib{j}=horzcat(ib{j},m);
         end
         
     end
     j=j+1;
     
 end


 ga{1}=[];
 j=1;
for i=1:size(ib,2) %f�r alle verschiedene y-werte
    
   %sortiere die z-Werte
    werte=unique(g5(ib{i},3)); 
    
    for k=1:max(size(werte)) %f�r jeden Wert
        ga{j}=[];
        for m=1:max(size(g5(ib{i},3))) %f�r jeden Wert in der z-Spalte
        if g5(ib{i}(m),3)==werte(k)
            ga{j}=horzcat(ga{j}, ib{i}(m));
        end
        
        end
        j=j+1;
        
    end
end


























set(gcf, 'name', strcat('Plot of ', inputname(1)));



sign='s';


%figure;



pixg=20;
grb=size(gb,2);
wb=zeros(grb,1);
x=wb;
y=wb;
for i=1:grb
    wb(i)=max(beamout.value(gb{i}));
    k=g5(gb{i},1);
    x(i)=k(1);
     k=g5(gb{i},2);
    y(i)=k(1);
end


subplot(2,2,1);
%scatter(-y,x,pixg,wb,sign, 'filled');

scatter(y,x,pixg,wb,sign, 'filled');

%title('View from above');
%hold on;





subplot(2,2,2);

grc=size(gc,2);
wc=zeros(grc,1);
x=wc;
y=wc;
for i=1:grc
    wc(i)=max(beamout.value(gc{i}));
    k=g5(gc{i},1);
    x(i)=k(1);
     k=g5(gc{i},3);
    y(i)=k(1);
end

%scatter(-x,y,pixg,wc,sign, 'filled');
scatter(x,y,pixg,wc,sign, 'filled');


%title('View from the side');
%hold on;

xlabel('Position in mm')
ylabel('Position in mm')



gra=size(ga,2);
wa=zeros(gra,1);
x=wa;
y=wa;
for i=1:gra
    wa(i)=max(beamout.value(ga{i}));
    k=g5(ga{i},2);
    x(i)=k(1);
     k=g5(ga{i},3);
    y(i)=k(1);
end


subplot(2,2,3);

%scatter(-x,y,pixg,wa,sign, 'filled');

scatter(x,y,pixg,wa,sign, 'filled');


%title('View from the back');
%hold on;
xlabel('Position in mm')
ylabel('Position in mm')


subplot(2,2,4);
%plot( beam.filter{beam.index}'*avgdata.avg);
bplot_3d(beamout)

end


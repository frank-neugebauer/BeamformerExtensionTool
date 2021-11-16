
g5=beamout.pos;

g5=g5(find(beamout.inside),:);


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













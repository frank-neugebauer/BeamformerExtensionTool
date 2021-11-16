
% 
% Hi Frank,
% 
% Das ist der Code, den ich jetzt zum Transformieren der ft-coils nehme, um die richtige Orientierung zu haben (ich lesen den header für die coilpos/ori, dann rechne ich die Koordinatentransformation zu Marios/Curry-Daten aus und transformiere die ft-Koordinaten dahin, sodass die Orientierungen richtig bleiben.
% 
% Vielleicht kannst du den Code auch gebrauchen:
% ______________________________________________________________________________________
%% check and transform meg coil orientation from Curry (somehow about half of the coil orientations are flipped)

nr_chans =271; %read from header?

%% load curry sensors
%coilpos_curry = loaddata(filename_coilpos_curry);
%coilori_curry = loaddata(filename_coilori_curry);

curryImport;

%%

%get ft header and extract coil positions from there
header_ft = ft_read_header(dataset,'headerformat', 'ctf_ds');
grad_ft = ft_convert_units(header_ft.grad, 'mm');
tra_ft = header_ft.grad.tra(1:nr_chans,:); % cut rows for reference channels (not relevant)

%select only coils that have a nonzero column in the transformation matrix
[~, idx_relevant_coils] = find(sum(tra_ft~=0,1)~=0);
coilpos_ft = grad_ft.coilpos(idx_relevant_coils,:);
coilori_ft = grad_ft.coilori(idx_relevant_coils,:);

%only use inner layer (in case reference coils vary)
coilpos_curry271 = coilpos_curry(1:271,:);
coilpos_ft271 = coilpos_ft(1:271,:);

%find out rotation matrix from meg coils and rotate eeg sensors
[R,t] = rigid_transform_3D(coilpos_ft271, coilpos_curry271);


%transform ft coils to mesh coordinate system

for i=1:size(coilpos_ft,1)
  coilpos_ft_trafo(i,:) = (R *coilpos_ft(i,:)') + t;
  coilori_ft_trafo(i,:) = (R *coilori_ft(i,:)');
end


%% plot to control
hFig = figure();
axh = axes('Parent', hFig);
hold(axh, 'all');
%h1 = scatter3(coilpos_ft(:,1), coilpos_ft(:,2), coilpos_ft(:,3), 'red', '.');
%quiver3(coilpos_ft(:,1), coilpos_ft(:,2), coilpos_ft(:,3), coilori_ft(:,1), coilori_ft(:,2), coilori_ft(:,3), 'red');
h2 = scatter3(coilpos_ft_trafo(:,1), coilpos_ft_trafo(:,2), coilpos_ft_trafo(:,3), 'green', '.');
quiver3(coilpos_ft_trafo(:,1), coilpos_ft_trafo(:,2), coilpos_ft_trafo(:,3), coilori_ft_trafo(:,1), coilori_ft_trafo(:,2), coilori_ft_trafo(:,3), 'green');
h3 = scatter3(coilpos_curry(:,1), coilpos_curry(:,2), coilpos_curry(:,3), 'black');
quiver3(coilpos_curry(:,1), coilpos_curry(:,2), coilpos_curry(:,3), coilori_curry(:,1), coilori_curry(:,2), coilori_curry(:,3), 'black');

%legend(axh, [h1,h2, h3], {'ft_orig', 'ft_transformed', 'curry'});



%%


for i=1:555
    
    if norm(coilpos_ft_trafo(i,:)-coilpos_curry(i,:))<0.1
       if norm(coilori_curry(i,:)-coilori_ft_trafo(i,:))>0.1 && ...
               norm(coilori_curry(i,:)+coilori_ft_trafo(i,:))<0.1
           disp(i);
           coilori_ft_trafo(i,:)=-coilori_ft_trafo(i,:);
           Lm(i,:)=-Lm(i,:);
           
       end
    end
end


%%


index=[];
for i=1:555
    
    if norm(coilpos_ft_trafo(i,:)-coilpos_curry(i,:))>0.1
           disp(i);
           
           for j=547:555
               if norm(coilpos_ft_trafo(j,:)-coilpos_curry(i,:))<0.1
                   index(end+1)=j;
               end
           end
           
           
           
           
           
           
           
           
           
       
    end
end

%disp(index);







































function [ cov_new ] = recipsiicos(cov, lead)


Gp=[];

for i=1:length(lead.leadfield)
    
%     Gp=horzcat(Gp, [...
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{i}(:,1)'),...
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{i}(:,2)'+lead.leadfield{i}(:,2)*lead.leadfield{i}(:,1)'), ...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{i}(:,2)') ...  
%         
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{i}(:,3)'+lead.leadfield{i}(:,3)*lead.leadfield{i}(:,1)'), ...
%         vectorize(lead.leadfield{i}(:,3)*lead.leadfield{i}(:,3)'), ...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{i}(:,3)'+lead.leadfield{i}(:,3)*lead.leadfield{i}(:,2)'), ... 
%         ]);

    
    Gp=horzcat(Gp, vectorize(lead.leadfield{i}*lead.leadfield{i}'));
    
    
    
end

[u, d, ~]=svd(Gp);



k=size(u,2);



P=u(:,1:k)*u(:,1:k)';


 %% whitened recipsiicos, one orientation

% %1
% Gcor=[];
% 
% for i=1:length(lead.leadfield)
%     for j=i:length(lead.leadfield)
%     Gcor=horzcat(Gcor, [...
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{j}(:,1)')+vectorize(lead.leadfield{j}(:,1)*lead.leadfield{i}(:,1)'), ... 
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{j}(:,2)')+vectorize(lead.leadfield{j}(:,2)*lead.leadfield{i}(:,1)'),...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{j}(:,1)')+vectorize(lead.leadfield{j}(:,1)*lead.leadfield{i}(:,2)'),...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{j}(:,2)')+vectorize(lead.leadfield{j}(:,2)*lead.leadfield{i}(:,2)'), ...    
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{j}(:,3)')+vectorize(lead.leadfield{j}(:,3)*lead.leadfield{i}(:,1)'),...
%         vectorize(lead.leadfield{i}(:,3)*lead.leadfield{j}(:,1)')+vectorize(lead.leadfield{j}(:,1)*lead.leadfield{i}(:,3)'),...
%         vectorize(lead.leadfield{i}(:,3)*lead.leadfield{j}(:,3)')+vectorize(lead.leadfield{j}(:,3)*lead.leadfield{i}(:,3)'),...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{j}(:,3)')+vectorize(lead.leadfield{j}(:,3)*lead.leadfield{i}(:,2)'),...
%         vectorize(lead.leadfield{i}(:,3)*lead.leadfield{j}(:,2)')+vectorize(lead.leadfield{j}(:,2)*lead.leadfield{i}(:,3)'),...
% ]);
%     end
% end
% 
% Ccor=Gcor*Gcor';
% 
% %2
% Gpwr=[];
% 
% for i=1:length(lead.leadfield)
%     
%     %Gpwr=horzcat(Gpwr, vectorize(lead.leadfield{i}*lead.leadfield{i}'));
%     Gpwr=horzcat(Gpwr, [...
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{i}(:,1)'),...
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{i}(:,2)'+lead.leadfield{i}(:,2)*lead.leadfield{i}(:,1)'), ...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{i}(:,2)') ...        
%         vectorize(lead.leadfield{i}(:,1)*lead.leadfield{i}(:,3)'+lead.leadfield{i}(:,3)*lead.leadfield{i}(:,1)'), ...
%         vectorize(lead.leadfield{i}(:,3)*lead.leadfield{i}(:,3)'), ...
%         vectorize(lead.leadfield{i}(:,2)*lead.leadfield{i}(:,3)'+lead.leadfield{i}(:,3)*lead.leadfield{i}(:,2)'), ... 
%         ]);
% end
% 
% Cpwr=Gpwr*Gpwr';
% 
% [Epwr, Apwr]=eig(Cpwr);
% 
% Apwr=diag((abs(diag(Apwr))).^(-1/2));
% 
% Wpwr=Epwr*Apwr*Epwr';
% 
% Ccorw=Wpwr*Ccor*Wpwr';
% 
% [Ecor, ~]=eig(Ccorw);
% 
% 
% 
% 
% Ek=Ecor*Ecor'; %implement k
% 
% P=inv(Wpwr)*(eye(size(Ek))-Ek)*Wpwr;
% 



%%




cov2=P*vectorize(cov);

cov2=devectorize(cov2, size(cov));


[V, D]=eig(cov2);

cov_new=V*abs(D)*V';

































end












function [mvec] = vectorize(m)

[z,s]=size(m);

mvec=zeros(z*s,1);

for i=1:s
    mvec(1+(i-1)*z:z*i)=m(:, i);
    
end
end



function [m] = devectorize(mvec, zs)


m=zeros(zs);
z=zs(1);
s=zs(2);


for i=1:s
    m(:, i)=mvec(1+(i-1)*z:z*i);
    
end


end


















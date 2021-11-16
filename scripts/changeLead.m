function [out] = changeLead(lead)
%CHANGELEAD changes a sens*(3*pos) matrix into a sens*3*pos matrix

sens=size(lead, 1);
pos3=size(lead, 2);

out=zeros(sens, 3, pos3/3);

index=1:3:pos3;
out(:,1,:)=lead(:,index);
index=index+1;
out(:,2,:)=lead(:,index);
index=index+1;
out(:,3,:)=lead(:,index);







end


function [Leadfield] = readLf(Matrix)
%erstellt aus einer Punkte*3 x Sensor+1 Matrix eine Leadfieldmatrix
%Sensor*3*Punkte Matrix H

Ma=Matrix';
Ma=Ma(2:end,:); %Sensor x Punkte*3
Leadfield=zeros(size(Ma,1),3,size(Ma, 2)/3);


anz=size(Ma, 2)/3;
n=0;
while n<anz
    Leadfield(:,1,n+1)=Ma(:,3*n+1);
    Leadfield(:,2,n+1)=Ma(:,3*n+2);
    Leadfield(:,3,n+1)=Ma(:,3*n+3);
    n=n+1;
end


end
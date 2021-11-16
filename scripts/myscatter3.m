function [] = myscatter3(array,symbol, color)

if nargin==2
   % color='b';
    scatter3(array(:,1), array(:,2), array(:,3), symbol);
end

if nargin==1
   % symbol='*'; 
   % color='b';
    scatter3(array(:,1), array(:,2), array(:,3));

end

if nargin==3
%array is N*3 vector

scatter3(array(:,1), array(:,2), array(:,3), symbol, color);

end






end


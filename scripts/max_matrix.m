function [value, row, column] = max_matrix(matrix)
%searches the maximum in a 2 dim matrix

[value, row]=max(matrix);
[value, column]=max(value);

row=row(column);
end



% function [value, index] = max_matrix(matrix)
% 
% if   size(size(matrix))==2
%     
%     if size(matrix,1)==1
%     [value, index]= max(matrix);
%     else if     








































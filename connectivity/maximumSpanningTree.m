function [adj] = maximumSpanningTree(matrix)

% Calculates the adjacency matrix of the maximumSpanningTree from the
% adjacency matrix of a graph.
%
%The maximum spanning tree is an unweighted connected graph with the highest weighted
%edges of the original graph that do not form a loop.
% If the edges have different weights, it is unique. 
% If the tree is not unique, matlab will give the solution with the lowest
% indices (which may not be optimal in that case)

% matrix is a N*N symmetric matrix, diagonal elements are ignored.
% adj is a N*N symmetric matrix

%Algorithm from Kruskal

matrix=triu(matrix,1);

N=size(matrix,1);
trees=1:N;
adj=zeros(N,N);


n=1;
while n<N
    
    [~, x,y]=max_matrix(matrix);  %gives row and column of maximal element
    matrix(x,y)=0;
    if trees(x)~=trees(y)   %if they do not belong to the same tree, they cannot form a loop
        adj(x, y)=1;
        n=n+1;
        yv=trees(y);
        xv=trees(x);
        for ind=1:N  % x and y now belong to the same tree
            if trees(ind)==yv
                trees(ind)=xv;
            end
        end
    end
    
end

adj=adj+adj'; %adj is upper triangular matrix but should be symmetric


end


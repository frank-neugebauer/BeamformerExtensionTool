close all
N=20;
 adj=rand(N,N);
 adj=triu(adj,1)+triu(adj,1)';
 G=graph(adj);

mst=maximumSpanningTree(triu(adj));
%mst=mst+triu(mst)';
mstG=graph(mst);

figure;
hh=plot(G);
highlight(hh,mstG,'EdgeColor','r','LineWidth',1.5)




figure;
h=plot(mstG);
bet=centrality(mstG, 'betweenness');
h.NodeCData=bet;
colorbar;






































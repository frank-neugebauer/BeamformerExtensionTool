function [lead] = grid2fieldtrip(grid, leadfield)


[S D N]=size(leadfield);

for n=1:N
    lead.leadfield{n}=leadfield(:,:,n);
    lead.pos=grid;
end
lead.inside=true(N,1);

lead.leadfield=lead.leadfield';
lead.leadfielddimord='{pos}_chan_ori';

%lead.pos=lead.pos-min(lead.pos)+[1, 1, 1]; %normalize the positions into a grid, starting at one, needed for coregistration




end


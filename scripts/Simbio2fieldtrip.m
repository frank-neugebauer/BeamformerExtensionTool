function [leadfield] = Simbio2fieldtrip(nameOfLeadfield, sourceGrid)
% reads a simbio-leadfield matrix and converts it to a fieldtrip-like
% format.

% Before using the code:
% Delete the lines before the numbers at the beginning of the document and
% at the end after the labels
% and change ': ' to \tab.
% Thank you.


leadfield=dlmread(nameOfLeadfield);
leadfield=readLf(leadfield);
leadfield=grid2fieldtrip(sourceGrid, leadfield);

end


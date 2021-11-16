function [elec] = readElec(nameOfData)

%reads the elec-structure out of combined ctf-MEG-EEG data and
% constructs the (usually missing) elec-structure for leadfield computation etc.


hdr=ft_read_header(nameOfData);
eeg=hdr.orig.eeg; %eeg is a 1xNumberOfSensors (NoS) struct with chanNum, name, pos.
% this 1xN struct gives strange results when called, so we convert it to a
% cell array

eegCell=struct2cell(eeg); %this is now a chanNum, Name, Pos 3x1xNoS

pos=squeeze(eegCell(3,1,:)); %pos is now a NoSx1 cell Array, but needs to be a 3xNoS array
pos = cat(2,pos{:});
pos=pos'; % now finally a NoS*3 array
pos=pos.*10; % pos is in 'cm', but should be in 'mm';



label=squeeze(eegCell(2,1,:));  %both are now NoSx1 cell arrays


chantype=cell(80,1);
chanunit=cell(80,1);
for i=1:size(label,1)
    chantype{i}='eeg';
    chanunit{i}='V';
end

% now collect the data for the output, the order of items is important

elec.chanpos=pos;
elec.chantype=chantype;
elec.chanunit=chanunit;
elec.elecpos=pos;
elec.label=label;
elec.unit='mm';


end


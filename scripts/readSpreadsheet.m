%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /data2/neugebauer/Matlab/P0857/BadChannels_01.xlsx
%    Worksheet: Sheet1
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2018/02/28 10:04:50

%% Import the data
[~, ~, raw] = xlsread('/data2/neugebauer/Matlab/P0857/BadChannels_01.xlsx','Sheet1');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);

%% Allocate imported array to column variable names
F4 = cellVectors(:,1);

%% Clear temporary variables
clearvars raw cellVectors;
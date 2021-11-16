%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /data2/neugebauer/Matlab/P0857/SimBio/SensorsbyCurry_02.xlsx
%    Worksheet: Sheet1
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2019/11/22 09:40:58

%% Import the data
[~, ~, raw] = xlsread('/data2/neugebauer/Matlab/P0857/SimBio/SensorsbyCurry_02.xlsx','Sheet1');
raw = raw(:,13:15);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
SensorsbyCurry02 = table;

%% Allocate imported array to column variable names
SensorsbyCurry02.VarName13 = data(:,1);
SensorsbyCurry02.VarName14 = data(:,2);
SensorsbyCurry02.VarName15 = data(:,3);

%% Clear temporary variables
clearvars data raw;

coilpos_curry=table2array(SensorsbyCurry02);

%% Import the data
[~, ~, raw] = xlsread('/data2/neugebauer/Matlab/P0857/SimBio/SensorsbyCurry_02.xlsx','Sheet1');
raw = raw(:,17:19);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
SensorsbyCurry02 = table;

%% Allocate imported array to column variable names
SensorsbyCurry02.VarName17 = data(:,1);
SensorsbyCurry02.VarName18 = data(:,2);
SensorsbyCurry02.VarName19 = data(:,3);

%% Clear temporary variables
clearvars data raw;


coilori_curry=table2array(SensorsbyCurry02);

clearvars SensorsbyCurry02;




























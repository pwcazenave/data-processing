% Do a quick analysis of the Avonmouth tidal data to compare against the
% results from TAPPy.

matlabrc
close all
clc

% base = checkos;
base = '/users/modellers/pica/Work/';

% Add the latest t_tide toolbox
addpath('/users/modellers/pica/Work/MATLAB/toolboxes/t_tide_v1.3beta/');

infile = [base, 'data/NTSLF/formatted/AVO.txt'];

fid = fopen(infile, 'r');
data = textscan(fid, '%4d %02d %02d %02d %02d %02d %.4f %.4f %s');
fclose(fid);

% Use only the last year's worth of data
elevations = data{7}(end-35040:end);
% Use only the last 20 years' data
% nSteps = 18*365*24*4;
% elevations = data{7}(end-nSteps:end);

% Use t_tide to do the analysis
[tidestruct, xout] = t_tide(elevations(elevations~=-99),'interval',double(data{5}(end)-data{5}(end-1))/60,'start time',double([data{1}(1),data{2}(1),data{3}(1),data{4}(1),data{5}(1),data{6}(1)]));
% [tidestruct, xout] = t_tide(elevations(elevations~=-99),'interval',double(data{5}(end)-data{5}(end-1))/60);
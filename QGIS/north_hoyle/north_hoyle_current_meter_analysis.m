% Do a quick kmeans cluster analysis to get the tidal axes for the stations
% Tara wanted for the North Hoyle wind farm site.

matlabrc
close all
clc

% base = checkos;
base = '/users/modellers/pica/Work/';

% Load the meta data for the selected sites
fid = fopen('./selected_current_meter_series.csv');
metadata = textscan(fid, '%s %s %s %s %s %s %s %s %s %s', 'Delimiter', ',');
fclose(fid);

strippedMetadata = metadata{2}(2:end);
numFiles = size(strippedMetadata,1);

outDirs = nan(numFiles,3);

for i = 1:numFiles
    % load this file
    fid = fopen(fullfile(base, '/data/BODC/currents/', regexprep(char(metadata{2}(i+1)), 'cmd\', 'formatted/')));
    data = textscan(fid, '%s %s %s %s %s %s %s');
    % Clean the data a bit (remove NaNs and so on)
    cleanedData = data{4};
    nIndex = find(ismember(cleanedData, '-1.0000N')==1);
    cleanedData(nIndex) = [];
    % Hackish way to convert to doubles
    matCleanedData = nan(size(cleanedData, 1),1);
    for j = 1:size(cleanedData, 1)
        matCleanedData(j) = str2double(cell2mat(cleanedData(j)));
    end
    [idx, c] = kmeans(matCleanedData, 2, 'Replicates', 5);
    outDirs(i,1:2) = sort(c);
    % Do some simple stats
    outDirs(i,3) = outDirs(i,2) - outDirs(i,1); % Difference between the two results
end

% Print some results
% fprintf('Sites with differences ~180 degrees:\n')
% strippedMetadata(outDirs(:,3)>90)

%% Plot of the tidal axis
close all

figure(1)
plot(mean([outDirs(outDirs(:,3)>90,1), outDirs(outDirs(:,3)>90,2)-180],2), 'k')
hold on
plot(outDirs(outDirs(:,3)>90,1), '.')
plot(outDirs(outDirs(:,3)>90,2)-180, 'r.')
xlabel('Site')
ylabel('Tidal axis (\circ)')
title('Observed tidal axes for the sites near the North Hoyle wind farm')

% Save the output
imgDir = './plots/';
print(gcf,'-dpdf','-r600',fullfile(imgDir, 'north_hoyle_current_meter_analysis.pdf'));

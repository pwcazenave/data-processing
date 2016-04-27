% Convert Blanpain's sediment distribution map from a tiff into an array of
% the median grain size values calculated in blanpain_2007_sediment_characteristics.ods

% 2011-10-21 Fixed the bad d50 values from the original spreadsheet
% (blanpain_2007_sediment_characteristics.xls) and updated with
% gradistat.xls data instead.

clear
close all

filename = '/users/modellers/pica/Desktop/BGS Report, single column layout_p60_posterised_cleaned_polygons.png';
A = imread(filename,'png');

nx = size(A,2)-1;
ny = size(A,1)-1;
west = -5.8;
east = 2;
south = 48.25;
north = 51.5;
rangeX = east-west;
rangeY = north-south;
x = west:rangeX/nx:east;
y = south:rangeY/ny:north;
[X,Y] = meshgrid(x,y);

Agrey = rgb2gray(A);
Anew = double(Agrey);

greyReps = [36,111,63,119,88,147,172,138,196,180,178,225,255];
% Equivalent d50s (mm?).
%           Mud M                       0.01391
%           Muddy Sand Ms               ?
%           Sandy Mud sM                0.04567
%           Gravelly muddy sand gmS     0.2871
%           Gravelly mud gM             ?
%           Gravelly sand gS            0.31886
%           Sand S                      0.12825
%           Gravel G                    0.74491

sedsReps = [0.74491, 20,5.7672,11.8517,11.3163,5.1654,8.1094,1.1232,0.4220,0.3118,0.1720,0.1374,0.09061,100];

% My original values and the new values
% Class:            d50 (gradistat):
% Coarse Gravel A   5.7672
% Coarse Gravel B   11.8517
% Gravel A          11.3163
% Gravel B          5.1654
% Sand A            8.1094
% Sand B            1.1232
% Sand C            0.04110
% Sand D            0.3118
% Sand E            0.1720
% Silt A            0.1374
% Silt B            0.0961
% Thus, the gradistat ones are typically an order of magnitude larger.

for i = 1:size(greyReps,2)
    Anew(Anew == greyReps(i)) = sedsReps(i);
end
Anew(Anew>25) = NaN;

%% Let's have a look-see...
close all
imshow(Agrey); shading flat; axis equal; axis tight
figure; pcolor(X,flipud(Y),(Anew)); shading flat; axis equal; axis tight; colorbar; %caxis([0 20])

%% Export to CSV
outdir = '/users/modellers/pica/Desktop/';
filename = 'bgs_b50.xyz';

savecsv(filename,[X(:),flipud(Y(:)),Anew(:)],outdir)

% we only want non-nan data
% Can't get this to work properly. Need to manually grep out the NaNs.
% Xnew = X(isfinite(Anew));
% Ynew = Y(isfinite(Anew));
% Anew2 = Anew(isfinite(Anew));
% savecsv(filename,[fliplr(Xnew),flipud(Ynew),Anew2],outdir)


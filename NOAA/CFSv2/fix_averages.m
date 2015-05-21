% Convert from n-hour averages to hourly averages.

files = {'dswsfc.gdas.199002.nc', 'prate.gdas.199002.nc', ...
    'q2m.gdas.199002.nc', 'uswsfc.gdas.199002.nc', ...
    'dlwsfc.gdas.199002.nc', 'pressfc.gdas.199002.nc', ...
    'tmp2m.gdas.199002.nc', 'wnd10m.gdas.199002.nc'};

keys.dlwsfc = 'DLWRF_surface';
keys.dswsfc = 'DSWRF_surface';
keys.uswsfc = 'USWRF_surface';
keys.prate = 'PRATE_surface';
keys.pres = 'PRES_surface';
keys.q2m = 'SPFH_2maboveground';
keys.wnd = {'UGRD_10maboveground', 'VGRD_10maboveground'};

for f = 1:length(files)
    var = regexp(files{f}, '\.', 'split');
    var = var{1};
    name = keys.(var);
    
    data = ncread(files{f}, name);
    % Copy so we don't have to fill gaps every 6th point or for the last
    % point.
    fixed = data;
    
    [nx, ny, nt] = size(data);
    
    for t = 1:6:nt
        % Fix the next 5 hours of data. Assume 0th hour is just the
        % original data - since the formula multiplies by the n-1 hour, if
        % we want the first hour's worth of data, then the second term in
        % the formula with multiply by zero, so the formula is essentially
        % only using the first term, which is just the data at n (i.e. 0).
        for n = 1:5
            if t + n <= nt
                fixed(:, :, t + n) = (n * data(:, :, t + n)) - ((n - 1) * data(:, :, t + n - 1));
            end
        end
    end
end

clf
plot(squeeze(data(100, 100, :)), '.-')
hold on
plot(squeeze(fixed(100, 100, :)), 'r.-')
legend('n-hour average', 'hourly average')
legend('BoxOff')
% files = dir('data/gs_full_tile/input/*.nc');
files = dir('/Users/ropa5718/Desktop/VSCode/ls_scag_vs_spires/data/p042r034_corrected.nc');

asdasdads 

for i=1:length(files)
    file = files(i);
    date_tile = split(file.name, '_');
    date = date_tile{1};
    tile = date_tile{2}(1:6);
    fp = strcat('data/gs_full_tile/input/', file.name);
    
    % Read in data
    mu0 = double(ncread(fp,'stc_solar_zenith'));
    phi0 = double(ncread(fp,'stc_solar_azimuth'));
    S = double(ncread(fp,'slope'));
    A = double(ncread(fp,'aspect'));
    spires_gs = double(ncread(fp,'spires_gs'));
    spires_dust = double(ncread(fp,'spires_dust'));
    mcd19_gs = double(ncread(fp,'mcd19_gs'));
    elevation = double(ncread(fp,'elevation'));
    % Permute arrays - python/matlab compatibility
    mu0 = permute(mu0, [2 1]);
    phi0 = permute(phi0, [2 1]);
    S = permute(S, [2 1]);
    A = permute(A, [2 1]);
    spires_gs = permute(spires_gs, [2 1]);
    spires_dust = permute(spires_dust, [2 1]);
    mcd19_gs = permute(mcd19_gs, [2 1]);
    elevation = permute(elevation, [2 1]);
    % Set NaN
    mu0(mu0==-2147483648) = NaN;
    phi0(phi0==-2147483648) = NaN;
    spires_gs(spires_gs==65535) = NaN;
    spires_gs(spires_gs==-2147483648) = NaN;
    spires_gs(spires_gs<-9e18) = NaN;
    spires_dust(spires_dust==65535) = NaN;
    mcd19_gs(mcd19_gs<0) = NaN;
    % Prepare variables
    mu0 = cosd(mu0);
    phi0 = 180. - phi0;
    phi0(phi0 > 180) = phi0(phi0 > 180) - 360;
    spires_dust = spires_dust/1e6;
    spires_dust = spires_dust/10;
    mcd19_gs = mcd19_gs*1000;
    % Calculations
    sun = sunslope(mu0, phi0, S, A);
    albedo_spires = AlbedoLookup(spires_gs, mu0, sun, elevation, LAPname='dust', LAPconc=spires_dust);
    albedo_mcd19 = AlbedoLookup(mcd19_gs, mu0, sun, elevation);
    
    save(strcat('data/gs_full_tile/output/',date,'_',tile,'.mat'),'albedo_spires','albedo_mcd19')
end
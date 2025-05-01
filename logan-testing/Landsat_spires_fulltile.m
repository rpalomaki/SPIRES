%example script for running SPIReS with Landsat 8 

% Bair, E.H., Stillinger, T., and Dozier, J. (2021) 
% Snow Property Inversion from Remote Sensing (SPIReS), 
% IEEE Transactions on Remote Sensing and Geoscience, 
% doi: 10.1109/TGRS.2020.3040328

%unzip example files
% unzip('L8example.zip')
addpath(genpath([pwd]))

% RTP - setup i/o directories
lstdir = '/pl/active/rittger_ops/landsat/lc08_l2sp_02_t1';
spires_dir = '/scratch/alpine/lost1845/SPIRES';
pr = 'p068r014';

%files
r0dir=fullfile(lstdir, pr, 'spires', 'ancillary', 'R0'); %snow/ice minima background, p42r34 20201014
%rdir=fullfile(pwd,'R'); %snow covered scene, p42r34 20160426
demfile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_dem.mat')); % DEM for p42r34 - extraneous 
%if terrain correction set to false & el_cutoff = 0 m
Ffile=fullfile(lstdir,'data','Ffile','lut_oli_b1to7_3um_dust.mat'); % look up tables
%Mie-RT calcs for snow for L8 bands 1-7 w/ 3 um dust
CCfile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_cc.mat')); % canopy cover percent file, NLCD
WaterMaskfile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_watermask.mat')); %watermask file, NLCD
CloudMaskfile=fullfile(lstdir, pr, 'spires', 'ancillary','cloudmask',strcat(pr,'_cloudmask.mat')); %RTP added
fIcefile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_fice.mat')); %fractional ice, derived from
%Randolph Glacier Inventory

%parameters
shade=0; % ideal shade endmember, fraction 0-1
tolval=0.05; % tolerance value for uniquetol for grouping spectra, fraction 0-1, Ned's value=0.05
fsca_thresh=0.10; %minimum fsca value, fraction 0-1
dust_rg_thresh=300; %minimum dirty snow grain size, um
grain_thresh=0.90; %RTP added from function description
dust_thresh=0.90; %RTP added from function description
el_cutoff=0; %minimum elevation for snow, m, in this case 0 m ignores
%subset=[1052 3032; 1471 3529]; %bounding box in pixel coordinates for subset 
% of scene 
subset=[]; %RTP added - select full tile

% RTP - loop through date dirs for a given pr
% get the folder contents
d = dir(fullfile(lstdir, pr, 'L2'));
dates = d([d(:).isdir]);
dates = dates(~ismember({dates(:).name},{'.','..'}));


% test_r0 = georasterinfo('R0/p042r034/LC08_L2SP_042034_20201014_20201105_02_T1_SR_B1.TIF');
% test_r = georasterinfo('R/p042r034/20230209/LC08_L2SP_042034_20230209_20230217_02_T1_SR_B1.TIF');

%% run spires on one scene
rdir=fullfile(dates(1).folder, dates(1).name);
disp(rdir)
  
%takes 2.09 min running w/ 50 cores
out=run_spires_landsat(r0dir,rdir,demfile,Ffile,shade,tolval,...
    fsca_thresh,dust_rg_thresh,grain_thresh,dust_thresh,CCfile,...
    WaterMaskfile,CloudMaskfile,fIcefile,...
    el_cutoff,subset,false);

%save spires out
spires_filename = fullfile(spires_dir, pr, dates(1).name, 'spires_out.mat');
save(spires_filename, 'out', '-v7.3')

%% loop through all scenes
%for i=1:length(dates)
%
%    rdir=fullfile(dates(i).folder, dates(i).name);
%    disp(rdir)
%  
%    %takes 2.09 min running w/ 50 cores
%    out=run_spires_landsat(r0dir,rdir,demfile,Ffile,shade,tolval,...
%        fsca_thresh,dust_rg_thresh,grain_thresh,dust_thresh,CCfile,...
%        WaterMaskfile,CloudMaskfile,fIcefile,...
%       el_cutoff,subset,false);
%
%    fsca = out.fsca;
%    fsca_raw = out.fsca_raw;
%    dust = out.dust;
%    grainradius = out.grainradius;
%
%    out_dir = strcat('data/output/',pr,'/',dates(i).name);
%    if not(isfolder(fullfile(pwd,out_dir)))
%        mkdir(fullfile(pwd,out_dir));
%        addpath(fullfile(pwd, out_dir));
%    end
%    % save data
%    out_file = fullfile(pwd,out_dir,strcat(pr,'_',dates(i).name, '_spires_out.mat'));
%    save(out_file, "fsca", "fsca_raw", "dust", "grainradius");
%end



%%
% Albedo lookup after base spires output is saved
%pr = 'p042r034';

%spires_dir = '/scratch/alpine/lost1845/SPIRES/20180508';


% save dem
dem_fn = fullfile(spires_dir, pr, dates(1).name, 'dem.tif');
geotiffwrite(dem_fn, dem.Z, dem.hdr.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');

% save grain radius tif
gr_fn = fullfile(spires_dir, pr, dates(1).name, "grainradius_out.tif");
geotiffwrite(gr_fn, out.grainradius, out.hdr.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');

% save r_b1 tif
r_b1_fn = fullfile(spires_dir, pr, dates(1).name, "r_b1_out.tif");
geotiffwrite(r_b1_fn, out.R(:, :,1), out.hdr.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');


% save dust tif
dust_fn = fullfile(spires_dir, pr, dates(1).name, "dust_out.tif");
geotiffwrite(dust_fn, out.dust, out.hdr.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');


%% reproject sza and saa
spires_dir_sa = fullfile(spires_dir, pr, dates(1).name);
load(spires_filename);
demhdr = out.hdr;
r_bands = out.R;

% reproject sza
sza = getOLIsa(spires_dir_sa, r0dir, r_bands, demhdr, 'SZA');
save(fullfile(spires_dir_sa, "sza_out.mat"), "sza");
%sza = sza.bands;
% save sza tif
sza_fn = fullfile(spires_dir_sa, "sza_out.tif");
geotiffwrite(sza_fn, sza.bands, sza.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');

% reproject saa
saa = getOLIsa(spires_dir_sa, r0dir, r_bands, demhdr, 'SAA');
save(fullfile(spires_dir_sa, "saa_out.mat"), "saa");
saa_fn = fullfile(spires_dir_sa, "saa_out.tif");
geotiffwrite(saa_fn, saa.bands, saa.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');

% load terrain properties, clip to sza extent
load(fullfile(spires_dir_sa, "sza_out.mat"));
elevation = load(demfile);
elevation_clipped = clip2mask(elevation.Z, sza.bands);
%dem_fn = fullfile(spires_dir_sa, "dem_clipped_out.tif");
%geotiffwrite(dem_fn, elevation_clipped, elevation.hdr.RasterReference, ...
%    'CoordRefSysCode', 'EPSG:32606');

% generate slope and aspect from elevation raster - function only accepts
% lat/lon
%[aspect,slope,~,~] = gradientm(elevation_clipped, out.hdr.RefMatrix);




% Load terrain properties
terrain_fp = strcat('terrain/',pr,'_terrain.nc');
elevation = double(ncread(terrain_fp,'elevation'));
slope = double(ncread(terrain_fp,'slope'));
aspect = double(ncread(terrain_fp,'aspect'));
% Permute arrays - python/matlab compatibility
elevation = permute(elevation, [2 1]);
slope = permute(slope, [2 1]);
aspect = permute(aspect, [2 1]);

% loop through output dates for specified pr
dates = dir(fullfile('output',pr,'**/*.mat'));
% dates = d([d(:).isdir]);
% dates = dates(~ismember({dates(:).name},{'.','..'}));

for i=1:length(dates)
    date = dates(i);
    angle_dir = dir(strcat('solar_angles/',pr,'/',date.name(10:17)));
    angle_files = angle_dir(~ismember({angle_dir(:).name},{'.','..'}));
    sza_file = angle_files(contains({angle_files(:).name},{'SZA'}));
    saa_file = angle_files(contains({angle_files(:).name},{'SAA'}));
    sza = read(Tiff(fullfile(sza_file.folder, sza_file.name), 'r')); % mu0
    saa = read(Tiff(fullfile(saa_file.folder, saa_file.name), 'r')); % phi0
    
    spires_output = load(strcat(date.folder,'/',date.name));
    spires_gs = spires_output.grainradius;
    spires_dust = spires_output.dust;
    
    % Permute arrays - python/matlab compatibility
%     mu0 = permute(mu0, [2 1]);
%     phi0 = permute(phi0, [2 1]);
    
%     spires_gs = permute(spires_gs, [2 1]);
%     spires_dust = permute(spires_dust, [2 1]);
    
    % Set NaN
    sza(sza==-2147483648) = NaN;
    sza(sza==0) = NaN;
    saa(saa==-2147483648) = NaN;
    spires_gs(spires_gs==65535) = NaN;
    spires_gs(spires_gs==-2147483648) = NaN;
    spires_gs(spires_gs<-9e18) = NaN;
    spires_dust(spires_dust==65535) = NaN;
    % Prepare variables
    sza = double(sza/100);
    saa = double(saa/100);
    sza = cosd(sza);
    saa = 180. - saa;
    saa(saa > 180) = saa(saa > 180) - 360;
    spires_dust = spires_dust/1e6;
    spires_dust = spires_dust/10;
    % Calculations
    sz = size(slope);
    sun = sunslope(sza(1:sz(1), 1:sz(2)), saa(1:sz(1), 1:sz(2)), slope, aspect);
    albedo_clean = AlbedoLookup(spires_gs, sza(1:sz(1), 1:sz(2)), sun, elevation);
    albedo_dirty = AlbedoLookup(spires_gs, sza(1:sz(1), 1:sz(2)), sun, elevation, LAPname='dust', LAPconc=spires_dust);

    save(strcat(strcat(date.folder, '/', date.name)),'albedo_clean','albedo_dirty','-append');

end
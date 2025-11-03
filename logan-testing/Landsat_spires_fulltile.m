%example script for running SPIReS with Landsat 8 

% Bair, E.H., Stillinger, T., and Dozier, J. (2021) 
% Snow Property Inversion from Remote Sensing (SPIReS), 
% IEEE Transactions on Remote Sensing and Geoscience, 
% doi: 10.1109/TGRS.2020.3040328

%unzip example files
% unzip('L8example.zip')
addpath(genpath([pwd])) %first cd to SPIRES repo
addpath(genpath('/projects/lost1845/ParBal')) %change to your parbal path

% RTP - setup i/o directories
lstdir = '/pl/active/rittger_ESP/landsat/lc08_l2sp_02_t1/';
%lstdir = '/scratch/alpine/lost1845/SPIRES';
spires_dir = '/scratch/alpine/lost1845/SPIRES'; % not used
pr = 'p042r034';
%epsg_code = 'EPSG:32613'; %p034r032, p034r033 Colorado UTM Zone 13N
%epsg_code = 'EPSG:32612'; %p035r034 Colorado UMT Zone 12N
epsg_code = 'EPSG:32611'; %p042r034 Sierra Nevada, CA

%files
r0dir=fullfile(lstdir, pr, 'spires', 'ancillary', 'R0'); %snow/ice minima background, p42r34 20201014
%rdir=fullfile(pwd,'R'); %snow covered scene, p42r34 20160426
demfile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_dem.mat')); % DEM for p42r34 - extraneous 
%if terrain correction set to false & el_cutoff = 0 m
Ffile=fullfile(lstdir,'data','Ffile','lut_oli_b1to7_3um_dust.mat'); % look up tables
%Mie-RT calcs for snow for L8 bands 1-7 w/ 3 um dust
CCfile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_cc.mat')); % canopy cover percent file, NLCD
WaterMaskfile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_watermask.mat')); %watermask file, NLCD
%CloudMaskfile=fullfile(lstdir, pr, 'spires', 'ancillary','cloudmask',strcat(pr,'_cloudmask.mat')); %RTP added
CloudMaskfiles = dir(strcat(lstdir, pr, '/spires/ancillary/cloudmask/*.mat'));
CloudMaskfiles = {CloudMaskfiles.name};
fIcefile=fullfile(lstdir, pr, 'spires', 'ancillary',strcat(pr,'_fice.mat')); %fractional ice, derived from
%Randolph Glacier Inventory

% AlbedoLookup files
solarAngleDir = fullfile(lstdir, pr, 'spires', 'ancillary', 'solar_angles');
SZAfiles = dir(strcat(lstdir, pr, '/spires/ancillary/solar_angles/*sza.mat'));
SZAfiles = {SZAfiles.name};
SAAfiles = dir(strcat(lstdir, pr, '/spires/ancillary/solar_angles/*saa.mat'));
SAAfiles = {SAAfiles.name};
slopefile = fullfile(lstdir, pr, 'spires', 'ancillary', strcat(pr, '_slope.mat'));
aspectfile = fullfile(lstdir, pr, 'spires', 'ancillary', strcat(pr, '_aspect.mat'));

%parameters
shade=0; % ideal shade endmember, fraction 0-1
tolval=0.1; % tolerance value for uniquetol for grouping spectra, fraction 0-1, Ned's value=0.05
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


%% run spires on one scene
% i = 1;
% %for i=1:length(dates)
% 
% 
%     rdir=fullfile(dates(i).folder, dates(i).name);
%     disp(rdir)
%       
%     %takes 2.09 min running w/ 50 cores
%     out=run_spires_landsat(r0dir,rdir,demfile,Ffile,shade,tolval,...
%         fsca_thresh,dust_rg_thresh,grain_thresh,dust_thresh,CCfile,...
%         WaterMaskfile,CloudMaskfile,fIcefile,...
%         el_cutoff,subset,false);
%     
%     % create spires out directory
%     out_dir = fullfile(spires_dir, pr, 'spires', 'output', dates(i).name);
%     if not(isfolder(out_dir))
%         mkdir(out_dir);
%         %addpath(fullfile(pwd, out_dir));
%     end
%     
%     % save data
%     out_file = fullfile(out_dir, strcat(pr,'_',dates(i).name, '_spires_out.mat'));
%     save(out_file, 'out', '-v7.3')
%     % save grain radius and dust tifs to view in QGIS
%     geotiffwrite(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_grain_radius_out.tif')), out.grainradius, out.hdr.RasterReference, ...
%         'CoordRefSysCode', epsg_code);
%     geotiffwrite(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_dust_out.tif')), out.dust, out.hdr.RasterReference, ...
%         'CoordRefSysCode', epsg_code);
% 
% 
%     % reproject solar angles
%     %sza
%     sza = getOLIsa(solarAngleDir, r0dir, out.R, out.hdr, 'SZA', dates(i).name);
%     save(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_sza_out.mat')), "sza");
%     geotiffwrite(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_sza_out.tif')), sza.bands, sza.RasterReference, ...
%         'CoordRefSysCode', epsg_code);
%     
%     %saa
%     saa = getOLIsa(solarAngleDir, r0dir, out.R, out.hdr, 'SAA', dates(i).name);
%     save(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_saa_out.mat')), "saa");
%     geotiffwrite(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_saa_out.tif')), saa.bands, saa.RasterReference, ...
%         'CoordRefSysCode', epsg_code);
% 
% 
% end

%% loop through all scenes
for i=1:length(dates)
%i=21;


   rdir=fullfile(dates(i).folder, dates(i).name);
   disp(rdir)

   % get matching cloud mask file
   matchIdx = contains(CloudMaskfiles, dates(i).name);
   matchedFiles = CloudMaskfiles(matchIdx);
   CloudMaskfile = strcat(lstdir, pr, '/spires/ancillary/cloudmask/', matchedFiles{1});

 
   % run spires algorithm
   out=run_spires_landsat(r0dir,rdir,demfile,Ffile,shade,tolval,...
       fsca_thresh,dust_rg_thresh,grain_thresh,dust_thresh,CCfile,...
       WaterMaskfile,CloudMaskfile,fIcefile,...
      el_cutoff,subset,false);

   fsca = out.fsca;
   fsca_raw = out.fsca_raw;
   dust = out.dust;
   grainradius = out.grainradius;
   hdr = out.hdr;

   % create output directory
   out_dir = strcat(lstdir, 'data/output/',pr,'/',dates(i).name, '/', 'mat');
   if not(isfolder(out_dir))
       mkdir(out_dir);
       addpath(out_dir);
   end
   % save data
   out_file = fullfile(out_dir,strcat(pr,'_',dates(i).name, '_spires_out.mat'));
   save(out_file, "fsca", "fsca_raw", "dust", "grainradius", "hdr");
end


%% load elevation file and calculate slope and aspect 
% elevation = load(demfile);
% 
% % get aspect and slope from elevation raster
% ancillary_dir = fullfile(lstdir, pr, 'spires', 'ancillary');
% getAspectSlope(elevation, epsg_code, ancillary_dir, pr);
% 
% 
% % load sza and saa
% load(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_sza_out.mat')));
% load(fullfile(out_dir, strcat(pr,'_',dates(i).name, '_saa_out.mat')));
% 
% 
% % clip valid pixel extent
% elevation_clipped = clip2mask(elevation.Z, sza.bands);
% elevation_clipped = elevation_clipped/1000; % convert to km  
% 
% %elevation_clipped_fn = fullfile(out_dir, "elevation_clipped_out.tif");
% %geotiffwrite(elevation_clipped_fn, elevation_clipped, elevation.hdr.RasterReference, ...
% %    'CoordRefSysCode', 'EPSG:32606');
% 
% % load terrain properties 
% % aspect
% [aspect, R_aspect] = readgeoraster(fullfile(ancillary_dir, strcat(pr, '_aspect.tif')));
% aspect = double(aspect);
% aspect(aspect == -9999) = NaN;
% aspect_clipped = clip2mask(aspect, sza.bands);
% 
% % aspect_clipped_fn = fullfile(out_dir, "aspect_clipped_out.tif");
% % geotiffwrite(aspect_clipped_fn, aspect_clipped, R_aspect, ...
% %     'CoordRefSysCode', 'EPSG:32606');
% 
% % slope
% [slope, R_slope] = readgeoraster(fullfile(ancillary_dir, strcat(pr, '_slope.tif')));
% slope = double(slope);
% slope(slope == -9999) = NaN;
% slope_clipped = clip2mask(slope, sza.bands);
% 
% 
% % slope_clipped_fn = fullfile(out_dir, "slope_clipped_out.tif");
% % geotiffwrite(slope_clipped_fn, slope_clipped, R_slope, ...
% %     'CoordRefSysCode', 'EPSG:32606');
% 
% % get dust and grain radius from spires output
% load(out_file);
% 
% spires_gs = out.grainradius;
% spires_dust = out.dust;
% % set NaNs
% spires_gs(spires_gs==65535) = NaN;
% spires_gs(spires_gs==-2147483648) = NaN;
% spires_gs(spires_gs<-9e18) = NaN;
% spires_dust(spires_dust==65535) = NaN;
% % scale factors
% spires_dust = spires_dust/1e6;
% spires_dust = spires_dust/10;
% 
% % Calculations - modified AlbedoLookup function to exclude NAs
% sun = sunslope(sza.bands, saa.bands, slope_clipped, aspect_clipped);
% albedo_clean = AlbedoLookup(spires_gs, sza.bands, sun, elevation_clipped);
% albedo_dirty = AlbedoLookup(spires_gs, sza.bands, sun, elevation_clipped, LAPname='dust', LAPconc=spires_dust);
% 
% figure;
% % albedo clean
% subplot(1,2,1);          
% histogram(albedo_clean(:));
% title('Albedo Clean');
% 
% % albedo dirty
% subplot(1,2,2);          
% histogram(albedo_dirty);
% title('Albedo Dirty');
% 
% 
% %save tifs
% albedo_clean_fn = fullfile(out_dir, "albedo_clean_out.tif");
% geotiffwrite(albedo_clean_fn, albedo_clean, out.hdr.RasterReference, ...
%     'CoordRefSysCode', 'EPSG:32606');
% albedo_dirty_fn = fullfile(out_dir, "albedo_dirty_out.tif");
% geotiffwrite(albedo_dirty_fn, albedo_dirty, out.hdr.RasterReference, ...
%     'CoordRefSysCode', 'EPSG:32606');







% Load terrain properties
elevation = load(demfile).Z;
elevation = elevation ./ 1000;
slope = load(slopefile).slope;
slope(slope == -9999) = NaN;
aspect = load(aspectfile).aspect;
aspect(aspect == -9999) = NaN;
aspect = mod(180 - aspect, 360); % convert aspect to ccw from south to match sunslope fcn

% loop through output dates for specified pr
%spires_files = dir(fullfile(lstdir, 'data', 'output',pr, '**/*.mat'));
spires_files = dir(fullfile(lstdir, 'data', 'output', pr, '**', 'mat/*.mat'));
% dates = d([d(:).isdir]);
% dates = dates(~ismember({dates(:).name},{'.','..'}));

for i=1:length(spires_files)
  
    date = spires_files(i).name(10:17);
    spires_fp = fullfile(spires_files(i).folder, spires_files(i).name);

    % load solar angles
    angle_dir = strcat(lstdir, pr, '/', 'spires/ancillary/solar_angles/');
    sza_file = SZAfiles{contains(SZAfiles,date)};
    saa_file = SAAfiles{contains(SAAfiles,date)};
    sza = load(fullfile(angle_dir, sza_file)).sza;
    saa = load(fullfile(angle_dir, saa_file)).saa;

    
    % load dust and grain size from spires
    spires_output = load(spires_fp);
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
    %saa = 180. - saa;
    %saa(saa > 180) = saa(saa > 180) - 360;
    saa = mod(180 - saa, 360); % convert saa to ccw from south to match sunslope fcn
    spires_dust = spires_dust/1e6;
    spires_dust = spires_dust/10;
    % Calculations
    sun = sunslope(sza, saa, slope, aspect);
    albedo_clean = AlbedoLookup(spires_gs, sza, sun, elevation);
    albedo_dirty = AlbedoLookup(spires_gs, sza, sun, elevation, LAPname='dust', LAPconc=spires_dust);

    save(spires_fp,'albedo_clean','albedo_dirty','-append');

end

%% save tifs
for i=1:length(spires_files)

    date = spires_files(i).name(10:17);
    spires_fp = fullfile(spires_files(i).folder, spires_files(i).name);

    % create directories for output tifs
    tif_dir = fullfile(lstdir, 'data', 'output', pr, date, 'tif');
    if not(isfolder(tif_dir))
       mkdir(tif_dir);
       addpath(tif_dir);
   end

   spires_out = load(spires_fp);

   %save tifs
   geotiffwrite(fullfile(tif_dir, strcat(pr, '_', date, '_dust.tif')), ...
       spires_out.dust, spires_out.hdr.RasterReference, ...
       'CoordRefSysCode', epsg_code);
   geotiffwrite(fullfile(tif_dir, strcat(pr, '_', date, '_fsca.tif')), ...
       spires_out.fsca, spires_out.hdr.RasterReference, ...
       'CoordRefSysCode', epsg_code);
   geotiffwrite(fullfile(tif_dir, strcat(pr, '_', date, '_fsca_raw.tif')), ...
       spires_out.fsca_raw, spires_out.hdr.RasterReference, ...
       'CoordRefSysCode', epsg_code);
   geotiffwrite(fullfile(tif_dir, strcat(pr, '_', date, '_grainradius.tif')), ...
       spires_out.grainradius, spires_out.hdr.RasterReference, ...
       'CoordRefSysCode', epsg_code);
   geotiffwrite(fullfile(tif_dir, strcat(pr, '_', date, '_albedo_clean.tif')), ...
       spires_out.albedo_clean, spires_out.hdr.RasterReference, ...
       'CoordRefSysCode', epsg_code);
   geotiffwrite(fullfile(tif_dir, strcat(pr, '_', date, '_albedo_dirty.tif')), ...
       spires_out.albedo_dirty, spires_out.hdr.RasterReference, ...
       'CoordRefSysCode', epsg_code);

end




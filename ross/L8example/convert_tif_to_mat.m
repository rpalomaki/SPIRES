pr = 'p068r014'; 
cc_fp = strcat('CC/tif/',pr,'_cc.tif');
% cloudmask_fp = strcat('cloudmask/tif/',pr,'_cloudmask.tif');
% dem_fp = strcat('DEM/tif/',pr,'_dem.tif');
% fice_fp = strcat('fice/tif/',pr,'_fice.tif');
% watermask_fp = strcat('watermask/tif/',pr,'_watermask.tif');

% dem_p042r034 = load('DEM/p042r034.mat');

% dem = struct('Z', read(Tiff("DEM/tif/p068r014_dem.tif", 'r')));
% sr_b1 = 'R0/p068r014/LC08_L2SP_068014_20140918_20200911_02_T1_SR_B1.TIF';
% info = georasterinfo(sr_b1);
% dem.hdr.RasterReference.ProjectedCRS=info.CoordinateReferenceSystem;

cc = read(Tiff(cc_fp, 'r'));
% cloudmask = read(Tiff(cloudmask_fp, 'r'));
% dem = struct('Z', read(Tiff("DEM/tif/p068r014_dem.tif", 'r')));
% Z = read(Tiff("DEM/tif/p068r014_dem.tif", 'r'));
% fice = read(Tiff(fice_fp, 'r'));
% watermask = read(Tiff(watermask_fp, 'r'));

save(strcat('CC/',pr,'_cc.mat'),'cc');
% save(strcat('cloudmask/',pr,'_cloudmask.mat'),'cloudmask');
% save(strcat('DEM/',pr,'_dem.mat'),'Z');
% save(strcat('fice/',pr,'_fice.mat'),'fice');
% save(strcat('watermask/',pr,'_watermask.mat'),'watermask');






hdr = struct(); 

point = [65.58711 -145.13650];
hdr.ProjectionStructure = createUTMmstruct(point);

hdr.RasterReference = georasterinfo('DEM/tif/p068r014_dem.tif').RasterReference;
refmat_xlim = hdr.RasterReference.XWorldLimits(1);
refmat_ylim = hdr.RasterReference.YWorldLimits(2);
RefMatrix = [0, -30; 30, 0; refmat_xlim-15, refmat_ylim+15];

hdr.RefMatrix = RefMatrix;
save('DEM/p068r014_dem.mat','hdr','-append')
save('CC/p068r014_cc.mat','hdr','-append')
save('cloudmask/p068r014_cloudmask.mat','hdr','-append')
save('fice/p068r014_fice.mat','hdr','-append')
save('watermask/p068r014_watermask.mat','hdr','-append')


% test = createUTMprojcrs(point(1), point(2)); % does not produce necessary
% variables
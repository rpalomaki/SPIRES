%function [aspect, slope] = getAspectSlope(in_rast, target)
in_rast = elevation_clipped;
target = out.hdr;


dx = target.RasterReference.CellExtentInWorldX;
dy = target.RasterReference.CellExtentInWorldY;

[dzdy, dzdx] = gradient(double(elevation_clipped), dy, dx);

slope = atan(sqrt(dzdx.^2 + dzdy.^2)) * (180/pi);
aspect = atan2(dzdx, -dzdy) * (180/pi);
aspect = mod(aspect, 360);

geotiffwrite(fullfile(spires_dir_sa, "slope_out.tif"), slope, target.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');
geotiffwrite(fullfile(spires_dir_sa, "aspect_out.tif"), aspect, target.RasterReference, ...
    'CoordRefSysCode', 'EPSG:32606');



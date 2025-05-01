function clipped_rast = clip2mask(in_rast, target)

% convert in_rast to type doulbe
in_rast = double(in_rast);

% clip raster using valid pixels in targer raster
invalidPxMask = isnan(target);
clipped_rast = in_rast;
clipped_rast(invalidPxMask) = NaN;

end
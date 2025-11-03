%% test with with these inputs
%ldir = '/scratch/alpine/lost1845/SPIRES/20180508';
%target = out.hdr;
%angle_type = 'SZA';

function SA=getOLIsa(ldir, r0dir, r_bands, target, angle_type)
%retrieve OLI solar zenith or solar azumith angles
%input: ldir - directory of SZA and SAA tifs, string
%target - [] empty or target_hdr w/ fields RefMatrix and
%ProjectionStructure and rasterref
%sun_file - string 'SZA' or 'SAA'
%output:
%   SA - struct with fields bands, RefMatrix, ProjectionStructure,and
%   RasterReference

%directory listing produces ascending sort of bands, except for HLS
%collection 1 on demand surface reflectance

% get r0 file for creating invalid pixel mask
%get R0 refl and reproject to hdr
R0=getOLIsr(r0dir,target);

%reproject R bands - nevermind, use output from run_spires_landsat
% actually, should probably just use out.nodatamask from spires
%[R,~]=getOLIsr(rdir,target);

%out of scene Nan mask
%invalidPxMask = isnan(R.bands(:,:,1)) | isnan(R0.bands(:,:,1));
invalidPxMask = isnan(r_bands(:,:,1)) | isnan(R0.bands(:,:,1));

% get sun angle file name
angle_string = ['*' char(angle_type) '*'];
d=dir(fullfile(ldir, angle_string));

% read file
fname=fullfile(d.folder,d.name);
X=single(readgeoraster(fname));

switch angle_type
    case 'SZA'
        X(X==-2147483648) = NaN;
        X(X==0) = NaN;
    case 'SAA'
        X(X==-2147483648) = NaN;
end

% get raster info
info=georasterinfo(fname);
RasterReference=info.RasterReference;

% create band field of zeros
SA.bands=zeros([target.RasterReference.RasterSize length(d)]);

if any(size(X)~=target.RasterReference.RasterSize)

            % reproject if RefMatrices or raster sizes don't match
            %             [X,R.RasterReference]=rasterReprojection(X,RasterReference,...
            %                 'InProj',ProjectionStructure,'OutProj',target.ProjectionStructure,'rasterref',...
            %                 target.RasterReference);
            %             R.RefMatrix=RasterRef2RefMat(R.RasterReference);
            %             R.ProjectionStructure=target.ProjectionStructure;
            X=rasterReprojection(X,RasterReference,...
                'rasterref',target.RasterReference,'cells',false);
end

% set nans using R0 band 1
%X(isnan(R0.bands(:, :, 1))) = NaN;
X(invalidPxMask) = NaN;

switch angle_type
    case 'SZA'
        %X = double(X/100);
        %X = cosd(X);
    case 'SAA'
        X = double(X/100);
        X = 180. - X;
        X(X > 180) = X(X > 180) - 360;
end

SA.bands(:,:,1)=X;
SA.RasterReference=target.RasterReference;

end
function F=build_lt(sensor,bands,integrate)
%input: sensor, string, e.g. 'LandsatOLI' , 'MODIS', 'VIIRS'
%bands: 1xN vector indicating bands needed from sensor table, e.g. 1:7 for
%L8 bands 1:7 or 1:13 for HSI bands 1-8,8a,9-12; 1:7 for MODIS 
%MOD09@500m resolution; 
%or [6:10 12 13 15 16] for VIIRS VNP09@750m resolution
%integrate: integrate over bandpasses, 1- yes, 0 - no
% output: gridded interpolant with inputs:
%grain size (um), dust (conc. by
% weight, ppm), solar zenith angle (deg), and band (N)

sT=SensorTable(sensor);

radius=30:10:1200;
dust=[0 0.1 1:10:1000];
solarZ=0:1:90;

lTbl=zeros(length(radius),length(dust),...
    length(solarZ),length(bands));
N=length(radius)*length(dust);

n=0;
tic;
for i=1:length(radius)
    for j=1:length(dust)
        parfor k=1:length(solarZ)
            outI=zeros(size(bands));
            if integrate
                P=setPrescription('snow','cosZ',cosd(solarZ(k)),...
                    'bandPass',[sT.LowerWavelength(bands) sT.UpperWavelength(bands)],...
                    'waveUnit','um','radius',radius(i),'LAP','dust',...
                    'LAPfraction',dust(j)*1e-6);
                out=SPIReS_fwd(P);
                S=SolarScale('wavelength',P.Spectrum.wavelength,'units',...
                    P.Spectrum.waveUnit);
                for m=1:length(bands)
                    b=P.Spectrum.waveBand==m;
                    outI(m)=trapz(P.Spectrum.wavelength(b),S.Global(b).*out(b))./...
                        trapz(P.Spectrum.wavelength(b),S.Global(b));
                end
            else %no integration
                P=setPrescription('snow','cosZ',cosd(solarZ(k)),...
                    'waveLength',sT.CentralWavelength(bands),...
                    'waveUnit','um','radius',radius(i),'LAP','dust',...
                    'LAPfraction',dust(j)*1e-6);
                outI(:)=SPIReS_fwd(P);
            end
            lTbl(i,j,k,:)=outI;
        end
    end
    n=n+1;
    etime=toc;
    fprintf('pct done=%2.5f; time=%2.5f hr\n',...
        n/N*100,etime/60/60);
end
[w,x,y,z]=ndgrid(radius,dust,solarZ,1:length(bands));
F=griddedInterpolant(w,x,y,z,lTbl,'linear','nearest');
% Load lidar tile, and clip polygon.  Clip to bounding box.
L = lasread('../data/DK22.las');
% S = shaperead('altgeld.shp');
% bb = S.BoundingBox;
% bb(1,:) = floor(bb(1,:));
% bb(2,:) = ceil(bb(2,:));

% L = lasclip(L,bb);
X = L.X;
Y = L.Y;
Z = L.Z;
clear L

X = X*.3048;
Y = Y*.3048;
Z = Z*.3048;

% Recenter
X = X - mean(X);
Y = Y - mean(Y);

% Rescale
% targetSize = .10; % in meters
% modelScale = targetSize/(max(X)-min(X));
% X = modelScale * X;
% Y = modelScale * Y;
% Z = modelScale * Z;

%% Create DSM, remove the jitters.
cellSize = 2;
% cellSize = 1I(bad) = NaN;
% I = inpaint_nans(I,5);;
% cellSize = modelScale * cellSize;
[I R] = createDSM(X,Y,Z,'c',cellSize,'inpaintmethod',4,'type','min');
bad = progressiveFilter(I,'c',cellSize,'w',1','s',.15);
I(bad) = NaN;
I = inpaint_nans(I,5);

geotiffwriteOld('dk22_dem.tif',I,R)

%% Create TIN

tic 

minModelThickness = 2;
[idx x y z] = dem2model(I,R,minModelThickness);

x3dindexedfaceset2('dk22.x3d',idx,x,y,z,'solid','false','convex','false','precision',3,...
    'vieworientation','1 0 0 -1.57','skycolor','.4 .4 .5','ambientintensity','.14','diffusecolor','.7 .7 .5', ...
    'emissivecolor','0 0 0','shininess','.16','specularcolor','.1 .1 .1','transparency','0');

toc
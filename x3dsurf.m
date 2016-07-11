% function [xDoc] = x3dsurf(filename,ZI,varargin)
% 
% x3dsurf is a function in active development that takes an elevation grid,
% and creates an X3D elevation grid from it.  In my own work, this file has
% largely been superceded by x3dindexedfaceset.m
%
% Example:
% x3dsurf('peaks.x3d',peaks(100));
%
% If the image is georeferenced, this information can be passed to the
% function:
% x3dsurf('peaks2.x3d',peaks(100),'refmat',makerefmat(0,0,1,-1));
%
% Or, if the elevation and referencing matrix have already
% been read: 
% [Z R] = arcgridread('MtWashington-ft.grd');
% x3dsurf('MtWashington-ft.x3d',Z,'refmat',R);
%
% The x and z spacing can also be explicitly set if R is not supplied with 
% 'xspacing' and 'zspacing' arguments.
%
%
% Texturing other than with the default colormap must be done with a
% supplied RGB image
%
% nColors = 256;
% cmap = demcmap(Z,nColors);
% rgb = ind2rgb(gray2ind(mat2gray(Z),nColors),cmap);
% x3dsurf('MtWashington-ft-texture1.x3d',Z,'refmat',R,'texture',rgb);
% 
% Alternatively, you can specify the filename.
% imwrite(rgb,'MtWashington-texture.png');
% x3dsurf('MtWashington-ft-texture2.x3d',Z,'refmat',R,'texture','MtWashington-texture.png');
%
% 
% This file is under active development.
%
% Author: Thomas J. Pingel
% Last updated: February 17, 2013
% tpingel.org/code


function [] = x3dsurf(filename,ZI,varargin)

% [ZI R bbox] = geotiffread('elevation.resample.tif');
% psize = 40;
% ZI = peaks(psize);
% R = makerefmat(psize,psize,1,1);
% filename = 'ftest.x3d';

[xDim zDim] = size(ZI);

nColors = 64;
cmap = jet(nColors);
defaultColor = [.4 .4 .1];
avatarSize = [1 1.6 10];


% Set some default values that can be specified by argument
xSpacing = 1;
zSpacing = 1;

% defaultPosition = [.9*xDim 2.5*max(ZI(:)) .9*zDim];
% defaultOrientation = [-.42 .89 .18 .90];

fov = pi/4; % Default field of view
defaultPosition = [xDim*xSpacing/2 mean(ZI(:)) (xDim*xSpacing)/tan(fov/2)];
defaultOrientation = [0 0 0 0];


nColors = 64;
[X map] = gray2ind(mat2gray(ZI),nColors);
C = ind2rgb(X,jet(nColors));

i = 1;
if nargin > 2
    while i<length(varargin)
        if isstr(varargin{i})
            switch lower(varargin{i})
                case 'refmat'
                    R = varargin{i+1};
                    xSpacing = abs(R(2));
                    zSpacing = abs(R(4));
                    i = i + 1;
                case 'texture'
                    C = varargin{i+1};
                    i = i + 1;
                case 'xspacing'
                    xSpacing = varargin{i+1};
                    i = i + 1;
                case 'zspacing'
                    zSpacing = varargin{i+1};
                    i = i + 1;
                otherwise
                    disp(['Argument <',varargin{i},'> is not supported.']);
                
            end
        end
        i = i + 1;
    end
end

% xSpacing = abs(R(2));
% zSpacing = abs(R(4));

COO = [.5*xDim*xSpacing .5*zDim*zSpacing];


defaultSecondsToTraverse = 15;
speed = mean([xSpacing*xDim zSpacing*zDim])/defaultSecondsToTraverse;  %



xDoc = com.mathworks.xml.XMLUtils.createDocument('X3D');
rootElement = xDoc.getDocumentElement;

rootElement.setAttribute('profile','Interchange');
rootElement.setAttribute('version','3.0');

  sceneElement = xDoc.createElement('Scene'); 
  rootElement.appendChild(sceneElement);
  
  backgroundElement = xDoc.createElement('Background');
  backgroundElement.setAttribute('groundColor','0 0 0');
  backgroundElement.setAttribute('skyColor','0.6 0.6 1');
  sceneElement.appendChild(backgroundElement);
%   
%   lightElement = xDoc.createElement('DirectionalLight');
%   lightElement.setAttribute('direction','0 -1 -.2');
%   lightElement.setAttribute('ambientIntensity','0.25');
%   lightElement.setAttribute('color','1 0.9 0.7');
%   sceneElement.appendChild(lightElement);
  
    % Define navigation elements and viewpoints
  navigationElement = xDoc.createElement('NavigationInfo');
    % Collision distance, camera height above ground, highest distance camera can walk over
    navigationElement.setAttribute('avatarSize',sprintf('% 1.2f',avatarSize)); 
    navigationElement.setAttribute('type','''EXAMINE'' ''ANY''');
    navigationElement.setAttribute('speed',num2str(speed));
    navigationElement.setAttribute('headlight','true');
  sceneElement.appendChild(navigationElement);
  
  viewElement = xDoc.createElement('Viewpoint');
    viewElement.setAttribute('description','StartingViewpoint');
    viewElement.setAttribute('fieldOfView',sprintf('%0.4f',fov));
    viewElement.setAttribute('position',sprintf('% 0.2f',defaultPosition));
    viewElement.setAttribute('orientation',sprintf('% 0.2f',defaultOrientation));
    viewElement.setAttribute('centerOfRotation',sprintf('% 0.2f',[xSpacing*xDim/2 mean(ZI(:)) zSpacing*zDim/2]));
    sceneElement.appendChild(viewElement);
  
  shapeElement = xDoc.createElement('Shape');
  
    appearanceNode = xDoc.createElement('Appearance');
    materialNode = xDoc.createElement('Material');
    materialNode.setAttribute('diffuseColor',sprintf('% 1.2f ',defaultColor));
    appearanceNode.appendChild(materialNode);
    
    % Apply colormap unless it's been defined as a single color
    if ~isempty(C) & isstr(C)
        textureNode = xDoc.createElement('ImageTexture');
        textureNode.setAttribute('url',C);
%         else
%            imwrite(imrotate(flipdim(C,2),90),[filename,'.png']);
%            textureNode.setAttribute('url',[filename,'.png']);
        appearanceNode.appendChild(textureNode);
    end
    
    shapeElement.appendChild(appearanceNode);
    
    gridElement = xDoc.createElement('ElevationGrid');
    gridElement.setAttribute('xDimension',num2str(xDim));
    gridElement.setAttribute('zDimension',num2str(zDim));
    gridElement.setAttribute('xSpacing',num2str(xSpacing));
    gridElement.setAttribute('zSpacing',num2str(zSpacing));
    gridElement.setAttribute('solid','false');
    gridElement.setAttribute('creaseAngle','3.14');
    ZI = fliplr(ZI);
    gridElement.setAttribute('height',sprintf('% 0.3f ',ZI(:)));
%     gridElement.setAttribute('color',sprintf('% 0.2f',C(:)));
%     shapeElement.setAttribute('height',num2str(ZI(:)));
  shapeElement.appendChild(gridElement);
  sceneElement.appendChild(shapeElement);

    if ~isempty(C) & ~isstr(C)
        Cs = C;
        Cs(:,:,1) = fliplr(Cs(:,:,1));
        Cs(:,:,2) = fliplr(Cs(:,:,2));
        Cs(:,:,3) = fliplr(Cs(:,:,3));
        Cs1 = Cs(:,:,1);Cs1=Cs1(:)';
        Cs2 = Cs(:,:,2);Cs2=Cs2(:)';
        Cs3 = Cs(:,:,3);Cs3=Cs3(:)';
        Csb = [Cs1;Cs2;Cs3];
       
        colorNode = xDoc.createElement('Color');
        colorNode.setAttribute('color',sprintf('% 0.2f',Csb(:)));
%         else
%            imwrite(imrotate(flipdim(C,2),90),[filename,'.png']);
%            textureNode.setAttribute('url',[filename,'.png']);
        gridElement.appendChild(colorNode);
    end
  
rootElement.appendChild(sceneElement);

% xmlwrite(xDoc)
if ~isempty(filename)
   xmlwrite(filename,xDoc);
end









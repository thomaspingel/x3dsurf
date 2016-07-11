function [] = x3dindexedfacesetm(fn,tri,x,y,z,varargin)

% IndexedFaceSet node
ccw = 'TRUE';
colorPerVertex = 'TRUE';
convex = 'TRUE';
creaseAngle = '0.0';
normalPerVertex = 'TRUE';
solid = 'TRUE';

% Coordinate node
coords = [];
numPrecision = '%0.8f ';

% GeoCoordinate node
worldType = 'normal';  % Specify 'geo' to activate 
geoSys = '"GD" "WE"';

% GeoOrigin Node
geoOrig = [];
yUp = 'false';

% Color node
c = [];

% Material node
shininess = '0.2';
diffuseColor = '0.8 0.8 0.8';
specularColor='0 0 0';
emissiveColor = '0 0 0';
ambientIntensity = '0.2';
transparency = '0';

texture = [];
browsertexture = [];

tcoords = [];

if nargin>=6
    i = 1;
    while i<=length(varargin)    
        if isstr(varargin{i})
            switchstr = lower(varargin{i});
            switch switchstr
                case 'ccw'
                    ccw = upper(varargin{i+1});
                    i = i + 2;
                case 'colorpervertex'
                    colorPerVertex = varargin{i+1};
                    if ~isstr(colorPerVertex)
                        colorPerVertex = boolean2str(colorPerVertex);
                    end
                    i = i + 2;                    
                case 'convex'
                    convex = upper(varargin{i+1});
                    i = i + 2;
                case 'solid'
                    solid = upper(varargin{i+1});
                    i = i + 2;                    
                case 'creaseangle'
                    creaseAngle = num2str(varargin{i+1});
                    i = i + 2;  
                case 'normalPerVertex'
                    normalPerVertex = upper(varargin{i+1});
                    i = i + 2;
                case 'normalPerVertex'
                    solid = upper(varargin{i+1});
                    i = i + 2;
                case 'c' % Color
                    c = varargin{i+1};
                    i = i + 2;
                case 'type' % GeoOrigin
                    worldType = lower(varargin{i+1});
                    i = i + 2;
                case 'geoorigin' % GeoOrigin
                    geoOrig = varargin{i+1};
                    i = i + 2;
                case 'geosys' % GeoSystem
                    geoSys = varargin{i+1};
                    i = i + 2;  
                case 'rotateyup'   % Rotate Y Up
                    yUp = varargin{i+1};
                    if ~isstr(yUp)
                        yUp = boolean2str(yUp);
                    end
                    i = i + 2;
                case 'precision'   % Numerical precision for geoCoordinates
                    numPrecision = varargin{i+1};
                    i = i + 2;
                case 'transparency'
                    shininess = num2str(varargin{i+1});
                    i = i + 2;
                case 'shininess'
                    shininess = num2str(varargin{i+1});
                    i = i + 2;
                case 'diffusecolor'
                    diffuseColor = num2str(varargin{i+1});
                    i = i + 2;              
                case 'emissivecolor'
                    emissiveColor = num2str(varargin{i+1});
                    i = i + 2;   
                case 'specularcolor'
                    specularColor = num2str(varargin{i+1});
                    i = i + 2;                     
                case 'ambientintensity'
                    ambientIntensity = num2str(varargin{i+1});
                    i = i + 2;              
                case 'texture'
                    texture = num2str(varargin{i+1});
                    i = i + 2;   
                case 'browsertexture'
                    browsertexture = num2str(varargin{i+1});
                    i = i + 2;   
                case 'tcoords'
                    tcoords = varargin{i+1};
                    i = i+2;
                otherwise
                    i = i + 1;
            end
        else
            i = i + 1;
        end
    end   
end

n = size(tri,1);


% if isempty(c)
%     c = [0 1 0];
%     c = repmat(c,n,1);
% end
% c = c';


if ~ischar(numPrecision)
   numPrecision = ['%0.',num2str(numPrecision),'f ']
end



%%
if strcmp(worldType,'geo')
    coords = [y x z]'; % Northing/Latitude is always specified first by default
else
    coords = [x y z]'; % In usual X3D, the y axis is what we think of as elevation (z)
end
coords = coords(:);
tri = tri - 1;
% min(tri(:));
tri = [tri -1*ones(n,1)]';
tri = tri(:);

% transform tcoords to [0 1] space
if ~isempty(tcoords)
    if strcmp(worldType,'geo')
        fliplr(tcoords);
    end
    tcoords(:,1) = mat2gray(tcoords(:,1));
    tcoords(:,2) = mat2gray(tcoords(:,2));
    tcoords = tcoords';
end
%%

xDoc = com.mathworks.xml.XMLUtils.createDocument('X3D');
docType = xDoc.createDocumentType('X3D','ISO//Web3D//DTD X3D 3.1//EN','http://www.web3d.org/specifications/x3d-3.1.dtd');
xDoc.appendChild(docType);

rootElement = xDoc.getDocumentElement;

rootElement.setAttribute('profile','Full');
rootElement.setAttribute('version','3.1');

% Declare Geospatial Component
% headElement = xDoc.createElement('head');
% rootElement.appendChild(headElement);
% componentElement = xDoc.createElement('component');
% headElement.appendChild(componentElement);
% componentElement.setAttribute('name','Geospatial');
% componentElement.setAttribute('level','1');

  sceneElement = xDoc.createElement('Scene'); 
  rootElement.appendChild(sceneElement);
  
 
      % Define navigation elements and viewpoints
%   navigationElement = xDoc.createElement('NavigationInfo');
% %     Collision distance, camera height above ground, highest distance camera can walk over
%     navigationElement.setAttribute('avatarSize','.5 1.6 1.6'); 
%     navigationElement.setAttribute('type','ANY');
%     navigationElement.setAttribute('speed','100');
%   sceneElement.appendChild(navigationElement);
  
  
%   viewElement = xDoc.createElement('Viewpoint');
%     viewElement.setAttribute('description','Viewpoint 1');
%     viewElement.setAttribute('fieldOfView','0.7854');
%     viewElement.setAttribute('position',sprintf('% 1.2f',calculatedPosition));
%   sceneElement.appendChild(viewElement);
%   
  shapeElement = xDoc.createElement('Shape');
%   
    appearanceNode = xDoc.createElement('Appearance');
    materialNode = xDoc.createElement('Material');
    materialNode.setAttribute('diffuseColor',diffuseColor);
    materialNode.setAttribute('emissiveColor',emissiveColor);
    materialNode.setAttribute('specularColor',specularColor);
    materialNode.setAttribute('ambientIntensity',ambientIntensity);
    materialNode.setAttribute('shininess',num2str(shininess));
    appearanceNode.appendChild(materialNode);
    
    if ~isempty(texture)
        textureNode = xDoc.createElement('ImageTexture');
        textureNode.setAttribute('url',texture);
        appearanceNode.appendChild(textureNode);
    end

    if ~isempty(browsertexture)
        browsertextureNode = xDoc.createElement('BrowserTexture');
        browsertextureNode.setAttribute('url',browsertexture);
        appearanceNode.appendChild(browsertextureNode);
    end    
    
    shapeElement.appendChild(appearanceNode);

        
        
        %     
    ifsElement = xDoc.createElement('IndexedFaceSet');
    ifsElement.setAttribute('containerField','geometry');
    ifsElement.setAttribute('ccw',ccw);
    ifsElement.setAttribute('colorPerVertex',colorPerVertex);
    ifsElement.setAttribute('convex',convex);
    ifsElement.setAttribute('creaseAngle',creaseAngle);
    ifsElement.setAttribute('colorPerVertex',colorPerVertex);
    ifsElement.setAttribute('solid',solid);
    ifsElement.setAttribute('coordIndex',sprintf('%i ',tri));
    
    if strcmp(worldType,'geo')
        coordElement = xDoc.createElement('GeoCoordinate');
        coordElement.setAttribute('geoSystem',geoSys);
    else
        coordElement = xDoc.createElement('Coordinate');
    end
    
    coordElement.setAttribute('point',sprintf(numPrecision,coords));
    ifsElement.appendChild(coordElement);
    
    if ~isempty(tcoords)
        tcoordElement = xDoc.createElement('TextureCoordinate');
        tcoordElement.setAttribute('point',sprintf('%0.2f ',tcoords(:)));
        ifsElement.appendChild(tcoordElement);
    end
    

    % If geoOrigin was provided, add it.
    if ~isempty(geoOrig)
        geoOriginElement = xDoc.createElement('GeoOrigin');
        geoOriginElement.setAttribute('geoSystem',geoSys);
        geoOriginElement.setAttribute('geoCoords',num2str(geoOrig));
        geoOriginElement.setAttribute('rotateYUp',yUp);
        coordElement.appendChild(geoOriginElement);
    end
    
  if ~isempty(c)
      colorElement = xDoc.createElement('Color');
      colorElement.setAttribute('color',sprintf('%0.2f ',c(:)));
      ifsElement.appendChild(colorElement);
  end
    
  shapeElement.appendChild(ifsElement);
  sceneElement.appendChild(shapeElement);

rootElement.appendChild(sceneElement);



% xmlwrite(xDoc)
xmlwrite(fn,xDoc);

end

function [bstr] = boolean2str(b)
    if b
        bstr = 'true';
    else
        bstr = 'false';
    end
end
        
function [] = x3dindexedfaceset(fn,tri,x,y,z)

x = x-mean(x);
y = -(y-mean(y));
z = (z-min(z));

n = size(tri,1);

%%
coords = [x z y]';
coords = coords(:);
tri = [(tri-1) -1*ones(n,1)]';
tri = tri(:);
%%
defaultColor = [.4 .4 .1];

xDoc = com.mathworks.xml.XMLUtils.createDocument('X3D');
rootElement = xDoc.getDocumentElement;

rootElement.setAttribute('profile','Immersive');
rootElement.setAttribute('version','3.1');

  sceneElement = xDoc.createElement('Scene'); 
  rootElement.appendChild(sceneElement);
  
  lightElement = xDoc.createElement('PointLight');
  lightElement.setAttribute('color','1 1 1');
  lightElement.setAttribute('location','0 1000 0');
  lightElement.setAttribute('global','true');
  lightElement.setAttribute('ambientIntensity','.3');
  lightElement.setAttribute('on','true');
  lightElement.setAttribute('radius','100');
  lightElement.setAttribute('intensity','.9');
  sceneElement.appendChild(lightElement);
  
      % Define navigation elements and viewpoints
  navigationElement = xDoc.createElement('NavigationInfo');
    % Collision distance, camera height above ground, highest distance camera can walk over
    navigationElement.setAttribute('avatarSize','.5 1.6 1.6'); 
    navigationElement.setAttribute('type','ANY');
    navigationElement.setAttribute('speed','100');
  sceneElement.appendChild(navigationElement);
  
  
%   viewElement = xDoc.createElement('Viewpoint');
%     viewElement.setAttribute('description','Viewpoint 1');
%     viewElement.setAttribute('fieldOfView','0.7854');
%     viewElement.setAttribute('position',sprintf('% 1.2f',calculatedPosition));
%   sceneElement.appendChild(viewElement);
%   
  shapeElement = xDoc.createElement('Shape');
  
    appearanceNode = xDoc.createElement('Appearance');
    materialNode = xDoc.createElement('Material');
    materialNode.setAttribute('diffuseColor',sprintf('% 1.2f',defaultColor));
%     materialNode.setAttribute('emissiveColor',sprintf('% 1.2f',defaultColor));
    appearanceNode.appendChild(materialNode);
    shapeElement.appendChild(appearanceNode);
    
    ifsElement = xDoc.createElement('IndexedFaceSet');
    ifsElement.setAttribute('containerField','geometry');
    ifsElement.setAttribute('ccw','true');
    ifsElement.setAttribute('convex','true');
    ifsElement.setAttribute('creaseAngle','.5');
    ifsElement.setAttribute('normalPerVertex','true');
    ifsElement.setAttribute('solid','true');
    ifsElement.setAttribute('coordIndex',sprintf('% 10.0f',tri));
    
        coordElement = xDoc.createElement('Coordinate');
        coordElement.setAttribute('point',sprintf('% 10.2f',coords));
    ifsElement.appendChild(coordElement);
    
  shapeElement.appendChild(ifsElement);
  sceneElement.appendChild(shapeElement);

rootElement.appendChild(sceneElement);

% xmlwrite(xDoc)
xmlwrite(fn,xDoc);
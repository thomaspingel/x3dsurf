function [idx X Y Z] = dem2tin2(Z,R,minModelThickness)

%% Get the size, must be a surface (no multiband)
[r c] = size(Z);

% Define corners, clockwise from top left
topCorners = [sub2ind([r,c],[1 1 r r],[1 c c 1])];

% Reshape the matrices
[xi yi] = ir2xiyi(Z,R);
[X Y] = meshgrid(xi,yi);
X = X(:);
Y = Y(:);
Z = Z(:);
clear xi yi

% Connect DEM via delaunay triangulation; convert to cell array since
% we'll need to have more than 3 things connected later.
[idx] = delaunay(X,Y);
idx = num2cell(idx,2);

% Define base corners; add these vertices to the X Y Z vectors
bottomCorners = length(X)+1:length(X)+4;
X = [X; X(topCorners)];
Y = [Y; Y(topCorners)];
Z = [Z; repmat(min(Z)-minModelThickness,[4 1])];

% Add depth pieces to model (base & sides)
% Base
idx{length(idx)+1} = bottomCorners;
% Left
idx{length(idx)+1} = [sub2ind([r,c],r:-1:1,ones(1,r)) bottomCorners([1 4])];
% Bottom
idx{length(idx)+1} = [sub2ind([r,c],repmat(r,[1 c]),c:-1:1),bottomCorners([4 3])];
% Right
idx{length(idx)+1} = [sub2ind([r,c],1:r,repmat(c,[1 r])),bottomCorners([3 2])];
% Top
idx{length(idx)+1} = [sub2ind([r,c],ones(1,c),1:c),bottomCorners([2 1])];

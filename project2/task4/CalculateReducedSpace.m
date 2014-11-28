function CalculateReducedSpace( filelist, distanceMatrix, r)
%FASTMAP Summary of this function goes here
%   Detailed explanation goes here

% nXk where, At the end of the algorithm,
% the i-th row is the image of the i-th object.
global pivotArray result colNumber n originalMatrix stress;

originalMatrix = distanceMatrix;
[n,~] = size(distanceMatrix);
result = zeros(n,r);
stress = zeros(r,1);

%  stores the ids of the pivot objects - one pair per recursive call
pivotArray = zeros(2, r);

% points to the column of the X array currently being updated

colNumber = 0;

% Execute FastMap to get reduced space
FastMap(filelist, distanceMatrix, r);
disp('Please use global results to see the results\n');
end

function FastMap( fileList, distanceMatrix, r)

global pivotArray result colNumber n originalMatrix stress;
% If r<=0 means, the dimensionality is reduced to r. Return
if(r <= 0) 
    return;
end

% Increment the columnNumber with 1. Points to the next column in the
% result matrix and also the pivotArray.
colNumber = colNumber + 1;

% Choose pivot elements and fill in the pivot Array
[indexA, indexB] = ChooseDistantObjects(fileList, distanceMatrix);
pivotArray(1, colNumber) = indexA;
pivotArray(2, colNumber) = indexB;


% Get the index of objectA and objectB from filelist
%indexA = find(strcmp(fileList, objectA) == 0);
%indexB = find(strcmp(fileList, objectB) == 0);

% If the pivot objects(farthest points) are same, then all the distances
% will be 0.
if(distanceMatrix(indexA,indexB) == 0)
    for i=1:n
        result(i,colNumber) = 0;
    end    
end

% Calculate xi, which will be the representation of the objects in the 1-d
% in the x-dimension space.
for i=1:n    
    distAisq = power(distanceMatrix(indexA,i),2);
    distAB = distanceMatrix(indexA,indexB);
    distABsq = power(distAB,2);
    distBisq = power(distanceMatrix(indexB,i),2);
    xi = (distAisq + distABsq - distBisq)/ (2*distAB);
    result(i, colNumber) = xi;
end

tempDistanceMatrix = ConstructTempDistanceMatrix(distanceMatrix);
stress(colNumber,1) = Stress(originalMatrix);
fprintf('Stress in dimension %d is %f\n', colNumber,stress(colNumber,1));

FastMap(fileList, tempDistanceMatrix, r-1);
end

% Construct tempDistanceMatrix every iteration. This will be the distance
% measure in the new hyper plane.
function [tempDistanceMatrix] = ConstructTempDistanceMatrix(distanceMatrix)

global n result colNumber;
for i=1:n
    for j=1:n
        xi = result(i,colNumber);
        xj = result(j,colNumber);
        distIJ = distanceMatrix(i,j);
        distPrimeSquare = power(distIJ,2) - power((xi - xj),2); 
        tempDistanceMatrix(i,j) = sqrt(distPrimeSquare);
    end
end
end



function [ indexA, indexB ] = ChooseDistantObjects( objects, distanceMatrix)
% CHOOSEDISTANTOBJECTS Fetches the 2 distant objects in a given set of 
% objects.
%   Instead of iterating through every pair of objects in the given set,
% this function heuristically tries to find 2 distant objects.

% Generate a random index between 1 and n
% n = # of files


[n, ~] = size(objects);
index = randi(n);
objectB = objects(index);

indexA = FindFarthestObject(distanceMatrix, index); 
indexB = FindFarthestObject(distanceMatrix, indexA);

% Testing code by manually setting values for calculations and matching
% global colNumber;
% switch colNumber
%     case 1
%         indexA = 1;
%         indexB = 4;
%     case 2
%         indexA = 5;
%         indexB = 2;
%     case 3
%         indexA = 3;
%         indexB = 5;
% end
end

function [ index] = FindFarthestObject(distanceMatrix, pivotIndex)

% Find objectA which is farthest from objectB
global n;
maxDistance = realmin('double');
for i=1:n
    distance = distanceMatrix(pivotIndex, i);
    if(distance > maxDistance)
        maxDistance = distance;      
        index = i;
    end
end

end


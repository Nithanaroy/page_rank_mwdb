function [topk, indices] = Task4b(directory, file,r,k)
% Compute similarity between the new object and all other older objects
% Compute distance measure from similarity measure and add it to the
% distanceMatrix

% globals 
global n pivotArray result;

% Set up files list
% Get the filenames of all the files under the directory
filepath = fullfile(directory,'/*.csv');
% Get the list of all the csv files to be loaded.
filelist = dir(filepath);

distanceMatrix = CalculateDistanceInOriginalSpace(filelist,file);

% image - a vector of size r will hold the image of the new object in
% r-dimension space
image = zeros(1,r);
resultWithQuery = result;
tempDistanceMatrix = distanceMatrix;


for i = 1:r 
    
    % Get pivots in ith dimension
    indexA = pivotArray(1,i);
    indexB = pivotArray(2,i);
    % Calculate xi in ith dimension
    % This calculation of xi is same as the Fastmap reduced space
    % calculation. This is using the cosine rule in the triangle assumed to
    % be in vector space.
    distAisq = power(tempDistanceMatrix(indexA,n+1),2);
    distAB = tempDistanceMatrix(indexA,indexB);
    distABsq = power(distAB,2);
    distBisq = power(tempDistanceMatrix(indexB,n+1),2);
    image(1,i) = (distAisq + distABsq - distBisq)/ (2*distAB);
    resultWithQuery(n+1,i) = image(1,i);
    tempDistanceMatrix = ReCalculateDistanceMatrix(tempDistanceMatrix, resultWithQuery, i);
    
end

% Fetch topk similar files
[topk,indices] = GetTopkSimilar(filelist, image, k);
disp('Top k similar files are\n');
% display the file list
for i=1:k
    disp(filelist(indices(i)).name);
end

end

% Computes the distance from the new object to all other older objects
function [distanceMatrix] = CalculateDistanceInOriginalSpace(filelist, file)

global originalMatrix n;
distanceMatrix = originalMatrix;
disp('1. Euclidean Measure');
disp('2. DTW');
disp('3. Dot product Similarity Word');
disp('4. Dot product Similarity Avg File');
disp('5. Dot product Similarity Diff File');
disp('6. Similarity Weighted');
disp('7. Similarity Weighted for Avg File');
disp('8. Similarity Weighted for Diff File');
choice = input('Please select the similarity measure:');

% Compute the similarity between every other object in the distance Matrix
% to the new object.
for i = 1:n
    simMeasure = Similarity(filelist(i).name, file, choice);
    distance = ComputeDistanceFromSimilarity(simMeasure);
    distanceMatrix(i,n+1) = distance;
    distanceMatrix(n+1,i) = distance; % since distance are symmetric
    % If not, comment this line and use the for loop below.
end

% Compute the similarity between the new objet and every other object in
% the distance Matrix
% This might be different some times, due to DTW not being a symmetric
% for i = 1:n
%     simMeasure = Similarity(file,filelist(i).name, similarityMeasure);
%     distance = ComputeDistanceFromSimilarity(simMeasure);
%     distanceMatrix(n+1,i) = distance;
% end
distanceMatrix(n+1,n+1) = 0;

end

function [tempDistanceMatrix] = ReCalculateDistanceMatrix(olddistanceMatrix, resultWithQuery, colNumber)

global n ;
tempDistanceMatrix = zeros(n+1);

% Recalculate distance Matrix for the older documents
for i=1:n+1
    for j=1:n+1
        xi = resultWithQuery(i,colNumber);
        xj = resultWithQuery(j,colNumber);
        distIJ = olddistanceMatrix(i,j);
        distPrimeSquare = power(distIJ,2) - power((xi - xj),2); 
        tempDistanceMatrix(i,j) = sqrt(distPrimeSquare);
    end
end

end


function [topk, indices] = GetTopkSimilar(filelist, image, k)

global result n;

% If k is greater than n, then give out all the simulations.
if(k>n)
    disp('k was larger than number of simulations. Returning all n simulations');
    topk = filelist;
    return;
end

% topk array with k rows, 1st column index, 2nd column distance
% <index, distance>
distanceArray = zeros(n,1);

% Calculate the distance using Euclidean Distance Measure. This is
% calculated from the query to all the simulation files.
for i=1:n
    tempDistance = sqrt(sum((result(i,:) - image(1,:)) .^ 2));
    distanceArray(i,1) = tempDistance;
    %distanceArray(i,2) = i;
end

[sortedArray,sortedIndices]=sort(distanceArray(:,1));
topk = sortedArray(1:k,:);
indices = sortedIndices(1:k);

end
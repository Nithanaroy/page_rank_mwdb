function [ partition, codebook ] = gaussbands( r, orientation )
%GAUSSBAND Summary of this function goes here
%   Detailed explanation goes here

if ~exist('orientation', 'var')
    orientation = 0;
else
    orientation = logical(orientation);
end

bands = zeros(1,r);
ipoints = linspace(0, 1, r+1);

for i = 1:r
    lowerx = ipoints(i);
    upperx = ipoints(i+1);
    bands(i) = (integral(@(x)gaussf(x), lowerx, upperx))/0.5;
end

if orientation == 1
    bands = fliplr(bands);
end

sum = cumsum(bands);
partition = sum(1:r-1);
codebook = zeros(1,r);
codebook(1) = partition(1)/2;
for i = 2:r
    codebook(i) = partition(i-1) + bands(i)/2;
end
function[distance] = ComputeDistanceFromSimilarity(simMeasure)

% If simMeasure is 0, then provide an epsilon
if(simMeasure == 0)
    simMeasure = eps;
end

% If similarity measure is 1, which means both the objects are equal, then
% distance must be 0
distance = (1/simMeasure) -1;
end
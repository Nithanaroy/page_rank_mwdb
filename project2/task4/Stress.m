function [ stress ] = Stress( distanceMatrix )
%STRESSFUNCTION Summary of this function goes here
%   Detailed explanation goes here

global n;
% Stress is calculated mean square error. The exact formula is given in the
% report.
% newSum = 0;
sumDiff =0;
oriSum = 0;
for i=1:n
    for j=1:n
        % Calculate Difference of new and old distance
        oriDistance = distanceMatrix(i,j);        
        newDistance = GetDistanceInReducedSpace(i,j);
        difference = newDistance - oriDistance;
        
        % Take the square and sum them up
        sumDiff = sumDiff + difference^2;
        % Sum up the old distances as well.
        oriSum = oriSum + oriDistance^2;    
    end
end

if(oriSum == 0)
    oriSum = eps;
end
%Dividing both gives the stress.
stressSq = sumDiff/oriSum;
stress = sqrt(stressSq);
% 
% for i=1:n
%     for j=1:n
%         oriDistance = distanceMatrix(i,j);        
%         newDistance = GetDistanceInReducedSpace(i,j);       
%                
%         oriSum = oriSum + oriDistance;
%         newSum = newSum + newDistance ;
%     end
% end
% stress = oriSum - newSum;

end

function [distance] = GetDistanceInReducedSpace(i,j)
global result;

% Calculate the Euclidean distance between 2 rows
distance = sqrt(sum((result(i,:) - result(j,:)) .^ 2));
end

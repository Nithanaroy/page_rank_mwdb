function [ mat, states ] = parsedatafile( filename )
%PARSECSV Summary of this function goes here
%   Detailed explanation goes here
celldata = read_mixed_csv(filename, ',');
states = celldata(1, 3:end);
for si = 1:numel(states)
    s = char(states(si));
    states(si) = cellstr(s(end-1:end));
end
mat = str2double(celldata(2:end,3:end));
% timestamps = celldata(2:end, 2);
end
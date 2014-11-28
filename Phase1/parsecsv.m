function [ mat, states, timestamps ] = parsecsv( filename )
%PARSECSV Summary of this function goes here
%   Detailed explanation goes here
mat = getdatamatrix( filename );
celldata = read_mixed_csv(filename, ',');
states = celldata(1, 3:53);
timestamps = celldata(2:end, 2);
end
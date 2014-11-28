function [ mat ] = getdatamatrix( filename )
%getdatamatrix get the data values in the csv file
mat = csvread(filename, 1, 2);
end
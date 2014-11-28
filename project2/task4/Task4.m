function Task4(directory, r)
% This function performs the Task 4a. Given a set of objects(simulation
% files), simularity measure and r, maps the objects into an r dimensional
% space. Gives a matrix with the images of the n given objects in the
% r-dimensional space.

% Get the user input for the type of similarity measure to use.
disp('1. Euclidean Measure');
disp('2. DTW');
disp('3. Dot product Similarity Word');
disp('4. Dot product Similarity Avg File');
disp('5. Dot product Similarity Diff File');
disp('6. Similarity Weighted');
disp('7. Similarity Weighted for Avg File');
disp('8. Similarity Weighted for Diff File');
choice = input('Please select the similarity measure:');
originalDistanceMatrix = CreateOriginalDistanceMatrix(directory, choice);

CalculateReducedSpace(directory, originalDistanceMatrix, r);


end

function[originalDistanceMatrix] = CreateOriginalDistanceMatrix(directory, choice)

% Set up files list
% Get the filenames of all the files under the directory
filepath = fullfile(directory,'/*.csv');
% Get the list of all the csv files to be loaded.
filelist = dir(filepath);
% Get the number of objects - store it in n.
[n,~] = size(filelist);

% Create the original Distance Matrix as nxn
originalDistanceMatrix = zeros(n);

% Fill in the distance Matrix by calculating distance from the selected
% similarity measure

for i = 1:n
    for j = 1:n
        simMeasure = Similarity(filelist(i).name, filelist(j).name,choice);
        distance = ComputeDistanceFromSimilarity(simMeasure);
        originalDistanceMatrix(i,j) = distance;
    end
end

end

function [sim_measure] = Similarity(firstFile, secondFile, choice)
LOCATION_MATRIX = 'LocationMatrix.csv';
WIN_SEARCH_DIST = 0.02;

switch choice
    case 1
        %Select Euclidean Distance measure
        sim_measure = sim_task1(firstFile, secondFile,'euclidean_func');
    case 2
        % Select DTW Distance measure
        sim_measure = sim_task1(firstFile, secondFile,'dtw');
    case 3
        sim_measure = sim(firstFile, secondFile,'word_file');
    case 4
        sim_measure = sim(firstFile, secondFile, 'word_file_avg');
    case 5
        sim_measure = sim(firstFile, secondFile, 'word_file_diff');
    case 6
        sim_measure = sim_weighted( 'word_file', LOCATION_MATRIX, firstFile, secondFile, WIN_SEARCH_DIST);
    case 7
        sim_measure = sim_weighted( 'word_file_avg', LOCATION_MATRIX, firstFile, secondFile, WIN_SEARCH_DIST);
    case 8
        sim_measure = sim_weighted( 'word_file_diff', LOCATION_MATRIX, firstFile, secondFile, WIN_SEARCH_DIST);
    otherwise
end 
end

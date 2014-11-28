function [sim_matrix, a_matrix] = adj_matrix(sim_files_dir, threshold, sym_dist)

%Getting user input for similarity measure
disp('1. Euclidean Measure');
disp('2. DTW');
disp('3. Dot product Similarity Word');
disp('4. Dot product Similarity Avg File');
disp('5. Dot product Similarity Diff File');
disp('6. Similarity Weighted');
disp('7. Similarity Weighted for Avg File');
disp('8. Similarity Weighted for Diff File');
choice = input('Please select the similarity measure: ');

% Get all csv files in directory
files = dir(fullfile(sim_files_dir,'/*.csv'));
files_count = size(files, 1);

LOCATION_MATRIX = 'LocationMatrix.csv';
WIN_SEARCH_DIST = 0.02;

sim_matrix = zeros(files_count);

% Adjacency matrix
% There is an edge between two sim files (nodes) if their similarity
% measure beyond `threshold`
a_matrix = zeros(files_count);

%based on user input, create simulation simulation similarity matrix
for i=1:files_count
    
    if(sym_dist) % Compute only upper half of the matrix if distance is symmetric
        start = i + 1;
    else
        start = 1;
    end
    
    for j=start:files_count
        
        firstFile = files(i).name;
        secondFile = files(j).name;
        
        switch choice
            case 1
                sim_measure = sim_task1(firstFile, secondFile,'euclidean_func');
            case 2
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
                error('Incorrect option chosen. Run again.');
        end
        
        sim_matrix(i,j) = sim_measure; % sim_func(files(i).name, files(j).name, measureName);
    end
end

% Construct adjancency matrix using the threshold
for i = 1:files_count
    
    if(sym_dist) % Compute only upper half of the matrix if distance is symmetric
        start = i + 1;
    else
        start = 1;
    end
    
    for j = start:files_count
        if sim_matrix(i, j) > threshold
            a_matrix(i, j) = sim_matrix(i, j);
        end
    end
end

end
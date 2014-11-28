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
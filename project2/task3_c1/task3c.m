function [OutputV U S V] = task3c(sim_files_dir, r)
%This task will create simulation simulation similarity matrix and 
%extract top r latent semantics from SVD command
%Getting user input
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
%based on user input, create simulation simulation similarity matrix
m = zeros(files_count);
for i=1:files_count
    for j=1:files_count
        
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
        
        m(i,j) = sim_measure; % sim_func(files(i).name, files(j).name, measureName);
    end
end

% Karthick's code starts here
%SVD for simulation simulation similarity matrix
[U, S, V] = svd(m);
OutputV = V(1:r,:);

%Printing latent semantics from first r columns of U matrix
for i = 1:r
    fprintf('Latent semantics \t %d\n',i);
    for j = 1 : length(files)
        simulation{j} = files(j).name;
        
        h{j} = U(j,i:i);
        
    end
    columnResult = cell2mat(h);
    sortedResult = sort(columnResult,'descend');
    
    count = 1;
    for latentIndex = 1:length(sortedResult)
        for j = 1:length(h)
            if  sortedResult(latentIndex) == h{j}
                h{j}=111111111111;
                fprintf('%s  \t %f\n',simulation{j} , sortedResult(latentIndex));
                break;
            end
        end
    end
    
    
    
end

end
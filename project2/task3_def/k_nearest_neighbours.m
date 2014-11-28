function topk = k_nearest_neighbours(fq, inp_dir, nearest_k, r)
% Finds the K nearest neighbours for the given query file
%
% Logic: Transforms the query file into object feature matrix
% Calls the SVD, LDA or custom dimentionality reduction function (task 3c)
% Uses thetranformation vector obtained from either of the methods above
% and projects the query into the reduced space.
% All the input files are projected to reduced space and a similarity
% measure is used to find the K nearest simulations to query file
%
% Input:
% fq = query filename. Eg: 1.csv or 1 in character format
% inp_dir = input directory path where all simulation files are located
% nearest_k = 3 for finding 3 nearest neighbours for fq in inp_dir
% r = latent semantic
%
% Output:
% A 2D double array, having 'k' rows. For each row first column denotes
% the similarity value and second column denotes the filename

[~,name,ext] = fileparts(fq);
fq_name = strcat(name, ext);

files = dir(fullfile(inp_dir, '*.csv'));

disp('1. SVD');
disp('2. LDA');
disp('3. Sim-Sim SVD');
choice = input('Please select the dimentionality reduction measure: ');

% Call SVD or LDA or custom based on user choice and save latent sematics
switch choice
    case 1
        [U, V] = final3a('word_file', r);  % SVD
        cols = get_distinct_words();
        file1 = get_file_red_space(fq, cols);
    case 2
        [U, V, ~, ~] = final3b('word_file', r);  % LDA
        cols = get_distinct_words();
        file1 = get_file_red_space(fq, cols);
    case 3
%         data_dir = input('Directory path for creating sim-sim-simu matrix: ');
        [V, sim_matrix] = task3c(inp_dir, r);  % Custom
        file1 = get_file_red_space_for_custom(fq);
    otherwise
        error('Incorrect option chosen. Run again.');
end

sorted_unique_w1 = sort(unique(file1, 'rows'));

similarity_measures = zeros(size(files, 1), 2);
index = 1;
for file = files'
    if choice == 3
        file2 = get_file_red_space_for_custom(file.name);
    else
        file2 = get_file_red_space(file.name, cols);
    end
    
    sorted_unique_w2 = sort(unique(file2, 'rows')); % similarity measure, file (integer)
    
    similar_rows = 0;
    for k=1:size(sorted_unique_w1,1)
        j = 1;
        while j <= size(sorted_unique_w2, 1) && size( sorted_unique_w1(sorted_unique_w1(k,:) >= sorted_unique_w2(j,:)), 2 ) == size( sorted_unique_w1(k,:), 2 )
            if sorted_unique_w1(k,:) == sorted_unique_w2(j,:)
                similar_rows = similar_rows + 1;
                break;
            end
            j = j + 1;
        end
    end
    
    similarity_measures(index, 1) = similar_rows; % From this return the best nearest_k files
    similarity_measures(index, 2) = str2double(char(regexp(file.name, '^\d*', 'match'))); % From this return the best nearest_k files
    index = index + 1;
    % fprintf('(%s, %s) = %d\n', fq_name, file.name, similar_rows);
end

topk = sortrows(similarity_measures, [-1]);

topk = topk(1:nearest_k+1,:);
% topk = topk(1:nearest_k+1,2);

    function res = get_file_red_space_for_custom(filename)
        file1_name = char(regexp(filename, '^\d*', 'match'));
        for i = 1:size(files, 1)
            file2_name = char(regexp(files(i).name, '^\d*', 'match'));
            if  file1_name == file2_name
                file_index = i;
                break;
            end
        end
%         res = V * transpose(sim_matrix(floor(str2double(char(regexp(filename, '^\d*', 'match')))), :));
        res = V * transpose(sim_matrix(file_index, :));
    end

    function res = get_file_red_space(fq, cols)
            res = get_file_from_db(fq);
            
            fq_in_orig_space = zeros(1,size(cols, 2));
            
            for i = 1:size(cols, 1)
                fq_in_orig_space(i) = size(res(ismember(res,cols(i,:), 'rows'), :), 1);
            end

            res = V * transpose(fq_in_orig_space);
    end

    function wins = get_file_from_db(filename)
        javaaddpath('mongo-java-driver-2.12.3.jar');
        import('com.mongodb.*');
        mongoClient = MongoClient();
        db = mongoClient.getDB( 'epidemic' );
        coll = db.getCollection('word_file');
        
        filter = BasicDBObject();
        filter.put('f', char(regexp(filename, '^\d*', 'match')));
        project = BasicDBObject();
        project.put('win', 1);
        project.put('_id', 0);
        rows = coll.find(filter, project).toArray;
        
        win_size = size(strsplit(rows.get(1).get('win'), ' '), 2);
        wins = zeros(rows.size, win_size);
        temp = zeros(1, win_size);
        for i = 1: rows.size
            row = strsplit(rows.get(i-1).get('win'), ' ');
            for j = 1:win_size
                temp(j) = str2double(row{j});
            end
            wins(i,:) = temp;
        end
        
        mongoClient.close();
    end

    function wins = get_distinct_words()
        javaaddpath('mongo-java-driver-2.12.3.jar');
        import('com.mongodb.*');
        mongoClient = MongoClient();
        db = mongoClient.getDB( 'epidemic' );
        coll = db.getCollection('word_file');
        
        project = BasicDBObject();
        project.put('win', 1);
        project.put('_id', 0);
        rows = coll.find([], project).toArray;
        
        win_size = size(strsplit(rows.get(1).get('win'), ' '), 2);
        wins = zeros(rows.size, win_size);
        temp = zeros(1, win_size);
        for i = 1: rows.size
            row = strsplit(rows.get(i-1).get('win'), ' ');
            for j = 1:win_size
                temp(j) = str2double(row{j});
            end
            wins(i,:) = temp;
        end
        
        wins = unique(wins, 'rows');
        
        mongoClient.close();
    end

end
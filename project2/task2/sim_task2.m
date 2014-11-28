
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% param1 (string)   is the name of the original csv file to compare
% param2 (integer)  is the number of k neighbors to find for the search
% param3 (string)   is the name of the function to use to find similarity. There
%   is a finite set of these functions. Here are all possible:
%       euclidean_func
%       dtw
%       sim_word
%       sim_word_avg
%       sim_word_diff
%       sim_weighted
%       sim_weighted_avg
%       sim_weighted_diff
%
% param4 (string)   is the directory that contains the csv files. 
%   IMPORTANT:  You must include the trailing '/' or '\' (depending
%   on your OS) in this string. 
%   IMPORTANT2: The location matrix (e.g. LocationMatrix.csv) must be 
%   in the MatLab path when running this function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = sim_task2( comp_file_name, top_k, comp_function, epidemic_file_dir )

    LOCATION_MATRIX = 'LocationMatrix.csv';
    WIN_SEARCH_DIST = 0.02;
    EPIDEMIC_FILE_DIR = epidemic_file_dir;
    
    DELIMITER = ',';
    EPIDEMIC_FILE_SUFFIX = '*.csv';
    
    STATE_NAME_STARTING_INDEX = 3;
    % This is the row that contains the state names for all input files
    STATE_NAME_ROW_INDEX = 1;
    % This is the starting row for the data for all input files
    DATA_STARTING_ROW = 2;
    % This is the starting column for the data for all input files
    DATA_STARTING_COLUMN = 3;

    
    
    disp('-----------------------------------------------');
    disp('Test parameters:');
    fprintf('Files to analyze: %s\n', EPIDEMIC_FILE_DIR);
    fprintf('Top k: %d\n', top_k);
    fprintf('File to compare: %s\n', comp_file_name);
    disp('-----------------------------------------------');
    
    epidemic_files = dir(strcat(EPIDEMIC_FILE_DIR, EPIDEMIC_FILE_SUFFIX));
    
    file_value_map = containers.Map();
    file_name_array = {};
    state_name_array = [];
    
    % This is where will will iterate over every file in the epidemic file
    % directory and gather the information.
    for index = 1:length(epidemic_files)
        file_name = epidemic_files(index).name;
        file_name_array = [file_name_array, file_name];
        % Getting the full name of the file we're going to read
        full_file_name = strcat(EPIDEMIC_FILE_DIR, char(epidemic_files(index).name));
    
        % This function will read in both numerical and string values from the
        % csv. After they are read in, they must be converted to the proper
        % data type (if they are not string).
        csv_file = read_mixed_csv(full_file_name, DELIMITER);
        
        % This will get me the complete list of states in this file. There are
        % some assumptions that are made, in that the the index of the row and
        % the column number where the state names start is defined prior to
        % reading.
        states = csv_file(STATE_NAME_ROW_INDEX, STATE_NAME_STARTING_INDEX:end);
    
        state_name_array = states;
        % Now I'm going to read the data in the file and convert it all to type
        % 'double'
        file_values_matrix = str2double(csv_file(DATA_STARTING_ROW:end, DATA_STARTING_COLUMN:end));
        disp(file_name);
        for column_index = 1:length(states)
            state_name = states(column_index);
            
            file_value_map(strcat(file_name, DELIMITER, state_name{1})) = file_values_matrix(:,column_index);
        end;
        
    end;
    
    result_matrix = [];
    % The euclidean and dtw functions are very similar in that they both
    % operate on the original csv files.
    if(strcmp('euclidean_func', comp_function) == 1 || strcmp('dtw', comp_function) == 1)
        file_handle = str2func(comp_function);
        
        % Iterate over the files in the csv directory
        for file_name_index = 1:length(file_name_array)
            running_total = 0.0;

            file_name = file_name_array(file_name_index);
            if strcmp(file_name,comp_file_name) == 1
                continue;
            end;
        
            % Iterate over the states and get the average
            for state_index = 1: length(state_name_array)
                map_index1 = strcat(comp_file_name, DELIMITER, state_name_array(state_index));
                map_index2 = strcat(file_name, DELIMITER, state_name_array(state_index));
                value_vector1 = file_value_map(map_index1{1});
                value_vector2 = file_value_map(map_index2{1});
            
                running_total = running_total + file_handle(value_vector1, value_vector2);
            end;
            if ~isempty(state_name_array)
                similarity_value = 1 / (1 + (running_total / length(state_name_array)));
            end;
        
            result_matrix = [result_matrix;[ similarity_value, file_name]];
        end;
    else
        % If we're here, then we're comparing values after the csv files
        % have been processed
        for file_name_index = 1:length(file_name_array)

            file_name = file_name_array(file_name_index);
            if strcmp(file_name,comp_file_name) == 1
                continue;
            end;
            
            % The DB doesn't store the file suffix... for some reason
            parsed_comp_file = strtok(comp_file_name, '.');
            parsed_file = strtok(file_name, '.');
            
            if(strcmp('sim_word', comp_function) == 1)
                similarity_value = sim_word( parsed_comp_file, parsed_file{1});
            elseif(strcmp('sim_word_avg', comp_function) == 1)
                similarity_value = sim_word_avg( parsed_comp_file, parsed_file{1});
            elseif(strcmp('sim_word_diff', comp_function) == 1)
                similarity_value = sim_word_diff( parsed_comp_file, parsed_file{1});
            elseif(strcmp('sim_weighted', comp_function) == 1)
                similarity_value = sim_weighted( 'word_file', LOCATION_MATRIX, parsed_comp_file, parsed_file{1}, WIN_SEARCH_DIST);
            elseif(strcmp('sim_weighted_avg', comp_function) == 1)
                similarity_value = sim_weighted( 'word_file_avg', LOCATION_MATRIX, parsed_comp_file, parsed_file{1}, WIN_SEARCH_DIST);
            elseif(strcmp('sim_weighted_diff', comp_function) == 1)
                similarity_value = sim_weighted( 'word_file_diff', LOCATION_MATRIX, parsed_comp_file, parsed_file{1}, WIN_SEARCH_DIST);
            end;
            
            result_matrix = [result_matrix;[ similarity_value, file_name]];
        end;
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Dealing with similarity results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sort by first field "name"
    result_matrix = sortrows(result_matrix, 1);
    result_matrix_size = size(result_matrix);
    result = result_matrix(result_matrix_size(1)-(top_k-1):end,:);
    %celldisp(result);

    final_result_matrix = cell2mat(result(:,1));
    
    final_result_matrix = [final_result_matrix, cell2mat(result(:,1))];
    final_result_matrix_size = size(final_result_matrix);
    imagesc(final_result_matrix);
    
    % Add text for euclidean results
    set(0, 'DefaulttextInterpreter', 'none');
    text(1,0.4,comp_function);
    for filename_index = 1:final_result_matrix_size(1)
        text(1,filename_index, result(filename_index, 2));
    end;
    
end



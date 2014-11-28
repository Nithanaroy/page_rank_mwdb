%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function loads 2 original data files (csv) and compares them
% by using a data function name that is passed in. It will print and
% return a similarity value. 
%   param1 is the name of the first file to compare (e.g. '10.csv')
%   param2 is the name of the second file to compare (e.g. '2.csv')
%   param3 is the name of the distance function to use. There are 
%   two options at the moment:
%       'euclidean_func'
%       'dtw'
%
% This function assumes that the directory that contains the csv files
% is in the matlab path. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function similarity_value = sim_task1(f1, f2, dist_fn)
    DELIMITER = ',';
    
    STATE_NAME_STARTING_INDEX = 3;
    % This is the row that contains the state names for all input files
    STATE_NAME_ROW_INDEX = 1;
    % This is the starting row for the data for all input files
    DATA_STARTING_ROW = 2;
    % This is the starting column for the data for all input files
    DATA_STARTING_COLUMN = 3;
    
    disp('-----------------------------------------------');
    disp('Test parameters:');
    fprintf('File 1 name: %s\n', f1);
    fprintf('File 2 name: %s\n', f2);
    fprintf('Distance function name: %s\n', dist_fn);
    disp('-----------------------------------------------');
    
    file_handle = str2func(dist_fn);
    
    filename1 = f1;
    csv_file1 = read_mixed_csv(filename1, DELIMITER);
    
    file1_value_map = containers.Map();
    % This will get me the complete list of states in this file. There are
    % some assumptions that are made, in that the the index of the row and
    % the column number where the state names start is defined prior to
    % reading.
    states = csv_file1(STATE_NAME_ROW_INDEX, STATE_NAME_STARTING_INDEX:end);
    
    % Now I'm going to read the data in the file and convert it all to type
    % 'double'
    file_values_matrix = str2double(csv_file1(DATA_STARTING_ROW:end, DATA_STARTING_COLUMN:end));
    % The outer loop that will iterate through each state
    for column_index = 1:length(states)
        state_name = states(column_index);
        file1_value_map(state_name{1}) = file_values_matrix(:,column_index);
    end
    
    % Same logic as before, but we won't be putting the second file
    % information into a map
    filename2 = f2;
    csv_file2 = read_mixed_csv(filename2, DELIMITER);
    states = csv_file2(STATE_NAME_ROW_INDEX, STATE_NAME_STARTING_INDEX:end);
    file_values_matrix = str2double(csv_file2(DATA_STARTING_ROW:end, DATA_STARTING_COLUMN:end));
    
    % We need a running total to get the average over the different states
    running_total = 0.0;
    for column_index = 1:length(states)
        state_name = states(column_index);
        file1_state_values = file1_value_map(state_name{1});
        file2_state_values = file_values_matrix(:,column_index);
        % Depending on the function name passed in, that's what we'll call
        % to get the distance measure
        running_total = running_total + file_handle(file1_state_values, file2_state_values);
    end
    
    % Avoiding a divide by zero error
    if ~isempty(states)
        similarity_value = 1 / (1 + (running_total / length(states)));   
    end
    
    % DEBUG print line
    fprintf('Similarity value: %.10f\n',similarity_value);

end
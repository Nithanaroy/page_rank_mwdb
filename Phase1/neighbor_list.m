function nblist = neighbor_list( location_matrix_filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[~,~,ext] = fileparts(location_matrix_filename);

if strcmpi(ext, '.xlsx')
    [nbmat, gtext, ~] = xlsread(location_matrix_filename);
    statenames = gtext(1, 2:end);
else strcmpi(ext, '.csv')
    celldata = read_mixed_csv(location_matrix_filename, ',');
    statenames = celldata(1, 2:end);
    nbmat = str2double(celldata(2:end,2:end));
end

nblist = struct();

for si = 1:numel(statenames)
    currentState = char(statenames(si));
    neighborIdxes = find(nbmat(si,:) == 1);
    numNeighbors = numel(neighborIdxes);
    neighborNames = cell(1, numNeighbors);
    
    if numNeighbors > 0
        for ni = 1:numNeighbors
            neighborNames(ni) = statenames(neighborIdxes(ni));
        end
    end
    
    nblist.(currentState) = neighborNames;
end
end


function [ranks, topk_values, topk_nodes] = personalized_page_rank2(K, q1, q2, sim_files_dir, p, threshold, assume_symm_dist, D)

    tolerance = 1e-8;
    converge_tolerance = 1e-1;

    files = dir(fullfile(sim_files_dir,'/*.csv'));
    nodes_count = size(files, 1);
    
    javaaddpath('mongo-java-driver-2.12.3.jar');
    import('com.mongodb.*');
    mongoClient = MongoClient();
    db = mongoClient.getDB( 'epidemic' );
    coll = db.getCollection('word_file');

    distinct_windows = sortrows(db_object_to_array(coll.distinct('win').toArray()));
    
    mmg = zeros(nodes_count + size(distinct_windows, 1));
    
    if(D)
        mmg = [1,0,0.678881660945381,0,0.537028855489255,1,0,1;0,1,0,0.664939236220188,0,1,0,1;0.678881660945381,0,1,0,0.719067432876597,1,1,0;0,0.664939236220188,0,1,0,1,1,0;0.537028855489255,0,0.719067432876597,0,1,1,1,0;1,1,1,1,1,1,0.900000000000000,0.800000000000000;0,0,1,1,1,0.900000000000000,1,0.900000000000000;1,1,0,0,0,0.800000000000000,0.900000000000000,1];
    else
        % Map files and windows
        for file = 1:nodes_count
            filter = BasicDBObject();
            filter.put('f', num2str(file));
            rows = db_object_to_array(coll.distinct('win', filter).toArray());

            [~, indices] = ismember(rows, distinct_windows, 'rows');
            mmg(file, indices + nodes_count) = 1;
        end

        % Map files to files based on similarity and threshold
        [~, mmg(1:nodes_count, 1:nodes_count)] = adj_matrix(sim_files_dir, threshold, assume_symm_dist);

        % Map windows and files. Just copying the top-right to bottom-left
        mmg(nodes_count + 1: end, 1:nodes_count) = transpose(mmg(1:nodes_count, nodes_count+1:end));

        % Map windows to windows: exact match % or euclidean distance
        map_windows_to_windows();
    end
    
    % MMG Algo
    vq = form_reset_vector();
    normalize_mmg();
    uq = vq;
    while(true)
        temp = p * mmg * uq + (1-p) * vq;
        if temp - uq < converge_tolerance
            uq = temp;
            break;
        end
        uq = temp;
    end

    ranks = uq(1:nodes_count); % only consider simulation files as others are features (distinct widnows)
    [sorted_ranks, sorted_ranks_indices] = sort(ranks, 'descend');
    topk_values = sorted_ranks(1:K);
    
    ranked_nodes = extract_file_names_as_nums(files((sorted_ranks_indices)));
    topk_nodes = ranked_nodes(1:K);
    
    % x-axis - simulation file names
    % y-axis - their corresponding proabilities (ranks)
    bar(topk_nodes, topk_values);
    
    close(mongoClient);
    
    function normalize_mmg
        total_nodes = nodes_count + size(distinct_windows, 1);
        uniform_prob_value = 1 / total_nodes;
        for i = 1:total_nodes
            col_sum = sum(mmg(:,i));
            if col_sum > 0
                % normalizing, so that the sum of all values in a col equals 1
                mmg(:,i) = mmg(:,i) / sum(mmg(:,i));
            else
                % If cursor reaches here, it implies this node is a sink as
                % probability of reaching any other node from here is zero as
                % indicated by `col_sum`
                mmg(:,i) = mmg(:,i) + uniform_prob_value; % removing sink nodes, by adding equal probability to all nodes
            end
        end
    end
    
    function vq = form_reset_vector
        vq = zeros(nodes_count + size(distinct_windows, 1), 1); 
        filenames = extract_file_names_as_nums(files);

        q1 = str2double(char(regexp(q1, '^\d*', 'match')));
        [~, indices] = ismember(q1, filenames);
        vq(indices) = 0.5;

        q2 = str2double(char(regexp(q2, '^\d*', 'match')));
        [~, indices] = ismember(q2, filenames);
        vq(indices) = 0.5;
    end
    
    function names = extract_file_names_as_nums(files)
        names = zeros(1, size(files, 1));
        for i = 1:size(files, 1)
            names(i) = str2double(char(regexp(files(i).name, '^\d*', 'match')));
        end
    end
    
    function map_windows_to_windows
        windows_count = size(distinct_windows, 1);
        for k = 1:windows_count
            for l = 1:windows_count
                if l == k
                    mmg(nodes_count + k, nodes_count + l) = 1;
                elseif l < k
                    % as the distance measure used between two windows is
                    % symmetric
                    mmg(nodes_count + k, nodes_count + l) = mmg(nodes_count + l, nodes_count + k);
                else
                    mmg(nodes_count + k, nodes_count + l) = get_exact_window_percent_match(distinct_windows(k, :), distinct_windows(l, :));
                    %                     mmg(nodes_count + k, nodes_count + l) = euclidean_func(distinct_windows(k, :), distinct_windows(l, :));
                end
            end
        end
    end
    
    function res = get_exact_window_percent_match(win1, win2)
        res = 0;
        for i = 1:win_size
            if abs(win1(i) - win2(i)) < tolerance
                res = res + 1;
            end
        end
        res = res / win_size;
    end
    
    function wins = db_object_to_array(rows)
        win_size = size(strsplit(rows(1), ' '), 2);
        wins = zeros(rows.length, win_size);
        temp = zeros(1, win_size);
        for i = 1: rows.size
            row = strsplit(rows(i), ' ');
            for j = 1:win_size
                temp(j) = str2double(row{j});
            end
            wins(i,:) = temp;
        end
    end
    
end
function [ranks, topk_values, topk_nodes] = page_rank_with_restart(q1, q2, k, p, sim_files_dir, threshold, assume_symm_dist, D)

    files = dir(fullfile(sim_files_dir,'/*.csv'));
    nodes_count = size(files, 1);
    reset_matrix = zeros(nodes_count);
    
    index = get_index_for_file(files, q1);
    reset_matrix(index, :) = 0.5;
    index = get_index_for_file(files, q2);
    reset_matrix(index, :) = 0.5;

    [ranks, topk_values, topk_nodes] = random_walk(k+2, p, sim_files_dir, reset_matrix, threshold, assume_symm_dist, D);

    function index = get_index_for_file(files, query)
        for i = 1:size(files, 1)
            if files(i).name == query
                index = i;
                break;
            end
        end
    end
    
end
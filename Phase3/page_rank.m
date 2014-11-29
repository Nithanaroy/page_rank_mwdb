function [ranks, topk_values, topk_nodes] = page_rank(k, p, sim_files_dir, threshold, assume_symm_dist, D)

    files = dir(fullfile(sim_files_dir,'/*.csv'));
    nodes_count = size(files, 1);
    uniform_prob = 1 / nodes_count;
    reset_matrix = zeros(nodes_count) + uniform_prob;
    
    [ranks, topk_values, topk_nodes] = random_walk(k, p, sim_files_dir, reset_matrix, threshold, assume_symm_dist, D);
    
end
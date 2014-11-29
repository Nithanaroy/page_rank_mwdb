function [ranks, topk_values, topk_nodes] = page_rank(k, p, sim_files_dir, threshold, assume_symm_dist, D)

    tolerance = 1e-8;

    m_without_sinks = markovian_matrix(sim_files_dir, threshold, assume_symm_dist, D);
    
    nodes_count = size(m_without_sinks, 1);
    uniform_prob = 1 / nodes_count;
    reset_matrix = zeros(nodes_count) + uniform_prob;
    
    m1 = p * m_without_sinks + (1-p) * reset_matrix; % M* = p X (M * Z) + (1-p) X K
    [eigen_vector, eigen_values] = eig(m1);
    
    % As m1 is a stochastic matrix, first coloumn of eigen vector is the
    % principal eigen vector
    assert(abs(eigen_values(1,1) - 1) < tolerance); % if this is not true something is wrong
    ranks = eigen_vector(:, 1) / sum(eigen_vector(:, 1)); % normalized probabilities
    
    [sorted_ranks, sorted_ranks_indices] = sort(ranks, 'descend');
    topk_values = sorted_ranks(1:k);
    
    files = dir(fullfile(sim_files_dir,'/*.csv'));
    ranked_nodes = files((sorted_ranks_indices));
    topk_nodes = ranked_nodes(1:k);
end
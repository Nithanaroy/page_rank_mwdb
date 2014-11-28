function prob_matrix = markovian_matrix(sim_files_dir, threshold, sym_dist, D)

    if(D) % Debug mode, mock the function calls
        a_matrix = [0,0,0.678881660945381,0,0.537028855489255;0,0,0,0.664939236220188,0;0,0,0,0,0.719067432876597;0,0,0,0,0;0,0,0,0,0];
    else
        [~, a_matrix] = adj_matrix(sim_files_dir, threshold, sym_dist);
    end
    
    prob_matrix = transpose(a_matrix);
    
    %Convert prob_matrix to stochastic matrix
    nodes_count = size(prob_matrix, 2);
    uniform_prob_value = 1 / nodes_count;
    for i = 1:nodes_count
        col_sum = sum(prob_matrix(:,i));
        if col_sum > 0
            prob_matrix(:,i) = prob_matrix(:,i) / sum(prob_matrix(:,i));
        else
            prob_matrix(:,i) = prob_matrix(:,i) + uniform_prob_value;
        end
    end
end
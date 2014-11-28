function [ distance ] = euclidean_func(value_vector1, value_vector2)
    distance = sqrt(sum((value_vector1 - value_vector2) .^ 2));
end


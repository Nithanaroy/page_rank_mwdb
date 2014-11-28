function normedmat = normmat( mat )
% Normalize all numbers in mat so they lie between 0 and 1
% Input arguments:
% 	mat - Data matrix
% Output arguments:
% 	normedmat - Normalized data matrix

normedmat = (mat-min(mat(:))) ./ (max(mat(:)-min(mat(:))));
end
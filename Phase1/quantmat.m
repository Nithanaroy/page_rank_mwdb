function quantizedmat = quantmat( normedmat, r, align )
% Quantize all values in normedmat into r bands.
% Input arguments:
%     normmat - Normalized data matrix
%     r - Num of Gaussian bands
%     align - First band alignment, 0 or 1
% Output arguments:
%     quantizedmat - Quantized data matrix

if ~exist('orientation', 'var')
    align = 0;
else
    align = logical(align);
end

[ partition, codebook ] = gaussbands( r, align );
[~, quantizedmat] = quanti(normedmat, partition, codebook);

end
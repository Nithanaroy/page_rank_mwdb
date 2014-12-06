% epidemic_words( directory, w, h, r, align )
% win_avg( epidemic_word_file, G, alpha )
% win_diff( epidemic_word_file, G )

w = 10; % Window length
h = 10; % Shift length
r = 5;  % Quantization resolution/bands

word = epidemic_words( 'data', w, h, r, 0 );
% win_avg( word, 'LocationMatrix.csv', 1 );
% win_diff( word, 'LocationMatrix.csv')

LOCATION_MATRIX = 'LocationMatrix.csv';
WIN_SEARCH_DIST = 0.02;

warning off
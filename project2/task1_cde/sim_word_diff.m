function similar_rows = sim_word_diff(f1, f2)
% Finds the similarity score betwen f1 and f2 by counting the number of
% common words in their corresponding epedemic word difference files
%
% Input:
% f1: file 1's name. Eg: 1.csv or 1 in character format
% f2: file 2's name. Eg: 1.csv or 1 in character format
%
% Output:
% A similarity score between f1 and f2 using their word difference files

similar_rows = sim(f1, f2, 'word_file_diff');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is a helper function to run task 2.
% param1 (string)   is the name of the original csv file to compare
% param2 (integer)  is the number of k neighbors to find for the search
% param3 (string)   is the name of the function to use to find similarity. There
%   is a finite set of these functions. Here are all possible:
%       euclidean_func
%       dtw
%       sim_word
%       sim_word_avg
%       sim_word_diff
%       sim_weighted
%       sim_weighted_avg
%       sim_weighted_diff
%
% param4 (string)   is the directory that contains the csv files. 
%   IMPORTANT: You must include the trailing '/' or '\' (depending
%   on your OS) in this string. 
%   IMPORTANT2: The location matrix (e.g. LocationMatrix.csv) must be 
%   in the MatLab path when running this function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sim_task2('7.csv',5, 'euclidean_func', 'data/');
%sim_task2('7.csv',5, 'dtw', 'data/');

%sim_task2('7.csv',5, 'sim_word', 'data/');
%sim_task2('7.csv',5, 'sim_word_avg', 'data/');
%sim_task2('7.csv',5, 'sim_word_diff', 'data/');
%sim_task2('7.csv',5, 'sim_weighted', 'data/');
%sim_task2('7.csv',5, 'sim_weighted_avg', 'data/');
%sim_task2('7.csv',5, 'sim_weighted_diff', 'data/');
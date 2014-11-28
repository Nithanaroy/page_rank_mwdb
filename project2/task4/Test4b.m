function [indices] = Test4b(k)

filepath = fullfile('data','/*.csv');
% Get the list of all the csv files to be loaded.
filelist = dir(filepath);
% Get the number of objects - store it in n.
[n,~] = size(filelist);
% Test for 4b, to fetch the topk
distances = zeros(n,1)
for i=1:n
    distances(i,1) = sim_task1(filelist(i).name,'query.csv','euclidean_func');
end

% Fetch the topk similar files
[sortedArray,sortedIndices]=sort(distances(:,1),'descend');
topk = sortedArray(1:k,:);
indices = sortedIndices(1:k);

for i=1:k
    disp(filelist(indices(i)).name);
end

end
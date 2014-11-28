

Readme file:

Preprocess all the datasets using dataprep folder to create epidemic word file,
epidemic average file and epidemic difference files.

dataprep.m -> will create all the data in the MongoDB collection

Task 1:
-------
a-b)
function similarity_value = sim_task1(f1, f2, dist_fn)
OUTPUT
    similarity_value: The similarity between f1 and f2. This value is
    between 0 and 1.
INPUT
    f1, f2:  The name of the file in the collection with suffix (e.g.
             '2.csv')

    dist_fn: The name of the distance function to use. Only two values
             are allowed: 'euclidean_func' and 'dtw'.
Sample Data : sim_task1('11.csv','12.csv','euclidean_func');
Sample data : sim_task1('11.csv','12.csv','dtw');

c-e)
The same function can do a distance comparison by epidemic word file or average file or difference file.

function similar_rows = sim(f1, f2, mongo_collection)
OUTPUT
    A similarity score between f1 and f2 found using the given mongo table.
INPUT
    f1, f2:  The name of the file in the collection with or without suffix (e.g.
             '2.csv')

    mongo_collection: The name of the mongo collection to use. Only three values
             are allowed: 'word_file', 'word_file_diff' and 'word_file_avg'.
Sample : sim_word('5', '15');

f-h)
similarity = sim_weighted( collection, location_matrix_filename, f1, f2, win_search_dist)

OUTPUT
    similarity: the weighted similar of f1 and f2, between 0 to 1
INPUT
	collection: name of the collection e.g. 'word_file', 'word_file_avg', 'word_file_diff'
	location_matrix_filename: name of the state location matrix file e.g. 'LocationMatrix.csv', 'LocationMatrix.xlsx'
	f1 f2: name of the file in the collection e.g. '1', '2'
	win_search_dist: cosine distance range for searching a matching win e.g. 0, 0.02


Sample : sim_weighted( 'word_file', 'LocationMatrix.csv', '1', '4', 0.02)
Sample : sim_weighted( 'word_file_avg', 'LocationMatrix.csv', '1', '4', 0.02)
Sample : sim_weighted( 'word_file_diff', 'LocationMatrix.csv', '1', '4', 0.02)

Task 2:
-------
This function runs the distance comparison between one file and all of the other files to find the k nearest neighbors.
sim_task2( comp_file_name, top_k, comp_function, epidemic_file_dir )
OUTPUT
    No output values, but this function does present a heatmap to the user.
INPUT
    comp_file_name: The file name in which the user wants to find the
    k neighbors.
    top_k:             The number of closest neighbors to find.
    comp_function:     This is the comparison function to use. There is
                       a finite set of strings that can be used for this 
                       parameter. They will be listed below.
    epidemic_file_dir: The file directory that contains all of the 
                       original csv files. IMPORTANT: You must include the 
                       trailing '/' or '\' (depending on your OS) in this 
                       string.

Sample : sim_task2('7.csv',5, 'dtw', 'data/');

Task 3:
-------
Task 3a:  [U S V outputV ]  = final3a(collection, r);
This function will take mongo collection name and r as input and it will print (simulation,score) to the console after doing SVD.
Input: Here word_file is the collection name where epidemic word file is stored and 
it could also take word_file_avg(average file) and word_file_diff(difference file)

Output for function: Output of object feature matrix from SVD command is returned 
as U S V. outputV is (r X number of features) from V matrix.

Output for task 3a is printed in console as (simulation, score) format.

Sample :  [U S V outputV ]  = final3a('word_file', 4);
Here we gave inpur r as 4 and collection name as 'word_file' where epidemic word file
will get stored as part of preprocessing step. You can see the output in (simulation, score) format printed in console using fprintf.

Task 3b: [ DocProb wordProb DP WP]  = final3b(collection, r);

This function will take mongo collection name and r as input and it will print
(simulation, score) in topics.txt file after doing LDA.

Here word_file is the collection name where epidemic word file is stored and it
could also take word_file_avg(average file) and word_file_diff(difference file)

DocProb is (number of objects X r) matrix where it will describe probabilistic
value for each document for r topics.

wordProb is (number of features X r) matrix where it will describe probabilistic
value for each object for r topics.

DP(i,j) contains the number of times a word in document d has been assigned to topic j. 

WP(i,j) contains the number of times word i has been assigned to topic j. 
Sample: [ DocProb wordProb DP WP]  = final3b('word_file', 4);

Here we gave input r as 4 and collection name as 'word_file' where epidemic word file
will get stored as part of preprocessing step. You can see the output in (simulation, score) format in topics.txt file.

Task 3c : 

[OutputV U S V] = task3c(sim\_files\_dir, r);

Sim\_files\_dir represents the directory where all the epidemic simulation files will be kept
and r is the input for which top r latent semantics should be extracted.

U S V are the matrices output by doing SVD of simulation-simulation similarity matrix.
outputV is r X number of features from V matrix.
Sample : [OutputV U S V] = task3c('data', 4);

This task will get the directory and r as input. Output will be top r latent semantics for simulation-simulation similarity matrix.

Task 3d-f
This task allows the user to use any similarity measure that they choose, along with the file name in which to find the k nearest neighbors, as well as defining k as an integer.

k_nearest_neighbours('21', 'data', 2, 4);

Task 4a 
--------
Performs dimensionality reduction. Takes directory path of the simulation files and the number of dimensions k.
To execute Task 4a on Matlab
 Task4('data',k); 
where data- directory path
and k - number of required dimensions
The program provides a user prompt for selection of the similarity measure.
The program provides the output of stress at every iteration

Sample Output command
Task4('data',10);
 Task 4b assumes Task4a has already executed. Task4b provides an interface, which given a data directory with .csv files, a
INPUT
[topk,indices] = Task4b('data','query.csv',10,10)
Specifies that the data objects or the simulation files present under directory data will be reduced to 10 dimensions.
OUTPUT
Provides the stress after each iteration as output.
global result provides the reduced dimension mapping.


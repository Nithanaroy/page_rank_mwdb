System requirements/installation 
================================

- MatLab 2013b
- Java
- MongoDB 2.6


Execution instructions
=======================
Execute command in shell:

    mongod

Open MatLab and go to the directory with the mat files.

Execute the task functions individually according to interface specifications.


## Task 1

    epidemic_word_file = epidemic_words( directory, w, h, r, align )

Create an epidemic_word_file, given a directory dir, window length w, a shift length h, and a resolution r.

Input arguments:

-  directory - Directory of csv data files
-  w - Window length
-  h - Shift length
-  r - Quantization resolution/bands

Output arguments:

-  epidemic_word_file - Struct array of idx-win pairs


## Task 2.1

    epidemic_word_file_avg = win_avg( epidemic_word_file, G, alpha )

Create epidemic_word_file_avg, given a connectivity graph G, and epidemic_word_file, and weight, 0 <= a <= 1.

Input arguments:

-  epidemic_word_file - Struct array of idx-win pairs
-  G - Connectivity graph in xlsx format
-  alpha - Weight

Output arguments:

-  epidemic_word_file_avg - Struct array of idx-win pairs


## Task 2.2

    epidemic_word_file_diff = win_diff( epidemic_word_file, G )

Create epidemic_word_file_diff, given a connectivity graph G, and epidemic_word_file.

Input arguments:

-  epidemic_word_file - Struct array of idx-win pairs
-  G - Connectivity graph in xlsx format

Output arguments:

-  epidemic_word_file_diff - Struct array of idx-win pairs



## Task 3

    heat_map( filetype, G, f )

Creates a heat map, given the type of epidemic word file, and an epidemic simulation file f.

Input arguments:

-  filetype - Type of epidemic word file, either 'file', 'avg' or 'diff'
-  G - Connectivity graph in xlsx format
-  f - Epidemic simulation file in csv format


# normalize
This repository stores code to normalize XLS/CSV  files
The CSV resulted not well formatted
So I will concentrate on the XLS files
Several  XLS files does not contain any geographical information.
For this reason I developed a code to prepare an index as the one at the end of a book.
Word, list of files.
I read all the files in the cuaderno de campo.
The code is at index.pl

At the moment I am running the code erubagotti@COMOSPLNXU09:~/aspell/code$ rm nohup.out; nohup perl index.pl &
there is a module in the file parser.pl to run different processes and avoid memory leaks.

The index should be at /home/erubagotti/data/databaseNormalization/indexFile
The format will be 
file_name/tword1/tword2/t.....

The code appears to have a memory leak problem.
It is using 30% of the computer memory without writing nothing in the file

The result are  at "/home/erubagotti/data/databaseNormalization/indexLibroDeCampo/indexLibroDeCampo".

This version of the code does not deal properly with time and dates.
I moved several code in oldCode.


I am passing through isDate/isADate.pl to identify strings with a patterns
 
It works and I should merge it with the file parser.pl
Identify date is difficult, there are several formats, and is not necessary.
I woyuld like to identify the column where the geographical information are stored.

I could not locate any municipio in the data up to know. For this reason I will use a hierarchical clusetring algorithm in R between all the columns
Each column will be represented as a vector of % of N-Grams with N going from 1 to 5. To calculate the N-gam I will use a vector of sorted prefixes and suffixes.

The code flow is described below
Data structure:
The index of all files is  eported  at /home/erubagotti/data/databaseNormalization/indexLibroDeCampo/indexLibroDeCampo and the file structure is as follows."New_File\n\n" identifies a new file. 
FileName\tsheetName
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
........
New_File #This value is between a file and another.

FileName\tsheetName
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue
Sheet_Name\tColumn_Number\tValue

The code is at /home/erubagotti/aspell/code/N_grams.pl

The code is using 94% of RAM.... It should be rewritten...

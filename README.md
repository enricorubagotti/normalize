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

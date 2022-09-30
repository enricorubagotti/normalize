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
The index should be at /home/erubagotti/data/databaseNormalization/indexFile
The format will be 
file_name/tword1/tword2/t.....

The code appears to have a memory leak problem.
It is using 30% of the computer memory without writing nothing in the file

The result shouls be at "/home/erubagotti/data/databaseNormalization/indexFile" otherwise I should run a https://metacpan.org/pod/Memory::Process or other memory profiling app




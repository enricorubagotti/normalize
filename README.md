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
I am using N_grams.1.pl.
I am reading the file once without keeping in mmeory any variables

It worked......
The results are at /home/erubagotti/aspell/code/N_grams/arrayR.txtnor.txt
Now I will load it in R.
R crashed !!!!!
This code appears to be too long to develop.
So I am downgrading it to a spell checker to normalize geographical name in csv file
The code 1.spellcheck.pl correctly correct words in a file from a dictionary.

I will modularize it and export all the XLS files into CSVs
and submit it as an article.

I will employ it to spell check words from an xls file

The code to check the department is 
spell.check.depa.pl
The one to check the municipality is 
spell.check.depa.pl
spell.check.muni.pl
I shouls amend it to keep counting the number of failures to match and stops  when matches are less than 50% 
Input: a column
Output: a list of -1 if the column is not composed by geographical names 
or the spell checked geographical names otherwise
I merged the two dictionaries (department and municipality) into one 
/home/erubagotti/aspell/code/depaYmuni.bwt.sorted

I am working on spell_depa.pl
It is able to get the departments from the
xls file but the file /home/erubagotti/aspell/code/depaYmuni.bwt.sorted is likeley incomplete,
it does not find the correct words.

The code is running at 
/home/erubagotti/aspell/code/nohup perl  spell_depa.pl &
I should analyze the outputs.

The levenstein distance is too high.

I should use an average  levenstein distance on a column to decide if it is 
a geographical column or not. 

The code work for departamentos but there are memory   leaks !!!!!
This code should 
1) Classify a column as municipio, departamento, o otro
2) Spell check the column



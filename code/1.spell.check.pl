use strict 'vars';
use strict 'subs';
use List::Util qw(min);
#use List::UtilsBy; 
binmode STDOUT, ":utf8";
my %depa; 	# $depa{"depa name"}=sum of the letters equals between the 
			# query and the match.
			# It is used when there is not an exact coincidence between query and substring
			# In that case locates the upper and lower substring and increases the depa of 
			# the substring more similar of the matching letters
			# IOQUI, The substring of ANTIOQUIA, is not a full suffix but will be located between 
			# IOQUIA y IPIÉLAGO
			#$depa{ANTIOQUIA}+=number of chars identical between IOQUIA and IOQUI
			#IOQUIA^IANTIOQUIA$
			#IOQUI
			#IPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CA^IARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CA$			

#my $depa_Muni="../depa_Muni.csv";
my $file2Correct=$ARGV[0];
my $maxLeven=10;#$ARGV[1];
my $depa_bwt="../depa.bwt.sorted";#$ARGV[2];
my $depa=$ARGV[3];#"../depa";
 
my @circularDic0; #It is the first column of the file prefix\tepartment and host the prefix
my @circularDic1; #It is the secund column of the file prefix\tepartment and host the column
my %cache;

sub L1_leven {
    my ($s, $t) = @_;

    return length($t) if $s eq '';
    return length($s) if $t eq '';

    $cache{$s}{$t} //=    # try commenting out this line
      do {
        my ($s1, $t1) = (substr($s, 1), substr($t, 1));

        (substr($s, 0, 1) eq substr($t, 0, 1))
          ? L1_leven($s1, $t1)
          : 1 + min(
                    L1_leven($s1, $t1),
                    L1_leven($s,  $t1),
                    L1_leven($s1, $t ),
            );
      };
}

sub L2_find_binary {
	    my ($array_ref, $value, $left, $right) = @_;
	    #print "query = $value left= $left right=$right \n";
	        if ($right < $left)
				{
				return ($left."\t".$right);
				print "I am returning ".$left." ".$right.",  $array_ref->[$left] \t $array_ref->[$right]\n";
				#list matches;
				#update 
				}
	        #Updating the score of the Department
	        my $countMatchUpper=0;

		#compare left and right with the $value char by char
		    my $middle = int(($right + $left) >> 1);
		    	my $compare= $value  cmp  substr($array_ref->[$middle],0,length($value)); #I am seeking prefixes
		        if ($compare==0) {
					#print "L2_find_binary_L94_The position of ".$value." is ".$middle." that corresponds to ".$array_ref->[$middle]."\t".$circularDic1[$middle]."\n";
				        return $middle."\tFound";
					    }
					        elsif ($compare < 0 ) {
							#print "L2_L70I am seeking in the upper part of the array between $array_ref->[$left] and  $array_ref->[$middle]\n";
							        L2_find_binary($array_ref, $value, $left, $middle - 1);
								    }
								        else {
									#		print "L2L73_I am seeking in the lower part of the array between $array_ref->[$middle] and $array_ref->[$right] \n";
										        L2_find_binary($array_ref, $value, $middle + 1, $right);
											    }
										    }
										    
####################################################################
sub L1_return_match{
	my $query=$_[0];
	my @listDepa_bwt=@{$_[1]};
	my @listDepa=@{$_[2]};
	my %depa=%{$_[3]};
	my $longestLength=0;#It host the length of the longest matched substr in the array
	my $longestMatch="-1"; #It is the matched substring (e.g. ANTIOQ)
	my $longestOriginalWord; # It is the original string (e.g. ANTIOQUIA)
	#SET TO 0 THE FREQUENCY HASHES

		#It seeks for a match in all the prefixes and suffixes
		for (my $c=3;$c<length($query);$c++)
			{
			my @returnDirect=L3_listMatches(L2_find_binary(\@circularDic0,substr($query,0,$c+1),0,scalar(@circularDic0)-1),\@listDepa);
			# It is an array of
			# the line number of matches. More departments could share 
			# the same prefix or suffix  
			#It increases of 1 the match to the correspondent department
			#print "L1-LINE126 ".substr($query,0,$c+1)."\n";
			for (my $dirB=0;$dirB<scalar(@returnDirect);$dirB++)
			{
			if (length($listDepa_bwt[$returnDirect[$dirB]])> $longestLength)
				{
				#print "return_match_L123_new longest match $longestMatch\n";
				$longestLength=length($listDepa_bwt[$returnDirect[$dirB]]);
				$longestMatch=$listDepa_bwt[$returnDirect[$dirB]]; #It is the index of the longest match
				$longestOriginalWord=$circularDic1[$returnDirect[$dirB]];
				#print "Line_134_Best Depa estimation of ".substr($query,0,$c+1)." is ".$circularDic1[$returnDirect[$dirB]]."\n"; 
				if (exists($depa{$circularDic1[$returnDirect[0]]}))
					{
					$depa{$circularDic1[$returnDirect[$dirB]]}++;#=$longestLength;
					#print "Line 110 It could be ".$circularDic1[$returnDirect[$dirB]]."\n";
					}
				else 
					{
					$depa{$circularDic1[$returnDirect[$dirB]]}=1;#$longestLength;
					#print "Line 110 It could be ".$circularDic1[$returnDirect[$dirB]]."\n";
					}
				#print "foundExactQuery= ".substr($query,0,$c+1)."\t".$circularDic0[$returnDirect[0]]."\n";
				}
			}
		#Write here reverse
		
		
			#print "L1_Line_150 ".substr($query,0,$c+1)."\n";
		
			my @returnreverse=L3_listMatches(L2_find_binary(\@circularDic0,substr($query,0,$c+1),0,scalar(@circularDic0)-1),\@listDepa);
			# It is an array of
			# the line number of matches. More departments could share 
			# the same prefix or suffix  
			#It increases of 1 the match to the correspondent department
			for (my $dirB=0;$dirB<scalar(@returnreverse);$dirB++)
			{
			if (length($listDepa_bwt[$returnreverse[$dirB]])> $longestLength)
				{
				#print "return_match_L123_best depa estimation of ".substr($query,0,$c+1)." new longest match $longestMatch\n";
				$longestLength=length($listDepa_bwt[$returnreverse[$dirB]]);
				$longestMatch=$listDepa_bwt[$returnreverse[$dirB]]; #It is the index of the longest match
				$longestOriginalWord=$circularDic1[$returnreverse[$dirB]];
				if (exists($depa{$circularDic1[$returnreverse[0]]}))
					{
					$depa{$circularDic1[$returnreverse[$dirB]]}++;#=$longestLength;
					#print "Line 110 It could be ".$circularDic1[$returnDirect[$dirB]]."\n";
					}
				else 
					{
					$depa{$circularDic1[$returnreverse[$dirB]]}=1;#+=$longestLength;
					#print "Line 110 It could be ".$circularDic1[$returnDirect[$dirB]]."\n";
					}
				#print "foundExactQuery= ".substr($query,0,$c+1)."\t".$circularDic0[$returnreverse[0]]."\n";
				}
			}			
		}


#It locates the department with the  highest frequency
my $freq_Of_Best_Key=0; # We could have several keys with the same frequency  
my $best_Key="Null";

foreach my $key (keys %depa)
	{
	if  ($depa{$key} == $freq_Of_Best_Key )
		{
		if (L1_leven($key,$query) < L1_leven($best_Key,$query))
				{
				$best_Key=$key;
			#	print "Another best is ".$best_Key."\n";
				}
		}
	if ($depa{$key} > $freq_Of_Best_Key )
		{
		$best_Key=$key;
		$freq_Of_Best_Key=$depa{$key};
		#print "The new best is ".$best_Key." with a freq of ".$freq_Of_Best_Key."\n";
		}
	
	}
	
#Check output using levenDistance
if (abs(1-(L1_leven($query,$best_Key)/length($query)))>0.3) #It is the % of the match
	{
	#print "L1_Line207 bestKey=$best_Key\tfreq_Of_Best_Key=$freq_Of_Best_Key\n";
	return $best_Key;
	}
else
	{
	#	print "Line 170 query= $query best_Key = $best_Key\n";
	#	print "leven($query,$best_Key)=".L1_leven($query,$best_Key)."\n";
	#	print "lengthQuery=".length($query)."\n";
		return "-1";	
	}


}

sub returnSeparator {
	
	#THE CSV DOES NOT HAVE THE SAME NUMBER OF FIELDS
	#SO I AM GOING TO ALIGN THE FULL LINE
	#USING A WINDOW OF 20 AND SEEKING THE PREFIX AND SUFFIXES 
	my $fileName=$_[0];
	my %freq_char_by_line;	# this is an array of hashes, doc at 
					#https://www.educba.com/perl-array-of-hashes/
	my %charArray;	#It hosts the list of chars.
	 
	open(file,"<".$fileName) or print "$fileName.does not exist";
	binmode file, ":utf8";
	my $lineN=0; # It has to read all the file
				 # Some field (e.g. departamento) could be repeated several times
	while(my $line=<file> )
		{
		$line=~s/\n|\r|\'|\"//g;
		for (my $c=0;$c<length($line);$c++)
				{
				if (exists $freq_char_by_line{substr($line,$c,1)}{$lineN})
						{
						$freq_char_by_line{substr($line,$c,1)}{$lineN}++;

						#print "Line 25 I increased freq_char_by_line{".substr($line,$c,1)."}{".$lineN."} to ".$freq_char_by_line{substr($line,$c,1)}{$lineN}."\n" ;
						}
				else
						{
						$freq_char_by_line{substr($line,$c,1)}{$lineN}=1;
						#print "Line 30 \t"." I initailized the ash at ".substr($line,$c,1)." and ".$lineN."\n"; 
						$charArray{substr($line,$c,1)}=1;
						}
				}
		$lineN++;
		}
	#Iterates around all chars
	my %char226Freq; #For each char  stores the % of times is identical in all records 
	

		

	foreach my $char (keys %freq_char_by_line)
		{
		my $lastFreq; # It sets to 0 the freq at each chars
		binmode STDOUT, ":utf8";
		print "Line 229 ".$char."\n";
		#It prints the % of each char 
		print "Freq $char ";
		for ( my  $lineNHash=0; $lineNHash<$lineN;$lineNHash++)		
		#foreach my $lineNHash (keys %{$freq_char_by_line{$char}})
			{
			if (exists $freq_char_by_line{$char}{$lineNHash})
				{
				print $freq_char_by_line{$char}{$lineNHash}."\t";
				}
			else
				{
				print "0\t";	
				}
			#my $modeFreq=0; 	# I am counting the mode of the 
							# frequency of  a char 
	
			#my $whichFreqIsMax=0;
			#foreach my $freq (keys $freq_char_by_line{$char}{$lineNHash})
			#	{
			#	print 
				
					
				#if ($freq_char_by_line{$char}{$lineNHash}{$freq}>$modeFreq)
				#	{
				#	$modeFreq=$freq_char_by_line{$char}{$lineNHash}{$freq};
				#	$whichFreqIsMax=$freq;
				#	print "The best char is $char with a frequency of ".$freq_char_by_line{$char}{$lineNHash}{$freq}."\n";
				#	}
			#	}
			}
		print "\n";
		}



	my @separator=keys %charArray;
	if ((scalar(@separator)) > 1)
		{
		my $maxFreq70=0; #It hosts the separator with maximum frequency 
		my $sepMaxfreq="NULL";
		print "return_match_L_245 There is more than one separator's candidates, corresponding to columns \n";
		for (my $c=0; $c<scalar(@separator);$c++)
			{
			if ( $freq_char_by_line{$separator[$c]}{"10"}> $maxFreq70)
				{
				#print "The new best separator is ".$separator[$c]." with a frequence ".$freq_char_by_line{$separator[$c]}{"10"}."\n";
				my $sepNoPointer=$separator[$c];
				$maxFreq70=$freq_char_by_line{$sepNoPointer}{"10"};
				$sepMaxfreq=$separator[$c];
				#print "Line 70 best sep =$sepMaxfreq\n";
				} 	
			}
		print "return_match_L_257 I ESTIMATED THE SEPARATOR OF THE FILE ".$file2Correct." AS ".$sepMaxfreq."\n";
		return $sepMaxfreq;
		}
	else
		{
		return $separator[0];
		}
	}
sub column_muni{
my $file=$_[0];
my $sep5=$_[1];
#$maxLeven is a global variable
my @howManyMatches;
my $fieldN=0; # It stores the number of fields in a file
	#It initalizes the array to 0;
	for (my $e=0;$e<100;$e++)
		{
		$howManyMatches[$e]=0;
		}

open(file,"<$file") or print "$file does not exist\n";
binmode file, ":utf8";
for (my $c=0;$c<100;$c++)
	{
	my $line=<file>;
	$line =~ s/\n|\r//g;
	my @line=split(/$sep5/,$line);
	$fieldN=scalar(@line);
	for (my $d=0;$d<scalar(@line);$d++)
			{		
			if (return_match($line[$d]) ne "-1" )
				{
				$howManyMatches[$d]++;
				#print "Line_294 d=$d ".$line[$d]." could be a department\n";
				}
			else
				{
				#print "Line_302 ".$line[$d]." could not be a department\n"; 	
				}
			}
	}
	my $maxFreq=0;
	my $colNumber="Null";
	for (my $f=0;$f<$fieldN;$f++)
		{
		print "column_muni_L303 previousMaxFreq=".$maxFreq."\tactualMatch".$howManyMatches[$f]."\n";
		if ($maxFreq == $howManyMatches[$f])
			{
			print  "column_muni_L306_The department could be two different fields\n"	
			}
			
		print "column_muni_L309 freq[$f]=".$howManyMatches[$f]."\n"; 
		#print "Line_305The column".$f." has ".$howManyMatches[$f]."\n ";
		if ($maxFreq<$howManyMatches[$f])
			{
	#		print "column_muni_L313 The new best is col $f";
			$maxFreq = $howManyMatches[$f];
			$colNumber=$f;
			}
		
		}
if ($maxFreq <80)
	{return "column_muni_L320_ERROR, maxFreq=".$maxFreq."\n"}
	else 
	{
	return $colNumber;
	}
}




sub L3_listMatches {
	#It checks if there are duplicates in the sorted list and returns all 
	# the duplicates
	my @toReturn;
	my @firstLine=split(/\t/,$_[0]);
	$toReturn[0]=$firstLine[0];
	my @array=@{$_[1]};
	my $upper=$toReturn[0]+1;
	my $lower=$toReturn[0]-1;
	my $arrayConter=0;
	while ($array[$toReturn[0]] eq $array[$upper])
		{
		#print "Line386 I am pushing the element $upper\n";
		push(@toReturn, $upper);
		$upper++;
		}
		
	while 	($array[$toReturn[0]] eq $array[$lower])
		{
		#print "Line393 I am pushing the element $lower\n";
		push(@toReturn,$lower);
		$lower--;	
		}
	
	my @toReturnSorted=sort { $a <=> $b } @toReturn;
	return @toReturnSorted;
	}
print "usage: perl find.pl filename\n The file should be UTF8\nYou should check it with file filename and convert it with \n iconv -f ISO-8859-1 -t utf8 filename -o filename.utf8\n\n";
open(depa_bwt,"<$depa_bwt") or print $depa_bwt." does not exist\n";
binmode depa_bwt, ":utf8";
my $lCounter=0;
while (my $line=<depa_bwt>)
	{
	$line=~s/\n|\r//g;
	my @line=split(/\t/,$line);
	$circularDic0[$lCounter]=$line[0];
	$circularDic1[$lCounter]=$line[1];
	$lCounter++;
	$depa{$line[1]}=0;
	}
close depa_bwt;


open(file,"<".$file2Correct) or print $file2Correct." does not exist\n";

#while (my $query372=<file>)
#	{
#	$query372=~s/\n|\r|\"|'//g; # double quotes are freezing the code
#	print "The best match to $query372 is  ".L1_return_match(uc($query372), \@circularDic0, \@circularDic1,\%depa)." \n" ;
#	print "\n";
#	}
#close file;

print returnSeparator("Validación_Suelos_NIRS.UTF8.csv");
#print L1_return_match("BOGOTÁ", \@circularDic0, \@circularDic1,\%depa)." \n" ;
#print L1_return_match("STNTDER", \@circularDic0, \@circularDic1,\%depa)." \n" ;
#print L1_return_match("ANTIQUIA", \@circularDic0, \@circularDic1,\%depa)." \n" ;
#print L1_return_match("NORT SANTANDER", \@circularDic0, \@circularDic1,\%depa)." \n" ;

#Which one is the field separator?
#open(file,"<$file2Correct") or print "$file2Correct does not exist\n";
#Which column is Depa(if there is one) and which column is Muni(if there is one)

__END__
=encoding UTF8

=head1 DESCRIPTION
	This script automatically spell check csv files. It was designed to automatically correct geographical names in the file.
	Input: a CSV file
	Output: a CSV file with the last three column: Department(state), 
	City(Municipio),id
	or, when we do not have the department Municipio, ID, or when we do not have the City Department(ID)
	For debugging porpuses it is a series of nested functions that 
	are  executed as normalize_csv(returnSeparator, column_depa,return_match(L2_find_binary(L1.leven()), L1.list_matches))
	I ARRIVED TO L1.leven AND I SHOULD REVIEW ALL THE SUBS WITH HIERARCHICAL NUMBERS AND 
	I SHOULD ADD L1.list_matches TO FIND BINARY OR RETURN MATCH

=head2 normalize_csv(fileName)

	This is the more external function.
	Input: csv file name
	Output: the csv file name + corrected geographical location
	THIS IS TO FINISH!!!!

=head2 return_match(query,\array)

	Given a string(query) and an array it returns the nearest word  
	in the array
=head2 listMatches 
	This sub deals with cases where there multiple matches in the sorted array.

=head2 binary($array_ref, $value, $left, $right)
	The function find_binary  return the best match in an array to an 
	alphanumerical  query. 
	Input:reference to an array, query, minimum index  in the array, 
	maximum index  in the array.
	The code is recursive and for this reason it uses min and max value

=head2 leven($a,$b)

	This function calculates the levenstain distance between two 
	strings($a and $b)

=head2 column_depa(file_csv,\array_depa)
	This function returns the column number (first column=column0)
	of the department in the initial file. It returns NULL if 
	cannot locate any columns
	
=head2 column_muni(file_csv,\array_municipios)
	This function returns the column number (first column=column0)
	of the municipality in the initial file
	It returns NULL if it cannot locate any columns
= head2 returnSeparator(file_name)
	It returns the separator of a csv file.
	It strips the EOL and count the frequency of chars in 10 lines.
	It returns the separator as the char with identical frequency 
	in all 10 lines 
= head2 listMatches (initialMatch,arrayofMatches)
	Problem: binary search locates the first match. In this case we
	could have several matches that are substrings of different departments
	e.g. Santander and Norte de Santander
	To avoid missing this matches this function extend the
	search on the top and on the bottom of the located line
	and return an array.
I_  _I
=cut

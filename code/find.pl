use strict 'vars';
use strict 'subs';
use List::Util qw(min);
#use List::UtilsBy; 
binmode STDOUT , ":utf8";
my $depa_bwt="../depa.bwt.sorted";
my $depa="../depa";
my $muni="../muni.csv";
my $depa_muni_bwt='../depa_Muni.csv.bwt.sorted';
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
my %muni;

my $depa_Muni="../depa_Muni.csv";
my %depa_Muni;
my $bestDepaTruncated="NULL";
my $bestDepaTruncatedScore=0;
#my $query=uc($ARGV[0]);
my $file2Correct=$ARGV[0];
my $maxLeven=$ARGV[1];
my @circularDic0;
my @circularDic1;
my %cache;






sub leven {
    my ($s, $t) = @_;

    return length($t) if $s eq '';
    return length($s) if $t eq '';

    $cache{$s}{$t} //=    # try commenting out this line
      do {
        my ($s1, $t1) = (substr($s, 1), substr($t, 1));

        (substr($s, 0, 1) eq substr($t, 0, 1))
          ? leven($s1, $t1)
          : 1 + min(
                    leven($s1, $t1),
                    leven($s,  $t1),
                    leven($s1, $t ),
            );
      };
}




sub find_binary {
	    my ($array_ref, $value, $left, $right) = @_;
	    

	    
#	    print "query = $value left= $left right=$right \n";
	        return ($left."\t".$right) if ($right < $left);
	        #Updating the score of the Department
	        my $countMatchUpper=0;

	        for (my $c=0;$c<length($value);$c++)
				{
				if (substr($value,$c,1) eq substr($array_ref->[$left],$c,1))
					{
					$depa{$circularDic1[$left]}++;
					if ($bestDepaTruncatedScore <$depa{$circularDic1[$left]})
						{
						$bestDepaTruncatedScore =$depa{$circularDic1[$left]};
						$bestDepaTruncated=$circularDic1[$left];
						}
					}
				if (substr($value,$c,1) eq substr($array_ref->[$right],$c,1))
					{
					$depa{$circularDic1[$right]}++ ;
					}
				if ($bestDepaTruncatedScore <$depa{$circularDic1[$right]})
					{
					$bestDepaTruncatedScore = $depa{$circularDic1[$right]};
					$bestDepaTruncated=$circularDic1[$right];
					}
					
				
				}

		#compare left and right with the $value char by char
		#print "I am returning ".$left." ".$right.",  $array_ref->[$left] \t $array_ref->[$right]\n";
		    my $middle = int(($right + $left) >> 1);
		    	my $compare= $value  cmp  substr($array_ref->[$middle],0,length($value)); #I am seeking prefixes
		        if ($compare==0) {
					print "The position of ".$value." is ".$middle." that corresponds to ".$array_ref->[$middle]."\n";
				        return $middle."\tFound"."\t".$array_ref->[$middle]."\t";
					    }
					        elsif ($compare < 0 ) {
			#				print "I am seeking in the upper part of the array between $array_ref->[$left] and  $array_ref->[$middle]\n";
							        find_binary($array_ref, $value, $left, $middle - 1);
								    }
								        else {
			#								print "I am seeking in the lower part of the array between $array_ref->[$middle] and $array_ref->[$right] \n";
										        find_binary($array_ref, $value, $middle + 1, $right);
											    }
										    }
####################################################################
sub return_match{
	my $query=$_[0];
	my $longestLength=0;
	my $longestMatch="Null";
	my $longestOriginalWord;
	#SET TO 0 THE FREQUENCY HASHES
	if (!exists $depa{$query})
		{
		for (my $c=0;$c<length($query);$c++)
			{
			my $directBoundary=find_binary(\@circularDic0,substr($query,0,$c+1),0,scalar(@circularDic0)-1);
			my @returnDirect=split(/\t/,$directBoundary);
			if (($returnDirect[1] eq "Found") and (length($returnDirect[1]) > $longestLength))
				{
				#print "new longest match $longestMatch\n";
				$longestMatch=$returnDirect[0];
				$longestLength=length($returnDirect[0]);
				$longestOriginalWord=$circularDic0[$returnDirect[0]];
				#print "foundExactQuery= ".substr($query,0,$c+1)."\t".$circularDic0[$returnDirect[0]]."\n";
				}
			else
				{
				#print "foundQuery between ".$circularDic0[$returnDirect[0]]."\t".$circularDic0[$returnDirect[1]]."\n";
				}
				my $reverseBoundary=find_binary(\@circularDic0,substr($query,$c,length($query)-$c),0,scalar(@circularDic0)-1);
				my @returnReverse=split(/\t/,$reverseBoundary);
			if (($returnReverse[1] eq "Found") and (length($returnReverse[1]) > $longestLength))
				{
				$longestMatch=$circularDic0[$returnReverse[0]];
				$longestLength=length($circularDic0[$returnReverse[0]]);
				$longestOriginalWord=$circularDic1[$returnReverse[0]];
				
				#print "foundExactQuery= ".substr($query,$c,length($query)-$c)."\t".$circularDic0[$returnReverse[0]]."\n";
				}
			else
				{
				#print "foundQuery between ".$circularDic0[$returnReverse[0]]."\t".$circularDic0[$returnReverse[1]]."\n";
				}
				#print $circularDic1[find_binary(\@circularDic0,substr($query,0,$c+1),0,scalar(@circularDic0))]."\n";			
				#print $circularDic1[find_binary(\@circularDic0,substr($query,$c,length($query)-$c),0,scalar(@circularDic0))]."\n";
			}
		}
	
#Check output using levenDistance
if ((leven($query,$longestOriginalWord)/length($query))<0.2) #It is the % of the match
	{
	return $longestOriginalWord;
	}
else
	{
	if (leven($query,$bestDepaTruncated)<$maxLeven+1)
		{
		return $bestDepaTruncated;
		}
	else 
		{
		print "Line 170 query= $query longest Word= $longestOriginalWord    bestDepaTruncated = $bestDepaTruncated\n";
		return "-1";	
		}
	}
}

sub normalize_csv {
	#initialize to 0 the frequency hashes;
	
	foreach my $key (keys %depa)
		{
		$depa{$key}=0;	
		}

	foreach my $key (keys %muni)
		{
		$muni{$key}=0;	
		}
		
	foreach my $key (keys %depa_Muni)
		{
		$depa_Muni{$key}=0;	
		}
	}

	
sub returnSeparator {
	my $fileName=$_[0];
	my %freq_char_by_line;	# this is an array of hashes, doc at 
					#https://www.educba.com/perl-array-of-hashes/
				
	my %charArray;		#It hosts the list of chars.
	 
	open(file,"<".$fileName) or print "$fileName.does not exist";
	binmode file, ":utf8";
	my $lineN=0; # It has to read all the file
				 # Some field (e.g. departamento) could be repeated several times
	while(my $line=<file> )
		{
		$line=~s/\n|\r//g;
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
	foreach my $char (keys %freq_char_by_line)
		{
		my $first="true";
		my $lastFreq; # It sets to 0 the freq at each chars 
		foreach my $lineNHash (keys %{$freq_char_by_line{$char}})
			{
			if (($first ne "true") and ($freq_char_by_line{$char}{$lineNHash} ne $lastFreq) and (exists $charArray{$char}))
				{#It deletes all the keys using $char
				delete $charArray{$char};
				#print "At line ".$lineNHash." there are ".$freq_char_by_line{$char}{$lineNHash}." and in the previous line there are ".$lastFreq."\n";
				}
			if ($first eq  "true")
				{
				$first="false";
				$lastFreq= $freq_char_by_line{$char}{$lineNHash};
				}
			
			}		
		}
	my @separator=keys %charArray;
	if ((scalar @separator) > 1)
		{
		my $maxFreq70=0; #It hosts the separator with maximum frequency 
		my $sepMaxfreq="NULL";
		print "Line 49 There is more than one separator's candidates, corresponidng to columns \n";
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
		print "LINE 69 I ESTIMATED THE SEPARATOR OF THE FILE ".$file2Correct." AS ".$sepMaxfreq."\n";
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
			
			if (return_match($line[$d],\@circularDic0) ne "-1" )
				{
				$howManyMatches[$d]++;
				print "Line_294 d=$d ".$line[$d]." could be a department\n";
				}
			else
				{
				print "Line_302 ".$line[$d]." could not be a department\n"; 	
				}
			}
	}
	my $maxFreq=0;
	my $colNumber="Null";
	for (my $f=0;$f<$fieldN;$f++)
		{
		if ($maxFreq<$howManyMatches[$f])
			{
			#print "The new best is col $f";
			$maxFreq = $howManyMatches[$f];
			$colNumber=$f;
			}
		}
if ($maxFreq <80)
	{return "ERRORcolumn_muni, maxFreq=".$maxFreq."\n"}
	else 
	{
	return $colNumber;
	}
}

print "usage: perl find.pl filename\n The file should be UTF8\nYou should check it with file filename and convert it with \n iconv -f ISO-8859-1 -t utf8 filename -o filename.utf8";
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
	}
	close depa_bwt;

open(depa,"<$depa") or print $depa."does not exist\n";
binmode depa, ":utf8";
while (my $line=<depa_bwt>)
    {
	$line=~s/\n|\r//g;
	$depa{$line}=0;
	}	

open(muni,"<$muni") or print $muni." does not exist\n";
while (my $line=<muni>)
	{
	$line=~s/\n|\r//g;
	$muni{$line}=0;	
	}
close muni;

while (my $line=<muni>)
	{
	$line=~s/\n|\r//g;
	$muni{$line}=0;	
	}
open(depa_muni,"<".$depa_muni_bwt) or print $depa_muni_bwt." does not exist\n"; #this file is ";" separated
while (my $line=<depa_muni>)
	{
	$line				=~s/\n|\r//g;
	$depa_Muni{$line}	=			1;
	}
close depa_muni;
print "The municipality column is".column_muni($file2Correct,returnSeparator($file2Correct))."\n";

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
	are  executed as normalize_csv(column_depa,column_muni,return_match(find_binary(leven())))

=head2 normalize_csv(fileName)

	This is the more external function.
	Input: csv file name
	Output: the csv file name + corrected geographical location
	THIS IS TO FINISH!!!!

=head2 return_match(query,\array)

	Given a string(query) and an array it returns the nearest word  

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
=cut

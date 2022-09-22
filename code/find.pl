use strict;
use List::Util qw(min);
#use List::UtilsBy; 
my $input="../depa.bwt.sorted";

my $depa="../depa";
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
my $bestDepaTruncated="NULL";
my $bestDepaTruncatedScore=0;
my $query=uc($ARGV[0]);
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

sub find {
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
							        find($array_ref, $value, $left, $middle - 1);
								    }
								        else {
			#								print "I am seeking in the lower part of the array between $array_ref->[$middle] and $array_ref->[$right] \n";
										        find($array_ref, $value, $middle + 1, $right);
											    }
										    }
										    


binmode STDOUT	, ":utf8";
open(input,"<$input") or print $input." does not exist\n";
binmode input, ":utf8";
my $lCounter=0;
while (my $line=<input>)
	{
	$line=~s/\n|\r//g;
	my @line=split(/\t/,$line);
	$circularDic0[$lCounter]=$line[0];
	$circularDic1[$lCounter]=$line[1];
	$lCounter++;
	}
	close input;

open(depa,"<$depa") or print $depa."does not exist\n";
binmode depa, ":utf8";
	while (my $line=<input>)
        {
	$line=~s/\n|\r//g;
	$depa{$line}=0;
	}	
	my $longestLength=0;
	my $longestMatch="Null";
	my $longestOriginalWord;
	if (!exists $depa{$query})
		{
		for (my $c=0;$c<length($query);$c++)
			{
			my $directBoundary=find(\@circularDic0,substr($query,0,$c+1),0,scalar(@circularDic0)-1);
			my @returnDirect=split(/\t/,$directBoundary);
			if (($returnDirect[1] eq "Found") and (length($returnDirect[1]) > $longestLength))
				{
				print "new longest match $longestMatch\n";
				$longestMatch=$returnDirect[0];
				$longestLength=length($returnDirect[0]);
				$longestOriginalWord=$circularDic0[$returnDirect[0]];
				#print "foundExactQuery= ".substr($query,0,$c+1)."\t".$circularDic0[$returnDirect[0]]."\n";
				}
			else
				{
				#print "foundQuery between ".$circularDic0[$returnDirect[0]]."\t".$circularDic0[$returnDirect[1]]."\n";
				}
				my $reverseBoundary=find(\@circularDic0,substr($query,$c,length($query)-$c),0,scalar(@circularDic0)-1);
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
				#print $circularDic1[find(\@circularDic0,substr($query,0,$c+1),0,scalar(@circularDic0))]."\n";			
				#print $circularDic1[find(\@circularDic0,substr($query,$c,length($query)-$c),0,scalar(@circularDic0))]."\n";
			}
		}
	
#Check output using levenDistance
if (leven($query,$longestOriginalWord)<$maxLeven+1)
	{
	print "$query corrected is ".$longestOriginalWord."\n";
	}
else
	{
	if (leven($query,$bestDepaTruncated)<$maxLeven+1)
		{
		print "\nThe best match is $bestDepaTruncated\n";
		}
	else 
		{
		print "I could not find a match for $query\n";	
		}
	}

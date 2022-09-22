use strict;
#Input: a set of words
#Output: the direct and reverse rotation
my $input=$ARGV[0];
my $output=$input.'.bwt.sorted';
my @rotate;
open(input,"<".$input) or print $input." does not exist\n";
binmode input, ':utf8';
open(output,'>'.$output) or print $output." does not exist\n"; 
binmode output, ':utf8';
my $rotateC=0;
while (my $line=<input>)
	{
	#print circular shift from the end
	for (my $c=0;$c<length($line);$c++)
		{
		$line=~s/\n|\r//g;#It removes the eol at the end of the file
		$rotate[$rotateC]=uc(substr($line,0,$c+1)."\t".$line);
		$rotate[$rotateC+1]=uc(substr($line,$c,length($line))."\t".$line);
		$rotateC++;
		$rotateC++;
		}
	}
my @sortedRotated=sort { $a cmp $b } @rotate;
print output join("\n",@sortedRotated);
close output;

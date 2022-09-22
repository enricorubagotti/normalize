use strict;
my $file=$ARGV[0];
open(file,"<$file") or print "$file does not exist\n";
my $line1=" ";
my $line2=" ";
while(my $line=<file>)
	{
	$line2=$line;
	my $cmp=$line1 cmp $line2;
	if ($cmp >0)
		{
		print "Error at line $line";
		}
	$line1=$line;

	}
close file;

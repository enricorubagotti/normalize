use strict;
my @multiarray;
$multiarray[0][0]='Z';
$multiarray[1][0]='B';
$multiarray[2][0]='D';

$multiarray[0][1]=3;
$multiarray[1][1]=1;
$multiarray[2][1]=4;


my @lexicographically = sort {$a->[0] cmp $b->[0]} @multiarray;
for (@lexicographically) {
    print "@{$_}\n";
}

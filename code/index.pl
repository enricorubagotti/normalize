use strict 'vars';
use strict 'subs';
#use Data::Printer  max_depth => 0 , string_max => 0 ;
use Scalar::Util qw(looks_like_number);
use Try::Tiny;
use Spreadsheet::ParseXLSX;
my $indexFile="/home/erubagotti/data/databaseNormalization/indexFile";
sub parse {
my $file_Name= $_[0];
my %indexHash;#This is a different has for each file
			  #It stores the list of words
my $parser = Spreadsheet::ParseXLSX->new;
my $workbook = $parser->parse($file_Name);
unless ($workbook) {
    die "Got error " . $parser->error() . " parsing spreadsheet.";
}
if ( !defined $workbook ) {
    die $parser->error(), ".\n";
}
for my $worksheet ( $workbook->worksheets() ) {
 
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();
		if (!(looks_like_number($worksheet->get_name())))
			{
			$indexHash{$worksheet->get_name()}=1;
			}
    for my $row ( $row_min .. $row_max ) {
        for my $col ( $col_min .. $col_max ) {
            my $cell = $worksheet->get_cell( $row, $col );
            next unless $cell;
            if (!(looks_like_number($cell->value())))
				{
				$indexHash{$cell->value()}=1;
				}
            #print $cell->value()."\n";
        }
    }
}
undef  $parser ;
undef $workbook;
return keys %indexHash;
}


my $listFiles="listLibroCampo.txt";
my $mummyDir="/home/erubagotti/data/databaseNormalization/LibrosCampos/";

open( dh, "<".$listFiles) || die "Can't open $listFiles: $!";
open(daddy,">".$indexFile) or print $indexFile." does not exist\n"; 

while (my $file_Name= <dh>) {
	if ( $file_Name=~m/xlsx/i){	
	try{
			$file_Name=~ s/\n|\r//g;
		print "I am parsing $file_Name\n";
		
		print daddy $file_Name."\t".join("\t",parse($mummyDir.$file_Name)); 
		close daddy;
		
		}
	catch { 
		warn "caught error: $_";
	}
}

}
close dh;
close daddy;

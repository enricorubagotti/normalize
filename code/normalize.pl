use strict;
use List::Util qw(min);

my $input_file=$ARGV[0];			#Esto es un archivo .csv que contiene la tabla y Departamento y Municipios
my $lines_to_skip=$ARGV[1];
my $number_of_columns=$ARGV[2];
my $file_Departamentos_Municipios='/home/enrico/data/normalize/Listados_DIVIPOLA.txt';	#Código ^INombreDepartamento^ICódigo ^INombreMuni^ITipo^I$
my @input_file;
my %columnMuni; #This hash stores the frequency of Municipality  names in the column N;
my %columnDepa; #This hash stores the frequency of Department   names in the column N;
# Open the file with the List of Municipalities
print "usage :perl normalize.pl filename.csv lines_to_skip number_of_columns\n Please note that the csvi file should be tab separated and not comma separated.lines_to_skip=1 if there is a header"
my %depa2Estimated;
my %municipio2Estimated;
open(municipality, "<$file_Departamentos_Municipios") or print $file_Departamentos_Municipios." does not exist\n";
my $header=<municipality>;
my %muni;#It hosts the list on municipality
my %depa2Muni;


#Subs are here !!!!
sub s_FindDepartment  {
					  #Find departments;
					  my $depa=$_[0];
					  my @distances;
					  #which depa is the nearest one?
					  #It return the array of distances sorted by distance
					  my $c=0
					  foreach my $key (keys %depa2Muni)
						{
						$distances[$c][0]=$key;
						$distances[$c][1]=s_Leven($key,$depa);
						c++;
						}	
					my @sortedDistances = sort {$a->[1] <=> $b->[1]} @distances;
					  return @sortedDistances;
					  }


sub s_FindMunicipio {
					my $muni=$_[0];
					my $depa=$_[1];
					my @distancesMunicipios
					foreach my $key (keys %{$depa2Muni{$depa} })
						{
						$distances[$c][0]=$key;
						$distances[$c][1]=s_Leven($key,$muni);
						c++;
						}
					#Municipio departments;	
					}
								
sub s_Leven {
    my ($s, $t) = @_;
 
    my $tl = length($t);
    my $sl = length($s);
 
    my @d = ([0 .. $tl], map { [$_] } 1 .. $sl);
 
    foreach my $i (0 .. $sl - 1) {
        foreach my $j (0 .. $tl - 1) {
            $d[$i + 1][$j + 1] =
              substr($s, $i, 1) eq substr($t, $j, 1)
              ? $d[$i][$j]
              : 1 + min($d[$i][$j + 1], $d[$i + 1][$j], $d[$i][$j]);
        }
    }
 
    $d[-1][-1];
}

	
########################################################################
#The code will start here!!!!!!
while (my $line_muni=<municipality>)
	{        
	
	# Load it in an hash $departamento(departamento)=Municipalidades;
	# Load the list of municipalities into an array

	$line_muni =~ s/\n|\r//g;
	my @line=split($line_muni,/\t/);
	
	if exists ($depa2Muni{$line[1]})
			{
			$depa2Muni{$line[1]}.="\t".$line[3];
			}
	else
			{
			$depa2Muni{$line[1]}.=$line[3];
			}
			$muni{$line[3]}=1
	}
	
close municipality;
my $outputFile=$inputFile.'.normalized.csv';
# Open the CSV file
open (inputFile,"<$inputFile") or print $inputFile."does not exist\n";

#where are the departamento and municipio columns?
my $skip;
for (my $c=0;$c<$line_to_skip;$c++)
			{
			$skip=<inputFile>
			}
my $lineN=0;
my $line2Load=100

while((my $line=<inputFile>) and ($lineN<$line2Load))
			{
			$line=~s/\n|\r//g;
			my @line=split(/\t/,$line);
			for (my $col=0;$col<$number_of_columns;$col++)
				{
				if (exists $depa2Muni{$line[$col]})
					{
					$columnDepa{$col}++
					}
				else 
					{
					$columnDepa{$col}=1;
					}
				if (exists $muni{$line[$col]})
					{
					$columnMuni{$col}++
					}
				else 
					{
					$columnMuni{$col}=1;
					}
				}
			}
#Which column has more departments/municipios?
my $bestColNDepa=-10000;
my $bestColNMuni=-10000;

my $bestColDepaFreq=-10000;
my $bestColMuniFreq=-10000;
#Where is the Depa column?
foreach my $columnDepaN (keys %columnDepa)
 					{
					if ($columnDepa{$columnDepaN} > $bestColDepaFreq )	
						{
						$bestColDepaFreq=$columnDepa{$columnDepaN};
						$bestColNDepa=$columnDepaN;
						}
					}
if ($bestColNDepa< 0.8*$line2Load)
 					{
					die "Line 91, I cannot find the column of the department\n"
					}
	


#Where is the Muni column?
					
foreach my $columnMuniN keys {%columnMuni}
						{
						if ($columnMuni{$columnMuniN}>$bestColMuniFreq)
								{
								$bestColMuniFreq=$columnMuni{$columnMuniN};
								$bestColNMuni=$columnMuniN;
								}
						}

if ($bestColMuniFreq< 0.8*$line2Load)
 					{
					die "Line 91, I cannot find the column of the Municipality\n"
					}
close inputFile;

#open the csv file
#print the  CSV file into a multiple column array+2 (estimated departamento y municipalidad)
open (inputFile,"<$inputFile") or print $inputFile."does not exist\n";
open (outputFile,">$outputFile") or print $outputFile."does not exist\n";
#It skippes the headers

for (my $c=0;$c<$lines_to_skip;$c++)
								{
								my $toSkip=<inputFile>;
								$toSkip=~s/\n|\r//g;
								print  outputFile  $toSkip."\tDepartamentoEstimado\tMunicipioEstimado\n".
								}


while (my $line=<inputFile>)
								{
								$line=~s/\n|\r//g;
								my @line=split(/\t/,$line);
								#Is there a department with this name?
								if (exists   $depa2Muni{$line[$bestColNDepa]})
									{
									print 	outputFile $line.'\t'.$line[$bestColNDepa].'\t';
									}
								else
									{
									#Find departments;
									my @sortedDistances=\@s_FindDepartment($line[$bestColNDepa])
									print 	outputFile $line.'\t'.@sortedDistances[0];
									}
									
								#find municipality	
								if (exists   $muni{$line[$bestColNMuni]})
									{
									print 	outputFile $line[$bestColNMuni].'\n';
									}
								else
									{
								#find municipality;
									print 	outputFile s_FindMunicipio($line[$bestColNMuni],$line[$bestColNDepa]).'\n';
									}
									
								}


#write in the last two columns dep y municipio if available 
#If not avalable get the one with the lower levenstein distance



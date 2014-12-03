# type: perl find_unordered.pl <trace file>

$infile=$ARGV[0];

open (DATA,"$infile");

@line = <DATA>;
$size = @line;

$unordSeq = 0;

@x = split(/,/,$line[$0]);
if ($x[7] =~ /Seq=(\w+)/){
	$prevSeq = $1;
}

for ($i=1; $i<$size; $i++){
	@x = split(/,/,$line[$i]);
	if ($x[7] =~ /Seq=(\w+)/){
		$currSeq = $1;
	}
	
	$tempSeq = $currSeq;
	if ($tempSeq != $prevSeq+1){
		for ($j=$i+1; $j<$size; $j++){
			@y = split(/,/,$line[$j]);
			if ($y[7] =~ /Seq=(\w+)/){
				$tempSeq = $1;
			}
			if ($tempSeq == $prevSeq+1){
				$unordSeq++;
				last;
			}
		}
	}	
	$prevSeq = $currSeq;
}

print "Unordered sequence events = $unordSeq\n";

close DATA;

#!/usr/bin/perl
# Usage: perl udp_throughput.pl <trace file> <to_node> <granularity> > file

# Function to parse .csv files
sub parse_csv {
    my $text = shift;      # record containing comma-separated values
    my @new  = ();
    push(@new, $+) while $text =~ m{
        # the first part groups the phrase inside the quotes.
        # see explanation of this pattern in MRE
        "([^\"\\]*(?:\\.[^\"\\]*)*)",?
           |  ([^,]+),?
           | ,
       }gx;
       push(@new, undef) if substr($text, -1,1) eq ',';
       return @new;      # list of values that were comma-separated
}

$infile=$ARGV[0];
$to_node=$ARGV[1];
$granularity=$ARGV[2];

$sum=0;
$tp=0;

open (DATA,"$infile")
  || die "Can't open $infile $!";

while ($line=<DATA>){
	@x = parse_csv($line);
	$t = $x[1];
	
	if ($x[3] eq $to_node){
		if ($t-$tp <= $granularity){
			$sum=$sum+93;
		} 
		else{
			$throughput=$sum*8/($t-$tp)/1024;
			print STDOUT "$t $throughput\n";
			$tp=$t;
			$sum=0;
		}
	}
}

close DATA;
exit(0);

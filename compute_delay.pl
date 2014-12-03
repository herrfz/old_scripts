#!/usr/bin/perl
# Usage: perl compute_delay <from_trace.csv> <to_trace.csv> <to_addr_ipv6> > output_file
# The input files must be comma-separated, contain only ... packets, sequence 

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

# Function to get the sequence number
sub get_seq_nbr {
	if ($_[0] =~ /Seq=(\w+)/){
		return $1;
	} else {
		return rand(100);
	}
}

# Function to convert time in format hh:mm:ss.ssss into seconds
sub convert_time_to_sec {
	@time = split(/:/,$_[0]);
	return $time[0]*3600 + $time[1]*60 + $time[2];
}

#---------------------------------------------------------------------
$from_trace = $ARGV[0];
$to_trace = $ARGV[1];
$to_addr = $ARGV[2];
# $from_offset = $ARGV[3];
# $to_offset = $ARGV[4];

# Compute the number of lines in the target trace file
$lcount = `wc -l < $to_trace`;
die "wc failed: $?" if $?;
chomp($lcount);

open(FILE1, "$from_trace") or die "can't open $from_trace: $!";
open(FILE2, "$to_trace") or die "can't open $to_trace: $!";
@to_lines = <FILE2>;

$j = 0;

while ($line=<FILE1>){
	@x = parse_csv($line);
	if ($x[3] eq $to_addr){
		$from_seq = get_seq_nbr($x[5]);
		for ($i=$j;$i<$lcount;$i++){
			@y = parse_csv($to_lines[$i]);
			if ($y[3] eq $to_addr){
				$to_seq = get_seq_nbr($y[5]);
				if ($from_seq == $to_seq){
					$tx_time = convert_time_to_sec($x[1]);
					$rx_time = convert_time_to_sec($y[1]);
					$delay = ($rx_time - $tx_time)*1000;
					print STDOUT "$from_seq, $delay\n";
					$j = $i;
					last;
				}
			}	
		}
	}
}

#!/usr/bin/env perl
# Modified from insertion.pl - to just deliver the sequence given an insertion of the form chr-pos
use warnings;
use strict;
use Bio::EnsEMBL::Registry;
Bio::EnsEMBL::Registry->load_registry_from_db(  -host => 'ensembldb.ensembl.org',
                                                -user => 'anonymous',);
my $sad = Bio::EnsEMBL::Registry->get_adaptor("Mouse", "core", "slice");
# Dir glob to set inputs
my @files = @ARGV;
my $count = 0;
while (my $f = shift @files) {
	open (FILE, "<", $f) or die "Can't open\n";
	open (OUTFILE,">", $f . ".genes");
	my @sites;
	while (my $line = <FILE>) {
	
	if ($count == 0) {
		print OUTFILE $line;
		$count = 1;
		next;
	}
	my @fields = split(/,/,$line);
#	foreach (@fields) { print $_ . "\t" }
#	print "\n";
# Splitting with capture introduces extra fields between each one (why?)
	my $chr = $fields[0];
	my $pos = $fields[2];
	my $str = $fields[1];
	my $sl;
	if ($str eq '+') {
		$sl = $sad->fetch_by_region('chromosome', $chr, $pos, $pos+3);
	} else {
		$sl = $sad->fetch_by_region('chromosome', $chr, $pos-3, $pos);
	}
	my @genes = @{$sl->get_all_Genes()};
	chomp $line;
	print OUTFILE $line . "\t";
	foreach (@genes) { print OUTFILE $_->external_name . "," }
	print OUTFILE "\n";
	}
close FILE;
close OUTFILE;
$count = 0;

# end while...file
}

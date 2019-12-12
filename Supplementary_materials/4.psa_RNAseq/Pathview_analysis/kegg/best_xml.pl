#!/usr/bin/perl

use strict; use warnings;

my $xml = $ARGV[1];
my $best = $ARGV[0];

open(XML, "< $xml");
open(BEST,"< $best");
my %pst2best;

while(<BEST>){
	my $line=$_;
	chomp($line);
	my @list = split("\t",$line);
	#print $list[1]."\n";
	$pst2best{$list[0]} = $list[1];
}

close BEST;


while(<XML>){
	if($_=~/^(\s+<entry.*name=\")(pst:PSPTO_\d+\s+.*pst:PSPTO_\d+)\"/){
		print $1;
		#save this
		my $pspt = $2;
		$pspt =~ s/\s+/,/g;
		$pspt =~ s/pst://g;
		#check which of the multiple PST orthologs has the highest DE 
		if(exists $pst2best{$pspt}){
			$pspt = $pst2best{$pspt};
		}
		else{
			my @tmp;
			@tmp = split(',',$pspt);
			$pspt = $tmp[0];
		}
					print "pst:".$pspt."\" type=\"gene\"\n";;
	}
	else{
		print $_;
	}
}


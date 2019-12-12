#!/usr/bin/perl

use strict; use warnings;

my $iyos = $ARGV[0];
my $xml = $ARGV[1];

open(IYOS, "< $iyos");
open(XML, "< $xml");
my %iyo2pst;
while(<IYOS>){
	my $line=$_;
	chomp($line);
	my @list = split("\t",$line);
	$iyo2pst{$list[1]} = $list[0];
}

close IYOS;

my $flag=0;
my $pspt="";

while(<XML>){
	if($_=~/^\s+<entry/){
		#if the entry name is a gene, store the first gene name 
		if($_=~/^(\s+<entry.*name=\")(pst:PSPTO_\d+)\"/){
			#save this
			$pspt=$2; 
			$flag=2;
		}
	}
	if($flag>0){
		if($flag>1 && $_=~/^(\s+<graphics name=")/){			
			print $1;
			$pspt =~s/pst://g;
			if(exists $iyo2pst{$pspt}){
				print $iyo2pst{$pspt};
			}
			else{
				print $pspt;
			}
			print "\" fgcolor=\"\#000000\" bgcolor=\"#FFFFFF\"\n";
		}
		elsif($_=~/^<\/entry/){
			$flag=0;
			print $_;
		}
		else{
			print $_;
		}
	}
	else{
		print $_;
	}
}


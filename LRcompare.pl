#!/usr/bin/perl
#get.pl file  5,6,7  2,3,4 
#Perform permutation test between two groups, 5,6,7 is group1, 2,3,4 is group2

use strict;
use warnings;
use List::Util qw/shuffle/;

my $file=shift;
my $group1=shift;
my $group2=shift;
my @group1=split /,/,$group1;
my @group2=split /,/,$group2;

###Array average
sub average {
	my (@num) = @_;
	my $num = scalar @num;
	my $total;
	#my $n;
	foreach (0..$#num) {
		#if($_==0){
		#}else{
			$total += $num[$_];
			#$n++;
		#}
	}
	return ($total/$num);
	#return ($total/$n);
}

open(RESULT,">compare_$file") or die;
open(FILE,$file) or die;
while(<FILE>){
	chomp;
	my @row=split /\t/;
	my $name=shift @row;
	if(/^ligand/i or /^sample/i){
		print RESULT "$_\tMs\tpvalue\n";
	}elsif($name=~/Unknown/i){
	}else{
		my @young;
		my @old;
		for(my $i=0;$i<@group1;$i++){
			my $loc1=$group1[$i]-2;
			push @young,$row[$loc1];
		}
		for(my $j=0;$j<@group2;$j++){
			my $loc2=$group2[$j]-2;
			push @old,$row[$loc2];
		}
		my $cha=(average @old)-(average @young);

		### Randomly shuffling the array, and then recalculate the difference between the two groups
		my @random;
		for(my $i=0;$i<1000;$i++){
			my @new=shuffle @row;  #Shuffle the array and rearrange it
			if(@new ~~ @row){  #Determine whether two arrays are equal
			}else{
				my @young1;
				my @old1;
				for(my $i=0;$i<@group1;$i++){
					my $loc1=$group1[$i]-2;
					push @young1,$new[$loc1];
				}
				for(my $j=0;$j<@group2;$j++){
					my $loc2=$group2[$j]-2;
					push @old1,$new[$loc2];
				}
				my $cha1=(average @old1)-(average @young1);
				push @random,abs $cha1;
			}
		}

		my $n=0;
		for(my $p=0;$p<@random;$p++){
			if($random[$p]>(abs $cha)){
				$n++;
			}
		}
		my $pvalue=$n/1000;
		print RESULT "$_\t$cha\t$pvalue\n";
	}
}
close(FILE);
close(RESULT);

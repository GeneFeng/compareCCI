#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Path;
use Cwd;
use File::Basename;


my $lr_tr_cell_dir;

sub usage() {
    print "Usage: perl $0 -d lr_tr_cell_dir";
}

GetOptions(
    "d=s" =>  \$lr_tr_cell_dir
);

if (!$lr_tr_cell_dir) {
    usage;
    exit;
}

my $dir=$lr_tr_cell_dir;

mkpath("celltype");

opendir(DIR,$dir) or die "Can't open $dir\n";
while(my $file=readdir(DIR)){
	if($file ne '.' and $file ne '..'){

		my %hash;
		open(FILE,$dir."/".$file) or die "Can't open ".$dir."/".$file."\n";
		while(<FILE>){
			$_=~s/[\r\n]+//g;
			if(/^ligand/){
			}else{
				my @row=split /\t/;
				my $cell=$row[3].'__'.$row[5];
				#my $result=$row[2]*$row[4];
				my $result=($row[2]*$row[4])/($row[2]+$row[4]); #calculate LRscore
				my $value=$row[0].'|'.$row[1]."\t".$result;
				push @{$hash{$cell}},$value;
			}
		}
		close(FILE);

		foreach  (keys %hash) {
			my @num=@{$hash{$_}};
			mkpath("celltype/".$_);   #Create a new folder that does not exist before, equivalent to mkdir -p
			#open(RESULT,'>'.$_.'___'.$file) or die;
			open(RESULT,">celltype/".$_."/".$file) or die "Can't create "."celltype/".$_."/".$file."\n";
			for(my $i=0;$i<@num;$i++){
				print RESULT "$num[$i]\n";
			}
			close(RESULT);
		}
	}
}
close(DIR);


###uniq
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

$dir=$lr_tr_cell_dir;

#scan lr_tr_cell to obtain sample information
my @list;  
opendir(DIR,$dir) or die;
while(my $file=readdir(DIR)){
	if($file ne '.' and $file ne '..'){
		push @list,$file; #Save the sample name into the array
	}
}
close(DIR);

#scan the folder where to add files

my $root_dir = "celltype";

opendir(ROOT_DIR, $root_dir) or die "Unable to access $root_dir dir\n";
	#my $result_dir = "new_$root_dir";
	#mkpath($result_dir);
	while(my $sub_dir = readdir(ROOT_DIR)) {
		if(substr($sub_dir,0,1) ne '.'){
			#mkpath($result_dir."/".$sub_dir);
			my %name;
			opendir(SUB_DIR, $root_dir."/".$sub_dir) or die;
			while(my $file=readdir(SUB_DIR)){
				if($file ne '.' and $file ne '..'){
					$name{$file}=1;  #Save the name of the subfolder to hash
				}
			}
			close(SUB_DIR);

			for(my $i=0;$i<@list;$i++){
				opendir(SUB_DIR, $root_dir."/".$sub_dir) or die;
				while(my $file=readdir(SUB_DIR)){
					if(exists $name{$list[$i]}){ #Check whether the subfolder contains the files in the array, if not, create a new one
					}else{
						open(RESULT,'>'.$root_dir."/".$sub_dir."/".$list[$i]) or die "Can't create result file ";
						close(RESULT);
					}
				}
				close(SUB_DIR);
			}
		}
	}
closedir(ROOT_DIR); 


$root_dir = "celltype";
opendir(ROOT_DIR, $root_dir) or die "Unable to access $root_dir dir\n";
	my $result_dir = "merge_$root_dir";
	mkpath($result_dir);
	while(my $sub_dir = readdir(ROOT_DIR)) {
		if(substr($sub_dir,0,1) ne '.'){
			open(RESULT,'>'.$result_dir."/".$sub_dir.'.txt') or die "Can't create result file ";
			my @num;  
			my @name;
			opendir(SUB_DIR, $root_dir."/".$sub_dir) or die;
			while(my $file=readdir(SUB_DIR)){
				if($file ne '.' and $file ne '..'){
					my $tmp=$file;
					$tmp=~s/lr_cell_//;
					$tmp=~s/.txt//;
					push @name,$tmp;
					open(FILE,$root_dir."/".$sub_dir."/".$file) or die;
					while(<FILE>){
						$_=~s/[\r\n]+//g;
						my @row=split /\t/;
						push @num,$row[0];  #Save the ligand-receptor names in an array
					}
					close(FILE);
				}
			}
			close(SUB_DIR);
			
			print RESULT "sample\t";
			print RESULT join "\t",@name;
			print RESULT "\n";

			@num=uniq @num;
			
			for(my $i=0;$i<@num;$i++){
				print RESULT "$num[$i]";
				opendir(SUB_DIR, $root_dir."/".$sub_dir) or die;
				while(my $file=readdir(SUB_DIR)){
					if($file ne '.' and $file ne '..'){
						my $value=0;
						open(FILE,$root_dir."/".$sub_dir."/".$file) or die;
						while(<FILE>){
							$_=~s/[\r\n]+//g;
							my @row=split /\t/;
							if($row[0] eq $num[$i]){
								$value=$row[1];
							}
						}
						close(FILE);
						print RESULT "\t$value";
					}
				}
				close(SUB_DIR);
				print RESULT "\n";
			}
			
			close(RESULT);			
		}
	}
closedir(ROOT_DIR); 


$dir="merge_celltype";
open(RESULT,'>'.$dir.'.txt') or die "Can't create file $dir".".txt\n";

my @num;
my %title;
opendir(DIR,$dir) or die "Can't open $dir\n";
while(my $file=readdir(DIR)){
	if($file ne '.' and $file ne '..'){
		my $tmp=$file;
		$tmp=~s/.txt//;
		my @name=split /__/,$tmp;
		open(FILE,$dir."/".$file) or die "Can't open ".$dir."/".$file."\n";
		while(<FILE>){
			$_=~s/[\r\n]+//g;
			if(/^sample/i){
				$_=~s/^sample/receiver_cell/;
				my $title1='ligand|receptor__sender_cell|'.$_;
				$title{$title1}=1;
			}else{
				my @row=split /\t/;
				my @lr=split /\|/,$row[0];
				$row[0]=$lr[0].'|'.$lr[1].'__'.$name[0].'|'.$name[1];
				my $new=join "\t",@row;
				push @num,$new; 
			}
		}
		close(FILE);
	}
}
close(DIR);

foreach  (keys %title) {
	print RESULT "$_\n";
}

for(my $i=0;$i<@num;$i++){
	print RESULT "$num[$i]\n";
}

close(RESULT);


rmtree 'celltype',{verbose => 0,keep_root => 0};
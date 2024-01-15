#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Path;
use Cwd;
use File::Basename;


my ($normalized_counts_dir, $cell_annotation, $lr_database);

sub usage() {
    print "Usage: perl $0 -c normalized_counts_dir -a cell_annotation_file -d lr_database_file";
}

GetOptions(
    "c=s" =>  \$normalized_counts_dir,
    "a=s" =>  \$cell_annotation,
    "d=s" =>  \$lr_database
);

if (!$normalized_counts_dir or !$cell_annotation or !$lr_database) {
    usage;
    exit;
}


my $dir=$normalized_counts_dir;
mkpath("tr_$dir");   #Create a new folder that does not exist before, equivalent to mkdir -p
opendir(DIR,$dir) or die "Can't open $dir\n";
while(my $file=readdir(DIR)){
	if($file ne '.' and $file ne '..'){
		open(FILE,$dir."/".$file) or die "Can't open ".$dir."/".$file."\n";
		my $i=0;
		my @data;
		while(<FILE>){
			$_=~s/[\r\n]+//g;
			my @line=split /\t/;
			for my $k(0 .. $#line){
				$data[$k][$i]=$line[$k];
			}
			$i++;
		}
		close(FILE);

		open (RESULT,">tr_$dir"."/".$file) or die "Can't create "."tr_$dir"."/".$file."\n";
		for (@data){
			#print RESULT $file,"\t";
			print RESULT join ("\t",@{$_}),"\n";
		}
		close(RESULT);
	}
}
closedir(DIR);


my $file=$cell_annotation;
$dir="tr_".$normalized_counts_dir;

my %hash;
open(FILE,$file) or die "Can't open $file\n";
while(<FILE>){
	$_=~s/[\r\n]+//g;
	if(/^barcode/i){
	}else{
		my @row=split /\t/;
		#my @barcode=split /_/,$row[0];
		#$row[1] =~ s/[\r\n]+//g;
		$hash{$row[0]}=$row[1];   #The annotation file includes two columns, the first column is barcode, and the second column is cell type
	}
}
close(FILE);

mkpath("cell");   #Create a new folder that does not exist before, equivalent to mkdir -p

opendir(DIR,$dir) or die "Can't open $dir\n";
while(my $newfile=readdir(DIR)){
	if($newfile ne '.' and $newfile ne '..'){

		my $tmp=$newfile;
		#$tmp=~s/tr_//;
		$tmp=~s/.txt//;

		my %hash2;
		my $title;
		open(NEWFILE,$dir."/".$newfile) or die "Can't open ".$dir."/".$newfile."\n";
		while(<NEWFILE>){
			$_=~s/[\r\n]+//g;
			if(/^gene/i or /^sample/i){ #the first letter of the first line of the file normalized count
				#print RESULT "$_\n";
				$title=$_;
			}else{
				my @row=split /\t/;
				my $name=shift @row;
				#$name=~s/-1//;            #Some barcodes have a -1 added after them. Be careful to keep it consistent with the annotation
				if(exists $hash{$name}){
					$name=$hash{$name};
					my $value=join "\t",@row;
					push @{$hash2{$name}},$value;
				}
			}
		}
		close(NEWFILE);
		
		my $subdir="cell/cell_$tmp";
		mkpath("$subdir");   #Create a new folder that does not exist before, equivalent to mkdir -p

		foreach  (keys %hash2) {
			#print("$_\n");
			open(RESULT,">$subdir/$_".".txt") or die "Can't create "."$subdir/$_".".txt"."\n";
			my @num=@{$hash2{$_}};
			print RESULT "$title\n";
			for(my $i=0;$i<@num;$i++){
				print RESULT "$_\t$num[$i]\n";
			}
			close(RESULT);
		}

	}
}
closedir(DIR);


my @all_file;

sub scan_dir {
	my $sub_dir = shift;
	my $start_dir = cwd();
	chdir $sub_dir or die "Unable to enter the $sub_dir dir!\n";
	opendir my $DIR, '.' or die "can't open the dir\n";
	my @names = readdir $DIR or die "can't read dir\n";
	closedir $DIR;
	foreach my $name (@names) {
		next if ($name eq '.');
		next if ($name eq '..');
		if (-d $name) {
			scan_dir($name);
			next;
		}
		push(@all_file, "$start_dir/$sub_dir/$name");
		# print("$start_dir/$sub_dir/$name\n");
	}
	chdir $start_dir or die "Unable to enter the $start_dir dir!\n";
}

my $boot_dir = "cell";
my $new_boot_dir = "tr_".$boot_dir;
print("$boot_dir -> $new_boot_dir\n");

&scan_dir($boot_dir);

foreach my $file (@all_file) {
	my $file_name = basename $file;
	my $dir_name = dirname $file;
	my $new_dir_name = $dir_name;
	$new_dir_name =~ s/\Q$boot_dir/$new_boot_dir/;
	
	open(FILE, $file) or die;
	my $i=0;
	my @data;
	while(<FILE>){
		$_=~s/[\r\n]+//g;
		my @line=split /\t/;
		for my $k(0 .. $#line){
			$data[$k][$i]=$line[$k];
		}
		$i++;
	}
	close(FILE);
			
	mkpath($new_dir_name);	# mkdir -p

	open (RESULT,">$new_dir_name/$file_name") or die "can't create result file $new_dir_name/$file_name\n";
	for (@data){
		print RESULT join ("\t",@{$_}),"\n";
	}
	close(RESULT);
}


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


# main
$boot_dir = "tr_cell";
my $lrfile =$lr_database;

opendir(DIR, $boot_dir) or die "Unable to access $boot_dir dir\n";
my $result_dir = "lr_$boot_dir";
mkpath($result_dir);
while(my $sub_dir=readdir(DIR)){
	if(substr($sub_dir, 0, 1) ne "."){
		print("Dealing $boot_dir/$sub_dir\n");
		my %hash;
		opendir(SUBDIR, "$boot_dir/$sub_dir") or die "Unable to access $boot_dir/$sub_dir dir\n";
		while(my $file=readdir(SUBDIR)){
			if(substr($file, 0, 1) ne "."){
				my $cell=$file;
				$cell=~s/^1-//;
				$cell=~s/.txt//;
				open(FILE, "$boot_dir/$sub_dir/$file") or die "Can't access file $boot_dir/$sub_dir/$file\n";
				while(<FILE>){
					$_=~s/[\r\n]+//g;
					my @row=split /\t/;
					if(/^gene/i or /^sample/i){ #the first letter of the first line of the file normalized count
					}else{
						my $name=shift @row;
						my $value=average @row;


						#print RESULT "$name\t$cell\t$value\n";
						if($value==0){  #If the average expression of a gene in all cells of this cell type is 0, it does not need to be counted
						}else{
							#my $final=$cell."\t".$value;
							my $final=$value."\t".$cell; #This is to be consistent with the results of italk
							push @{$hash{$name}},$final;
						}
					}
				}
				close(FILE);
			}
		}
		close(SUBDIR);
		
		open(RESULT,">$result_dir/lr_$sub_dir" . ".txt") or die "Can't create result file $boot_dir/lr_$sub_dir.txt\n";
		#print RESULT "ligand\treceptor\tcell_from\tcell_from_mean_exprs\tcell_to\tcell_to_mean_exprs\n";
		print RESULT "ligand\treceptor\tcell_from_mean_exprs\tcell_from\tcell_to_mean_exprs\tcell_to\n";
		open(FILE, $lrfile) or die "Can't open file $lrfile\n";
		while(<FILE>){
			$_=~s/[\r\n]+//g;
			if(/^ligand/i){
			}else{
				#$_=uc $_;
				my @row=split /\t/;
				if(exists $hash{$row[0]} and exists $hash{$row[1]}){
					my @ligand=@{$hash{$row[0]}};
					for(my $i=0;$i<@ligand;$i++){
						my @receptor=@{$hash{$row[1]}};
						for(my $j=0;$j<@receptor;$j++){
							print RESULT "$row[0]\t$row[1]\t$ligand[$i]\t$receptor[$j]\n";
						}
					}
				}
			}
		}
		close(FILE);
		close(RESULT);
	}
}
close(DIR);


rmtree 'cell',{verbose => 0,keep_root => 0};
rmtree 'tr_cell',{verbose => 0,keep_root => 0};
rmtree 'tr_normalized_counts',{verbose => 0,keep_root => 0};
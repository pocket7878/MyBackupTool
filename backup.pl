#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Copy;
use File::Copy::Recursive qw(rcopy);
use File::Temp;
use File::HomeDir;
use Archive::Zip;
use Cwd;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
my $outfile = "backup$year$mon$mday$hour$min$sec.zip";

# GetOptions
GetOptions("outfile=s" => \$outfile);

# get home dir path 
my $home = File::HomeDir->my_home;
# set rc filename
my $rcFile = $home . "/.myBackuprc";
# check rc file exist
unless(-f $rcFile) {
	die "Error: Can't find rc file";
}
# ead data from rc file
# nd save data to haskmap
my %backupHash;
open(IN, $rcFile);
while(my $line = <IN>) {
	if($line =~ /([a-zA-Z0-9]*): ([^\s]*)/) {
		$backupHash{"$1"} = "$2";
	}
}

# heck hash map
while((my $key, my $val) = each(%backupHash)) {
	unless(-e $val) {
		print "Warn: $val does not exist!!\n";
		delete $backupHash{"$key"};
	}
	else {
		print "Backup name: $key Path: $val\n";
	}
}

# enerate temp dir
my $currentDir = getcwd;
my $tempDir = File::Temp::tempdir(DIR=>'.', CLEANUP => 1);
my $tempDirFullPath = $currentDir . "/$tempDir";
# nto temp dir

chdir($tempDirFullPath);
while((my $key, my $val) = each(%backupHash)) {
	rcopy("$val", "$key");
}

# enerate tgz
my $zip = Archive::Zip->new;
$zip->addTree("$tempDirFullPath");
# et out from temp dir
chdir($tempDirFullPath . "/../");
$zip->writeToFileNamed("$outfile");

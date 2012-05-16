#!/usr/bin/perl

use warnings;
use threads;
use threads::shared;
use LWP::Simple;
use XML::Simple;
use Data::Dumper;
use File::Copy;

my $log = '/mnt/webcam-log';
my @cameras;

sub read_xml {
	$xml = new XML::Simple (KeyAttr=>[]);
	$data = $xml->XMLin("cameras.xml");
	@cameras = @{$data->{camera}};
}

#LOG: "$log/$_[0]->{id}/".time().".jpg"
sub capture_thread {
	while(1) {
		my $file = "$log/current/$_[0]->{id}.jpg";
		my $tmp = File::Temp->new( TEMPLATE => "$_[0]->{id}XXXX",
					   DIR => "$log/tmp/",
					   SUFFIX => ".jpg");

		my $result = getstore($_[0]->{url}, $tmp->filename);
		if($result != 200) {
			print "Error fetching $_[0]->{url}: $result\n";
		} else {
			rename $tmp->filename, $file;
			print "Fetched $_[0]->{url} to $file\n";
		}
		sleep($_->{capture_every});
	}
}

sub log_thread {
	while(1) {
		sleep($_->{log_every});
		my $logfile = "$log/$_[0]->{id}/".time().".jpg";
		my $currentfile = "$log/current/$_[0]->{id}.jpg";
		copy($currentfile, $logfile) or warn "[WARN] Could not copy $currentfile to $logfile: $!\n";
	}
}

sub main {
	foreach (@cameras) {
		threads->create(\&capture_thread,$_);
		threads->create(\&log_thread,$_);
	}
	foreach $thr (threads->list) { 

        if ($thr->tid && !threads::equal($thr, threads->self)) { 
            $thr->join; 
        } 
    }	
}

sub init {
	if(!-d "$log/current") { mkdir("$log/current") or die "Could not make current image store $log/current: $!\n";	}
	if(!-d "$log/tmp") { mkdir("$log/tmp") or die "Could not make temporary image store $log/tmp: $!\n"; }
	foreach (@cameras) {
		$dir = "$log/$_->{id}";
		if(!-d $dir) {
			mkdir($dir) or die "Could not make folder $dir: $!\n";
		}
	}
}

read_xml;
init;
main;

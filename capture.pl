#!/usr/bin/perl

use warnings;
use LWP::Simple;
use XML::Simple;
use File::Temp;
use Data::Dumper;

my $log = '/mnt/webcam-log';

sub read_xml {
	$xml = new XML::Simple (KeyAttr=>[]);
	$data = $xml->XMLin("cameras.xml");
}

#LOG: "$log/$_[0]->{id}/".time().".jpg"
sub get_image {
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
}

sub main {
	while (1) {
		foreach $i (@{$data->{camera}}) {
			$pid = fork();
			if ($pid) {
				push(@childs, $pid);
			} elsif ( $pid == 0 ) {
				get_image($i);
				exit(0);
			} else {
				die "couldn't fork, probably wills' fault";
			}
		}
		foreach (@childs) {
			waitpid($_,0);
		}
		sleep 1;
	}
}

sub init {
	if(!-d "$log/current") { mkdir("$log/current") or die "Could not make current image store $log/current: $!\n";	}
	if(!-d "$log/tmp") { mkdir("$log/tmp") or die "Could not make temporary image store $log/tmp: $!\n"; }
	for my $i (@{$data->{camera}}) {
		$dir = "$log/$i->{id}";
		if(!-d $dir) {
			mkdir($dir) or die "Could not make folder $dir: $!\n";
		}
	}
}

read_xml;
init;
main;

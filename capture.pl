#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;

my $log = '/mnt/webcam-log/';
my @cameras = ('http://cam-studio1-dj/image.jpg','http://cam-studio1-guest/image.jpg','http://cam-studio2-dj/image.jpg','http://cam-studio2-guest/image.jpg');

sub get_image {
	my $id = $_[0] + 1;
	my $url = $cameras[$_[0]];
	my $file = '/mnt/webcam-log/'.sprintf("%03d", $id).'-'.time().'.jpg';

	my $result = getstore($url, $file);

	if($result != 200) {
		print "Error fetching image: ".$result;
	}
}

sub main {
	for my $i (0 .. $#cameras) {
 	   get_image($i);
	}
}

main;

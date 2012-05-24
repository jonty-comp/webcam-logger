#!/usr/bin/perl

use threads;
use LWP::Simple;
use XML::Simple;
use File::Path;
use Image::Magick;

my $log = "/mnt/webcam-log";
my @cameras;

sub read_xml {
	$xml = new XML::Simple (KeyAttr=>[]);
	$data = $xml->XMLin("cameras.xml");
	@cameras = @{$data->{camera}};
}

sub capture_thread {
	while(1) {
		my $file = "$log/current/$_[0]->{id}.jpg";
		my $tmp = File::Temp->new( TEMPLATE => "$_[0]->{id}XXXX",
					   DIR => "$log/tmp/",
					   SUFFIX => ".jpg");

		my $result = getstore($_[0]->{url}, $tmp->filename);
		if($result != 200) {
			warn "[WARN] Error fetching $_[0]->{url}: $result\n";
			$sleep = $sleep * 2;
			print "[INFO] Sleeping for $sleep seconds before trying again\n";
		} else {
			chmod 0755, $tmp->filename;
			rename $tmp->filename, $file;
			#print "Fetched $_[0]->{url} to $file\n";
			$sleep = $_->{capture_every};
		}
		sleep($sleep);
	}
}

sub log_thread {
	while(1) {
		sleep($_->{log_every});
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900; $mon += 1;
		my $logpath = "$log/log/$_[0]->{id}/$year-".sprintf("%02d", $mon)."-".sprintf("%02d",$mday)."/";
		if(!-d $logpath) { mkpath($logpath) or warn "[ERROR] Could not create log directory $logpath: $!\n"; }
		my $logfile = "$logpath".time().".jpg";
		my $currentfile = "$log/current/$_[0]->{id}.jpg";

		my $image = Image::Magick->new;
		$x = $image->Read($currentfile);
		warn "$x" if "$x";

		my($width, $height) = $image->Get('width', 'height');
		my $aspect = $width/$height;

		$x = $image->AdaptiveResize(width=>640, height=>(640*$aspect));
		warn "$x" if "$x";

		$x = $image->Write($logfile);
		warn "$x" if "$x";

		print "[INFO] Written $currentfile to $logfile\n";
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
	if(!-d "$log/current") { mkpath("$log/current") or die "[FATAL] Could not make current image store $log/current: $!\n";	}
	if(!-d "$log/tmp") { mkpath("$log/tmp") or die "[FATAL] Could not make temporary image store $log/tmp: $!\n"; }
	if(!-d "$log/log") { mkpath("$log/log") or die "[FATAL] Could not make logging store $log/log: $!\n"; }
}

read_xml;
init;
main;

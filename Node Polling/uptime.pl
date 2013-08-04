#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################

use strict;

my $ERRORCODE = "";

unless(getUptime()==0){
	die($ERRORCODE);
}

sub getUptime{
	#getUptime returns 0 upon success or 1 upon failure
	# prints current uptime in minutes
	my($output, $days, $hours, $minutes);	
	unless($output = `uptime`){
		$ERRORCODE .= "Unable to perform uptime check: $!";
		return 1;
	}
	
	$days = 0;
	$hours = 0;
	$minutes = 0;

	# Linux is a bit flakey in terms of uptime output; the output format is in common english, meaning some conditional parsing is necessary
	if($output =~ m/ +up +([0-9]+) day/){
		$days = $1;
		if($output =~ m/, +([0-9]{1,2}):([0-9]{1,2}),/){
			$hours = $1;
			$minutes = $2;
		}
	}
	elsif($output =~ m/ +up +(\d+) min/){
		$minutes = $1;
	}
	elsif($output =~ m/ +up +([0-9]{1,2}):([0-9]{1,2})/){
		$hours = $1;
		$minutes = $2;
	}
	else{
		$ERRORCODE .= "Unrecognized output format for uptime - $output";
		return 1;
	}
	$output = ($days * 24 + $hours)*60 + $minutes;
	print "$output minutes";
	0;
}





#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################


use strict;
use Time::Local;

my $ERRORCODE = "";
unless(lastRestart()==0){
	die($ERRORCODE);
}

sub lastRestart(){
	# lastRestart() returns the date and time of the last restart
	# Requires Time::Local, linux "uptime" command; platform-dependent
	# Returns 0 upon success, else 1

	my $uptimeSeconds;
	unless($uptimeSeconds = getTime()*60){
		# getTime failure
		$ERRORCODE .= "Unable to get Uptime: $!\n";
		return 1;
	}
	if($uptimeSeconds < 0){
		# getTime failure
		return 1;
	}

	my $last = time - $uptimeSeconds;
	my @out;
	unless(@out = localtime($last)){
		#failure in localtime()
		$ERRORCODE .= "Unable to convert timestamp: $!\n";
		return 1;
	}

	$out[4]+=1;
	for(my $i=1; $i<6;$i++){
		# format output string to 2 digits, leading zeroes
		$out[$i] = sprintf("%02d",$out[$i]%100);
	}
 
	# print date/time of last restart
	print "$out[4]\/$out[3]\/$out[5] $out[2]:$out[1]";
	0;
}


sub getTime{
	# getTime() returns the time since the last restart in minutes.
	# returns -1 upon failure

	my $output;
	unless($output = `uptime`){
		#linux uptime function failed
		$ERRORCODE .= "Unable to perform uptime check: $!\n";
		return -1;
	}
	my $days = 0;
	my $hours = 0;
	my $minutes = 0;

	if($output =~ m/ +up +([0-9]+) days/){
		$days = $1;
		if($output =~ m/, ([0-9]{1,2}):([0-9]{1,2}),/){
			$hours = $1;
			$minutes = $2;
		}
	}
	elsif($output =~ m/ +up +(\d+) min/){
		$minutes = $1;
	}
	elsif($output =~ m/ +up +(\d{1,2}):(\d{1,2}),/){
		$hours = $1;
		$minutes = $2;
	}
	else{
		# Output is in unexpected format, as such cannot be properly parsed
		$ERRORCODE .= "Unexpected output\n";
		return -1;
	}

	$output = ($days * 24 + $hours)*60 + $minutes;
	if ($output==0){
		$output = 1;
	}
	$output;
}




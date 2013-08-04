#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################

use strict;

my $ERRORCODE = "";

unless(getTime() == 0){
	die($ERRORCODE);
}

sub getTime{
	# getTime() returns the time, using Perl's platform-independent time library
	# Returns 0 upon success, else 1

	my @myTime;
	unless(@myTime = localtime(time)){
		$ERRORCODE .= "Unable to get LocalTime: $!";
		return 1;
	}
	for(my $i = 0; $i<6; $i++){
		$myTime[$i] = sprintf("%02d",$myTime[$i]%100);
	}
	$myTime[4]+=1;
	print "$myTime[4]"."/"."$myTime[3]"."/"."$myTime[5] $myTime[2]:$myTime[1]:$myTime[0]";
	0;
}



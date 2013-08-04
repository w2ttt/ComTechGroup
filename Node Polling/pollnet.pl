#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################


use strict;

my $ERRORCODE = "";
#my $ipAddr = "localnode";
my $ipAddr = "192.168.1.1";
my $count = 3;
my $minMaxAvg = "";


unless(getMMA() == 0){
	usage();
	die($ERRORCODE);
}

unless(pollNet($count) == 0){
	die($ERRORCODE);
}

sub pollNet{
	# pollnet(count) will ping the IP address in $ipAddr a total of $count times, and present the max and average values
	# Output is HTML-encoded and separated using the line break HTML element
	# Returns 0 upon success, else 1

	my($str, $count);
	my(@response, @stats);
	$count = shift;
	
	if($count =~ m/\A[0-9]\Z/ && $count < 16){}
	else{
		$count = 3;
	}
	unless($str = `ping -c$count -W400 $ipAddr`){
		$ERRORCODE .= "Unable to execute ping command: $!";
		return 1;
	}
	if($str =~ m/100.0% packet loss/){
		print "Timeout";
		return 0;
	}
	my @response; 
	unless(@response = split(/=/,$str)){
		$ERRORCODE .= "Unable to parse \@response: $!";
		return 1;
	}
	$response[3*$count+1] =~ s/ +//g;
	my @stats;
	unless(@stats = split(/\//,$response[3*$count+1])){
		unless(@stats = split(/\//,$response[3*$count])){
			unless(@stats=split(/\//,$response[3*$count]-1)){
				$ERRORCODE .= "Anomalous result from $ipAddr, refresh page";
				return 1;
			}
		}
	}

	if($stats[2]=~m/\A *\Z/){
		$ERRORCODE .= "Anomalous result from $ipAddr, refresh page";
		return 1;
	}
	if($minMaxAvg eq "min"){
		print "$stats[0]\n";
	}
	elsif($minMaxAvg eq "avg"){
		print "$stats[1]\n";
	}
	elsif($minMaxAvg eq "max"){
		print "$stats[2]\n";
	}
	else{
		usage();
		return 1;
	}
	0;
}

sub getMMA{
	if(defined($ARGV[1])){
		return 1;
	}
	unless(defined($ARGV[0])){
		print "default\n";
		$minMaxAvg = "avg";
		return 0;
	}
	if($ARGV[0] =~ m/\Amin\Z/i || $ARGV[0] =~ m/\Aminimum\Z/i){
		print "min\n";
		$minMaxAvg = "min";
		return 0;
	}
	elsif($ARGV[0] =~ m/\Amax\Z/i || $ARGV[0] =~ m/\Amaximum\Z/i){
		print "max\n";
		$minMaxAvg = "max";
		return 0;
	}
	else{
		print "avg\n";
		$minMaxAvg = "avg";
		return 0;
	}
	usage();
	1;
}

sub usage{
	my $thisScript = $0;
	$thisScript =~ s/\.\///;
	$ERRORCODE .= " $thisScript usage:\n $thisScript [min|max|avg]\n";
	return 0;
}
#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################

use strict;

my $ERRORCODE = "";

# Location of log consisting exclusively of 1 line in the following format:
# "<temp_celsius> <humidity>" (without quotes)
my $LOG_LOCATION = "";

my $humOrTemp = "";

unless(validateInput() == 0){
	usage();
	die($ERRORCODE);
}

unless(updateLogLocation() == 0){
	die($ERRORCODE);
}

unless(pollHumidity() == 0){
	die($ERRORCODE);
}

sub pollHumidity{
	#pollHumidity() accesses $LOG_LOCATION, and pulls the second(space-delimited) field from the file
	#Platform-dependent: requires linux 'cat', 'cut'
	#Returns 0 upon success, else 1

	my $out;
	
	if($humOrTemp eq "hum"){
		unless ($out = `cat $LOG_LOCATION | cut -f2 -d ' '`){
			$ERRORCODE .= "Unable to fetch humidity log: $!";
			return 1;
		}
		$out =~ s/[\n\r]//g;
		$out .= "\%";
	}
	elsif($humOrTemp eq "temp"){
		unless ($out = `cat $LOG_LOCATION | cut -f1 -d ' '`){
			$ERRORCODE .= "Unable to fetch temperature log: $!";
			return 1;
		}
		$out =~ s/[\n\r]//g;
		$out = 9/5*($out)+32;
		$out =~ s/\..//;
	}	
	else{
		usage();
		return 1;
	}

	print $out;
	0;
}

sub updateLogLocation{
	if(defined($ARGV[1])){
		unless(-e $ARGV[1]){
			$ERRORCODE .= "File does not exist\n";
			usage();
			return 1;
		}
		if(-d $ARGV[1]){
			$ERRORCODE .= "Directory provided; should be full file path\n";
			usage();
			return 1;
		}
		else{
			$LOG_LOCATION = $ARGV[1];
		}
	}
	else{
		$LOG_LOCATION = "\/home\/pi\/scripts\/temp.log";
	}
	0;
}

sub validateInput{
	if(defined($ARGV[2])){
		return 1;
	}
	unless(defined($ARGV[0])){
		return 1;
	}
	if($ARGV[0] =~ m/\Ah\Z/i || $ARGV[0] =~ m/\Ahum\Z/i || $ARGV[0] =~ m/\Ahumidity\Z/i){
		# Requested humidity
		$humOrTemp = "hum";
		return 0;
	}
	if($ARGV[0] =~ m/\At\Z/i || $ARGV[0] =~ m/\Atemp*\Z/i || $ARGV[0] =~ m/\Atemperature\Z/i){
		# Requested temperature
		$humOrTemp = "temp";
		return 0;
	}
	1;
}
sub usage{
	#Print appropriate usage example

	my $thisScript = $0;
	$thisScript =~ s/\.\///;
	$ERRORCODE .= " $thisScript usage:\n $thisScript <humidity|temp> [path_to_temp_and_humidity_log]\n";
	return 0;
}


#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################

use strict;

my $ERRORCODE = "";
my $input;

unless(validateInput() == 0){
	usage();
	die($ERRORCODE);
}

unless(loadAverage() == 0){
	die($ERRORCODE);
}

sub loadAverage{
	# loadAverage() provides the system load averages (1/5/15 min), as provided in the output from the unix "uptime" command
	# Returns 0 upon success, else 1

	my $command = `uptime`;
	if($command =~ m/averages*: +(.+) +(.+) +(.+)/){
		my ($a,$b,$c) = ($1, $2, $3);
		$a =~ s/,//;
		$b =~ s/,//;
		$c =~ s/,//;
		$a *=100;
		$b *=100;
		$c *=100;

		if($ARGV[0] eq "1"){
			print "$a\n";
		}
		elsif($ARGV[0] eq "5"){
			print "$b\n";
		}
		elsif($ARGV[0] eq "15"){
			print "$c\n";
		}
		else{
			$ERRORCODE .= "Unexpected result";
			return 1;
		}
	}
	else{
		$ERRORCODE .= "Unable to get averages: $!";
		return 1;
	}
	0;
}

sub validateInput{
	my $input = $ARGV[0];
	if(defined($ARGV[1])){
		return 1;
	}
	unless(defined($ARGV[0])){
		return 1;
	}
	unless($input eq "1" || $input eq "5" || $input eq "15"){
		return 1;
	}
	0;
}

sub usage{
	my $filename = $0;
	$filename =~ s/\.\///;
	$ERRORCODE .= "  $filename usage:\n  $filename <1|5|15>";
	0;
}

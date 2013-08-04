#!/usr/bin/perl

#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################

use Net::SNMP;

my @hosts = @ARGV;

foreach(@hosts){
	main($_);
}
sub main{
	my $hostID = shift;
	my ($session, $error) = Net::SNMP->session(
			-hostname => $hostID,
			-version => "2c",
			-community => "public",
			-timeout => "5",
			);
	$session->max_msg_size(3000);
	if(!defined($session)){
		print $error;
		return 1;
	}
	my $table = $session->get_table(
			-baseoid => ".1.3.6.1.4.1.8072.1.3.2.3.1.1"
			);
my $output = "";
	foreach(keys %$table){
		my $result = $session->get_next_request($_);
		my %rez = %$result;
		$output .= "<tr>";
		foreach(keys %rez){
			my $x = $_;
			my $name = `snmptranslate $x`;
			$name =~ s/NET-SNMP-EXTEND-MIB::nsExtendOutput.+\.//;
			$name =~ s/["\n\r]//g;
			$output .= "<td>$name</td><td>$rez{$x} </td>";
			$output .= "</tr>\n";
		}
	}
	if($session->error){
		my $err = $session->error();
		print "Unable to Poll Host: $err <br/>";
	}
	
	my @outz = split(/\n/,$output);
	$output = "";
	mySort(\@outz);
	foreach(@outz){
		$output .= $_."\n";
	}
	$output .= "\n<br/>";
	print $output;
	$session->close();
	return 0;
}

sub mySort{
	my $inRef = shift;
	my @arr = @$inRef;
	my $size = @arr;
	my $sorted = 0;
	for(my $i=0;$i<$size;$i++){
		for (my $j=$i+1;$j<$size; $j++){
			my $jtmp;
			my $itmp;
			if($arr[$i] =~ m/td>([0-9]+)\)/){
				$itmp = $1;
			}
			if($arr[$j] =~ m/td>([0-9]+)\)/){
				$jtmp = $1;
			}	
			if($jtmp < $itmp){
				my $temp = $arr[$i];
				$arr[$i] = $arr[$j];
				$arr[$j] = $temp;
			}
		}
	}
	@$inRef = @arr;
}

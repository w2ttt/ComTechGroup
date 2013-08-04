#!/usr/bin/perl
#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################

use CGI qw/-nosticky/;

my @hosts; 
my $FILE = "..\/nonCGI\/sweepresults.txt";
my $ERRORCODE = "";

readFile();

sub readFile{
	my $success = 0;
	open(IN,$FILE) or $ERRORCODE = $!;
	while(<IN>){
		my $x = $_;
		$x =~ s/\n\r//g;
		push @hosts,$x;
		$success = 1;
	}
	close(IN);
	unless($success){
		die("Unable to open file\n");
	}
}
my $q = CGI->new;
my @parameters = $q->param;
my $a = $0;
$a =~ s/.+\///g;

# Manually print headers
print "Content-type: text/html", "\n\n";
print "<HTML>\n<head><link rel='stylesheet' type='text/css' href='./styles.css'><title>Web Console</title><\head><body>\n";

#See if user is here from submitting form; act accordingly
if($q->param("submitted") eq '1'){
#run output script, given params
	secondTimePage(\@parameters);	
}
else{
#first time on page; remember to set submitted = 1 on form input
	firstTimePage();
}
print "<br/><footer style='font-size:10px'><p>TrackNode \&\#169; 2013, Jason Stultz
<br/>Licensed under GPLv3, available at <a href='http://opensource.org/licenses/GPL-3.0'>http://opensource.org/licenses/GPL-3.0</a>
<br/>All other rights reserved</p>\n";
print $q->end_html;


sub firstTimePage{
#User is here for first time; present form
#Also possibly redirected as the result of an error - output error message
	my $msg = "";
	$msg = shift;
	print "\n<p style='color:\#FF0000'>$msg</h2>\n";
	print "<H2 style='margin-bottom: 0px;'>Web Console</H2><br/>\n";
	print $q->start_form(-name=>'myform',-action=>$a,-method=>'GET');
	print $q->radio_group(-name=>'viewOpts',-values=>['View All Nodes','View Single Node','View Multiple Nodes'],-default=>'View All Nodes',-linebreak=>'true');
	print "<br/>Enter Single Node Address: <input type='text' name='ip' size='15' maxlength='15' onchange='document.myform.viewOpts[1].checked=true;'><br/> - OR -<br/> Select Multiple Nodes:<br/>";

	my $evenOdd = 0;
	foreach(@hosts){
		$evenOdd = ($evenOdd+1) % 3;
		my $x = $_;

		print "<input type='checkbox' name='a' value='$x' onchange='document.myform.viewOpts[2].checked=true;'\/>$x";

		if($evenOdd == 1 || $evenOdd == 2){
			print "\&nbsp;"x20;
		}
		else{
			print "<br/>";
		}
	}
	print "<br/>"x2;
	print $q->submit;
	print $q->hidden('submitted','1');
	print $q->end_form;
	return;
}
sub secondTimePage{
#User got here by submitting form; present results
	my $ref = shift;
	my @params = @$ref;
	if($q->param(viewOpts) eq "View Multiple Nodes"){
		print "<h2 style='margin-bottom: 0px'>Multiple Nodes</h2>";
		print "\n<a href='$a' style='font-size: 12'> \&\#91;Back to Console\&\#93;</a><br/><br/>\n";
		my @IPAddrs = $q->param('a');
		foreach(@IPAddrs){
			$_ =~ s/\s+//g;
		}
		foreach(@IPAddrs){
			print "<style='margin-bottom: 0px'>For host ";
			my $z = $_;
			my $urlstr = "./"."$a?viewOpts=View+Single+Node&ip=$_"."&submitted=1";
			print "<a href='$urlstr'>$_</a>:";
			print "<br/></style>\n<table>
				<colgroup><col style='width: 20em'><col style='width: 20em'></colgroup>";
			my $out = `../nonCGI/OIDWalk.pl $_`;
			if ($out =~ m/Unable to Poll Host/i){
				$out = "<font color='\#FF0000'>".$out."</font";
			}
			else{
				$out = "<th><b>Parameter</b></th><th><b>Value</b></th>\n".$out;
			}
			print $out;
			print "\n</table>\n<hr>";
		}
	}
	elsif($q->param(viewOpts) eq "View All Nodes"){
		print "<h2 style='margin-bottom: 0px'>All Nodes</h2>";
		print "\n<a href='$a' style='font-size: 12'> \&\#91;Back to Console\&\#93;</a><br/><br/>\n";
		foreach(@hosts){
			print "<style='margin-bottom: 0px'>For host ";
			my $z = $_;
			my $urlstr = "./"."$a?viewOpts=View+Single+Node&ip=$_"."&submitted=1";
			print "<a href='$urlstr'>$_</a>:";
			print "<br/></style>\n<table>
				<colgroup><col style='width: 20em'><col style='width: 20em'></colgroup>";
			my $out = `../nonCGI/OIDWalk.pl $_`;
			if ($out =~ m/Unable to Poll Host/i){
				$out = "<font color='\#FF0000'>".$out."</font";
			}
			else{
				$out = "<th><b>Parameter</b></th><th><b>Value</b></th>\n".$out;
			}
			print $out;
			print "\n</table>\n<hr>";
		}
	}
	elsif($q->param(viewOpts) eq "View Single Node"){	
		my $a = $0;
		$a =~ s/.+\///g;
		my $ip = $q->param('ip');

		if($ip =~ m/\A(\d+)\.(\d+)\.(\d+)\.(\d+)\Z/){
			unless($1 < 255 && $2 < 255 && $3 < 255 && $4 < 255 && $1 > 0 && $2 >=0 && $3 >=0 && $4 >= 0){
				firstTimePage("Invalid IP Address");
			} 
			print "<h2 style='margin-bottom: 0px'>Single Node</h2>";
			print "\n<a href='$a' style='font-size: 12'> \&\#91;Back to Console\&\#93;</a><br/><br/>\n";

			print "<style='margin-bottom: 0px'>For host $ip:</style>\n<table>
				<colgroup><col style='width: 20em'><col style='width: 20em'></colgroup>";
			my $out = `../nonCGI/OIDWalk.pl $ip`;
			if ($out =~ m/Unable to Poll Host/i){
				$out = "<font color='\#FF0000'>".$out."</font";
			}
			else{
				$out = "<th><b>Parameter</b></th><th><b>Value</b></th>\n".$out; 
			}
			print $out;
			print "\n</table>";
		}
		else{
			firstTimePage("Invalid IP Address");
		}
	}
	else{
		firstTimePage();
	}
	return;
}

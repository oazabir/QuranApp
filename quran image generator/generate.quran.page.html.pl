#!/usr/bin/env perl
# بسم الله الرحمن الرحيم
# In the name of Allah, Most Gracious, Most Merciful

# Quran Image Generator
#  Using primary source fonts originating from the King Fahed Complex in Saudi Arabia...
#  <em>As seen on Quran.com</em>

# Authors/Contributors
#  Ahmed El-Helw
#  Nour Sharabash

# The code is copyleft GPL (read: free) but the actual fonts and pages (in the 'data' 
# directory) belong to the King Fahed Complex in Saudia Arabia
# Their URL: http://www.qurancomplex.com

use strict;
use warnings;

use DBI;
use GD;
use GD::Text;
use GD::Text::Align;
use Getopt::Long;
use Pod::Usage;
use List::Util qw/min max/;

# we're using Phi because the height/width and width/height ratios of text
# from pages from a madani mushaf are approximately 1.61 and 0.61, respectively
use constant PHI => ((sqrt 5) + 1) / 2;
use constant phi => (((sqrt 5) + 1) / 2) - 1;

my $self = \&main;
bless $self;

my $dbh = DBI->connect("dbi:SQLite:dbname=./data/text.sqlite3.db","","");

my ($page, $batch) = (undef, undef);

GetOptions(
	'page=i' => \$page,
	'batch' => \$batch
) or pod2usage(1);

if ($batch) {
	$self->generate_batch;
}
else {
	$self->generate_page($page);
}

sub generate_batch {
	for (my $page = 1; $page <= 604; $page++) {
		print "Generating page $page...\n";
		$self->generate_page($page);
	}
}

sub generate_page {
	my ($self, $page) = @_;

	my $hash = {};
	my $page_str = sprintf('%03d', $page);

	my $sth = $dbh->prepare(
		"select line, sura, ayah, text from madani_page_text where page=$page");

	my $font_name;
	my $html = "";

	$sth->execute;
	my $last_ayah = 0;
	my $word = 1;
	my $last_line = 0;
	
	$font_name = "QCF_P$page_str.TTF";
	
	my $surahinfo = $dbh->prepare(
		"select sura, ayah, text from sura_ayah_page_text where page=$page");
	
	my @ayah_numbers = ();
	my $word_info = {};
	
	$surahinfo->execute;
	while (my ($sura, $ayah, $text) = $surahinfo->fetchrow_array) {
		my @chars = split /;/, $text;
		my $last = $chars[-1];
		
		$word = 1;
		foreach my $c (@chars) {
			$word_info->{$c} = [$sura, $ayah, $word++];
		}
		push @ayah_numbers, $last;
	};
	$surahinfo->finish;
	
	while (my ($line, $sura, $ayah, $text) = $sth->fetchrow_array) {
		#$text = $self->_reverse_text($text);
		if (($ayah) && $ayah != $last_ayah) {
			$word = 1;
		}
		
		if ((!$ayah) || ($ayah == 0)){
			$html = $html . "<div class='basmalah line'>" . $text . "</div>\n";
		}
		else {
			
			if ($line != $last_line) {
				$html = $html . "<div class='page$page_str line'>";
			}
			
			$html = $html . "<span id='sura\_$sura\_ayah\_$ayah' class='ayah' sura='$sura' ayah='$ayah'>";	
			
			my @chars = split /;/, $text;
			foreach my $c (@chars)
			{
				my $id = "sura\_$sura\_ayah\_$ayah";
				if ( $c ~~ @ayah_numbers) {
					$id = $id . "_number";
					$html = $html . "<span id='$id' class='ayah_number' sura='$sura' ayah='$ayah'>";					
				} else {
					my ($s, $a, $w) = @{$word_info->{$c}};
					$id = $id . "\_word\_$word";
					$html = $html . "<span id='$id' class='word' sura='$s' ayah='$a' word='$w'>";
				}
				

		    	$html = $html . $c;
				$html = $html . "</span>";
				$word ++;
			}
			
			$html = $html .  "</span>";
			
		
			if ($line != $last_line) {
				$html = $html . "</div>\n";
			}
		}
		
		if ($ayah) {
			$last_ayah = $ayah;
		}
		
		$last_line = $line;
	}
	$sth->finish;


	#my $path = "./output/width_$width/";
	#eval { `mkdir -p $path` };
	#open OUTPUT, ">$path/$page_str.png";
	#binmode OUTPUT;
	#print OUTPUT $gd->png(9); # 0 is highest quality, 9 is highest compression level
	
	
	#my $html_path = "./";
	#eval { `mkdir -p $path` };
	#open OUTPUT, ">$path/$page_str.html";
	#mode OUTPUT;
	#print OUTPUT $html; # 0 is highest quality, 9 is highest compression level


	open(my $before, '<:encoding(UTF-8)', "before.html")
	  or die "Could not open file 'before.html' $!";
 
	while (my $row = <$before>) {
	  chomp $row;
	  print "$row\n";
	}
	
	print "<style type='text/css'>";
	print "    \@font-face {";
	print "     font-family: 'page$page_str';";
	print "     src: url('./data/fonts/$font_name') format('truetype');";
	print "     font-weight: normal;";
	print "     font-style: normal;";
	print "    }";
	print "    .page$page_str { font-family: 'page$page_str'; }";
	print "</style>\n";
	print "<div class='page section' id='page$page_str' pageno='$page_str'>\n";
	print $html;
	print "</div>\n";
	
	open(my $after, '<:encoding(UTF-8)', "after.html")
	  or die "Could not open file 'after.html' $!";
 
	while (my $row = <$after>) {
	  chomp $row;
	  print "$row\n";
	}
	
	
} # sub generate_page

sub _reverse_text {
	my ($self, $text) = @_;
	my @text = split /;/, $text;
	@text = reverse sort @text;
	$text = join ';', @text;
	$text .= ';';
	return $text;
} # sub _reverse_text


__END__

=head1 NAME

generate.quran.page.pl - Generate Qur'an Images for Madani pages

=head1 SYNOPSIS

generate.quran.page.pl --page n --width n [options]


=head1 OPTIONS

	-p    --page     page number to process
	-b    --batch    process the entire Qur'an in one shot
	-w    --width    width of image in pixels
	-s    --scale    scale font size by given factor - overrides width
	-h    --help     print this help message and exit

e.g. './generate.quran.page.pl -p 23 --width=480' would output page 4
     as a png image in the sub 'output' directory.

=cut
# vim: ts=2 sw=2 noexpandtab

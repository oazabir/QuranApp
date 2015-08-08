#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use GD;
use GD::Text;
use GD::Text::Align;
use Getopt::Long;
use Pod::Usage;
use List::Util qw/min max/;

my $self = \&main;
bless $self;

my $dbh = DBI->connect("dbi:SQLite:dbname=./data/text.sqlite3.db","","");

my ($page, $batch) = (undef, undef);

my $hash = {};

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

sub get_meanings {
	my ($self, $page) = @_;
	
	open(my $txt, '<:encoding(UTF-8)', "wordbyword.txt")
	  or die "Could not open file 'wordbyword.txt' $!";
 
	while (my $row = <$txt>) {
	  chomp $row;

	  my @parts = split /\t/, $row;
	  
	}
}

sub generate_page {
	my ($self, $page) = @_;

	my $page_str = sprintf('%03d', $page);
	
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

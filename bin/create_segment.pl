#!/usr/local/bin/perl

=head1 NAME

create_segment - read trsd to create segment data

=head1 SYNOPSIS

./bin/create_segment.pl

=head1 DESCRIPTION

Read TRSD to create segment.txt and segment.dat for further processing

=cut

open (INFILE, "un_edifact_d96b/trsd.96b") || die "can not open trsd.96b for reading";
open (OUTFILE, ">data/segment.txt") || die "can not open segment.txt for writing";

printf STDERR "reading trsd.96b\n";

while (<INFILE>) {
    chop;	# strip record separator
    if (!($. % 64)) {
	printf STDERR '.';
    }
    $f3 = substr($_,6,4);
    $f5 = substr($_,12,46);
    $f7 = substr($_,59,1);
    $f9 = substr($_,62,7);

    $ok = 0;

    if ($_ =~ '^   [+*#|X -][+*#|X -] [A-Z][A-Z][A-Z]   ') {
	$tag = $f3;
	$s = " \$", $tag =~ s/$s//;
	$cod = '';
	$des = $f5;
	$s = '^ *', $des =~ s/$s//;
	$s = " *\$", $des =~ s/$s//;
	$fnr = 0;
	$man = '';
	$typ = '';
	$ok = 1;
    }

    if ($_ =~ '^[0-9][0-9][0-9] [+*#|X -] ') {
	$cod = $f3;
	$des = $f5;
	$s = '^ *', $des =~ s/$s//;
	$s = " *\$", $des =~ s/$s//;
	$fnr++;
	$man = $f7;
	$typ = $f9;
	$ok = 1;
    }

    if ($ok) {
	printf OUTFILE "%s\t%s\t%s\t%s\t%s\t%s\n", $tag, $fnr, $cod, $des, $man, $typ;
    }
}

close(INFILE);
close(OUTFILE);
print STDERR "\n";

0;

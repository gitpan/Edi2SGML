#!/usr/local/bin/perl

=head1 NAME

create_codes - read uncl to create code data

=head1 SYNOPSIS

./bin/create_codes.pl

=head1 DESCRIPTION

Read UNCL to create codes.txt and codes.dat for further processing

=cut

sub read_code {
    chop;	# strip record separator
    if (!($. % 64)) {
	printf STDERR '.';
    }

    $ok = 0;

    if ($_ =~ '^[+*#|X -] [0-9][0-9][0-9][0-9]  ') {
	$cod = substr($_, 2, 4);
	$des = substr($_, 8);
	$s = '^ *', $des =~ s/$s//;
	$s = " *\$", $des =~ s/$s//;
	$fld = '';
	$ok = 1;
    }
    elsif (($_ =~ '^[+*#|X -][+*#|X -] [0-9A-Z ][0-9A-Z ][0-9A-Z ][0-9A-Z ][0-9A-Z ][0-9A-Z] ')
        || ($_ =~ '^[+*#|X -][+*#|X -] [0-9A-Z][0-9A-Z ][0-9A-Z ][0-9A-Z ][0-9A-Z ][0-9A-Z ] '))

      {
	$fld = substr($_, 3, 6);
	$s = ' ', $fld =~ s/$s//g;
	$des = substr($_, 10);
	$s = '^ *', $des =~ s/$s//;
	$s = " *\$", $des =~ s/$s//;
	$ok = 1;
    }

    if ($ok) {
	printf OUTFILE "%s\t%s\t%s\n", $cod, $fld, $des;
    }
}

open (OUTFILE, ">data/codes.txt") || die "can not open segment.txt for writing";

open (INFILE, "un_edifact_d96b/uncl-1.96b") || die "can not open uncl-1.96b for reading";
printf STDERR "reading uncl-1.96b\n";
while (<INFILE>) { read_code(); };
close(INFILE);
print STDERR "\n";

open (INFILE, "un_edifact_d96b/uncl-2.96b") || die "can not open uncl-2.96b for reading";
printf STDERR "reading uncl-2.96b\n";
while (<INFILE>) { read_code(); };
close(INFILE);
print STDERR "\n";

open (INFILE, "un_edifact_d96b/unsl.96b") || die "can not open unsl.96b for reading";
printf STDERR "reading unsl.96b\n";
while (<INFILE>) { read_code(); };
close(INFILE);
print STDERR "\n";

close(OUTFILE);

0;

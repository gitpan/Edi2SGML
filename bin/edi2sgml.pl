#!/usr/local/bin/perl

eval 'exec /usr/local/bin/perl -S $0 ${1+"$@"}'
	if $running_under_some_shell;

# -----------------------------------------------------------------------------

$db= "data";
$debug=1;

&read_database();
&read_message($ARGV[0]);
&process_message();

# -----------------------------------------------------------------------------

sub recode_mark {
	local($mark) = @_;
	local($M,$s);

	$M = lc($mark);
	$s = '[^a-z][^a-z]*', $M =~ s/$s/_/g;
	$s = "_coded\$", $M =~ s/$s//;
	$s = '__*', $M =~ s/$s/./g;
	($M);
}

sub read_database {
	local ($file,$mark,@Fld);

	printf "<!-- *** reading segment -->\n"		if ($debug>1);
	
	$file = $db . '/segment.txt';
	open FILE,$file					|| die "cant open ".$file;

	while (<FILE>) {
		chop;		# strip record separator
		@Fld = split('\t', $_, 9999);
		$mark = &recode_mark($Fld[3]);
		$segment_hash{$Fld[0], $Fld[1]} = $Fld[2] . "\t" . $mark;
	}
	close FILE;

	printf "<!-- *** reading composite -->\n" 	if ($debug>1);
 	
 	$file = $db . '/composite.txt';
	open FILE,$file					|| die "cant open ".$file;
 	while (<FILE>) {
		chop;		# strip record separator
		@Fld = split('\t', $_, 9999);
 		$mark = &recode_mark($Fld[3]);
 		$composite_hash{$Fld[0], $Fld[1]} = $Fld[2] . "\t" . $mark;
 	}
	close FILE;

	printf "<!-- *** reading codes -->\n"		if ($debug>1);

	$file = $db . '/codes.txt';
	open FILE,$file					|| die "cant open ".$file;
 	while (<FILE>) {
		chop;		# strip record separator
		@Fld = split('\t', $_, 9999);
		$cod{$Fld[0], $Fld[1]} = $Fld[2];
		if ($Fld[1] ne '') {
			$codes{$Fld[0]}++;
		}
	}
	close FILE;
}

# -----------------------------------------------------------------------------

sub read_message() {
	local($filename) = @_;
	local($size);

	printf "<!-- *** reading message -->\n"		 if ($debug>1);

	$size=(stat($filename))[7]		|| die "cant stat ".$filename;
	die $filename." is to short ".$size." for EDI" 	if ($size <= 9);
	open(F,$filename)			|| die "cant open ".$filename;
	read(F,$raw_message,$size,0)		|| die "cant read message from ".$filename;
	close(F);

	$advice=substr($raw_message,0,9);
	die $filename." is not an EDI message"	if ($advice !~ "^UNA");

	$advice_component_seperator =substr($advice,3,1);
	$advice_element_seperator   =substr($advice,4,1);
	$advice_decimal_notation    =substr($advice,5,1);
	$advice_release_indicator   =substr($advice,6,1);
	$advice_segment_terminator  =substr($advice,8,1);
}

sub process_message() {
	local($cooked_message,@Segments,$segment,$s);

	$cooked_message  = $raw_message;
	$s = "\\".$advice_release_indicator."\\".$advice_segment_terminator;
	$cooked_message =~ s/$s/\001/g;

	@Segments = split /$advice_segment_terminator/, $cooked_message;
	shift @Segments;

	foreach $segment (@Segments) {
		$s = "\\".$advice_segment_terminator;
		$segment =~ s/\001/$s/g;
		&resolve_segment($segment);
	}
}

# -----------------------------------------------------------------------------

sub resolve_segment {
	local($raw_segment) = @_;
	local($cooked_segment,@Elements,$element,$s,$i);
	local($sg,@sgv);

	printf "<!-- *** %s -->\n", $raw_segment	if ($debug);

	$cooked_segment = $raw_segment;
	$s = "\\".$advice_release_indicator."\\".$advice_element_seperator;
	$cooked_segment =~ s/$s/\001/g;

	$s = "\\".$advice_element_seperator;
	@Elements = split /$s/, $cooked_segment;

	$sg = $segment_hash{$Elements[0], 0};
	@sgv = split("\t", $sg, 2);
	$segment_name = $sgv[1];

	printf "<!-- *** name %s -->\n", $segment_name	if ($debug>2);

	&open_mark($segment_name);

	for ($i = 1; $i <= $#Elements; $i++) {
		$element  = $Elements[$i];
		$element =~ s/\001/$advice_element_seperator/g;

		if ($Elements[$i] ne '') {
			&resolve_element(
				$segment_name, $Elements[0],
				$i, $Elements[$i]);
		}
	}
	&close_mark($segment_name);
}

# -----------------------------------------------------------------------------

sub resolve_element {
	local($name, $id, $pos, $raw_element) = @_;
	local($cooked_element,@Components,$component,$s,$i);
	local($sg,@sgv);
	local($cm,@cmv);

	printf "<!-- *** resolve element %s, %s, %s, %s -->\n", $name, $id, $pos, $raw_element if ($debug>1);

	$sg = $segment_hash{$id, $pos};
	if ($sg ne '') {
		$cooked_element = $raw_element;
		$s = "\\".$advice_release_indicator."\\".$advice_component_seperator;
		$cooked_element =~ s/$s/\001/g;

		@sgv = split("\t", $sg, 2);

		if ($sgv[0] =~ '^C') {
			&open_mark($sgv[1]);

			$s = "\\".$advice_component_seperator;
			@Components = split(/$s/, $cooked_element, 9999);
			foreach $i (0 .. $#Components) {
				$component = $Components[$i];
				if ($component ne '') {
					$s = $advice_component_seperator;
					$component =~ s/\001/$s/g;
					$cm = $composite_hash{$sgv[0], $i+1};
					@cmv = split("\t", $cm, 2);
					&resolve_code($cmv[1], $cmv[0], $component);
				}
			}

			&close_mark($sgv[1]);
		}
		else {
			$s = $advice_component_seperator;
			$cooked_element =~ s/\001/$s/g;
			&resolve_code($sgv[1], $sgv[0], $cooked_element);
		}
	}
	else {
		printf "<!-- *** %s\t%s\t%s -->\n", $id, $pos, $raw_element;
	}
}

# -----------------------------------------------------------------------------

sub resolve_code {
	local($mark, $id, $val) = @_;
	printf "<!-- *** resolve code %s, %s, %s -->\n", $mark, $id, $val if ($debug>1);

	&open_mark($mark);
	if ($codes{$id}) {
		$cd = $cod{$id, $val};
		&add_code($mark, $val);
		if ($cd ne '') {
			&add_val($mark, $cd);
		}
		else {
			&add_val($mark, $val);
		}
	}
	else {
		&add_val($mark, $val);
	}
	&close_mark($mark);
}

# -----------------------------------------------------------------------------

sub open_mark {
	local($mark) = @_;
	printf "<!-- *** open mark %d, %s -->\n", $markstackp, $mark if ($debug>2);

	$markstack{++$markstackp} = $mark;
	$markopt{$markstackp} = '';
	$markval{$markstackp} = '';
}

sub close_mark {
	local($mark) = @_;
	printf "<!-- *** close mark %d, %s -->\n", $markstackp-1, $mark if ($debug>2);
	
	if ($markval{$markstackp} ne '') {
		if ($markval{$markstackp} !~ "[</\n]") {
			if ($markopt{$markstackp} ne '') {
				$vt = " coded=\"" . $markopt{$markstackp} . "\"";
			}
			else {
				$vt = '';
			}
			$v = sprintf('<%s%s/%s/', 
			$markstack{$markstackp}, $vt, $markval{$markstackp});
		}
		else {
			if ($markopt{$markstackp} ne '') {
				$vt = " coded=\"" . $markopt{$markstackp} . "\"";
			}
			else {
				$vt = '';
			}
			$v = sprintf("<%s%s>\n%s\n</%s>", 
			$markstack{$markstackp}, 
			$vt, 
			$markval{$markstackp}, 
			$markstack{$markstackp});
		}
		if ($markstackp != 1) {
			$s = '^', $v =~ s/$s/  /;
			$s = "\n", $v =~ s/$s/\n  /g;
			&add_val($markstack{$markstackp - 1}, $v);
		}
		else {
			printf "%s\n", $v;
		}
	}
	$markopt{$markstackp} = '';
	$markval{$markstackp} = '';
	$markstack{$markstackp--} = '';
}

sub add_code {
	local($mark, $code) = @_;
	printf "<!-- *** add code %s, %s -->\n", $mark, $code if ($debug>3);
	
	for ($k = 1; $k <= $markstackp; $k++) {
		if ($markstack{$k} eq $mark) {
			$markopt{$k} = $markopt{$k} ? $markopt{$k} . ':' : '' . $code;
			last;
		}
	}
}

sub add_val {
	local($mark, $val) = @_;
	printf "<!-- *** add val %s, %s -->\n", $mark, $val if ($debug>3);
	
	for ($k = 1; $k <= $markstackp; $k++) {
		if ($markstack{$k} eq $mark) {
			if ($markval{$k} ne '') {
				$markval{$k} = $markval{$k} . "\n" . $val;
			}
			else {
				$markval{$k} = $val;
			}
			last;
		}
	}
}

# -----------------------------------------------------------------------------

0;

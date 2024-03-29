#! @PERL@

# This file is part of the Orrery, a solar system simulator for
# Geomview (see www.geomview.org for details).
#
# The orrery is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# The orrery is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the Orrery; see the file COPYING.  If not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.

$maglim = 5.5; # Faintest visible star
$magdiam = 2.2; # diameter (pixels) of star 1 mag brigher than maglim
$colormag = 3.0; # Faintest star we try to color
$R = 70;

if (@ARGV == 0 && -t STDIN) {
  print STDERR "Usage: $0 [-m maglim] [-d diam] [-c colorlim] [-r radius]  yale.star > stars.oogl
Extracts stars from yale.star file brighter than maglim (default $maglim),
showing stars 1-mag-brigher than maglim as diam-pixel dots (default $magdiam),
coloring by spectral type all stars brighter than colorlim (default $colormag),
arranging stars on sphere of given radius (default $R).
yale.star file, derived from Yale Bright Star Cat, is part of \"starchart\":
    ftp://ftp.uu.net/usenet/comp.sources.unix/volume12/starcharts/
";
  exit(1);
}

while($ARGV[0] =~ /^-[mdcr]/) {
    shift, $maglim = shift if $ARGV[0] =~ /^-m/;
    shift, $mag0diam = shift if $ARGV[0] =~ /^-d/;
    shift, $colormag = shift if $ARGV[0] =~ /^-c/;
    shift, $R = shift if $ARGV[0] =~ /^-r/;
}


$maglim = shift if $ARGV[0] =~ /^[-.\d]+$/;
$magdiam = shift if $ARGV[0] =~ /^[-.\d]+$/;
$colormag = shift if $ARGV[0] =~ /^[-.\d]+$/;

$rwas = -1;
$pi = 3.1415926;
$classes = <<EOF;
W	.5 1 1
O	.7 .8 1
B	.9 .9 1
A	1 1 1
F	1 1 .9
G	1 1 .8
K	1 .8 .7
M	1 .7 .5
EOF

foreach $_ (split("\n", $classes)) {
    ($color, $r, $g, $b) = split(' ', $_);
    $r{$color} = $r;
    $g{$color} = $g;
    $b{$color} = $b;
}

sub dump {
    if ($nv > 0) {
	$ncol = $lastcolored+1;
	if($ncol > 0 && $ncol < $nv) {
	    $rgb[$ncol++] = "1 1 1";
	}
	printf "appearance { linewidth %d } VECT %d %d %d\n",
		$oldsize, $nv, $nv, $ncol;
	print "1 " x $nv, "\n";
	print "1 " x $ncol, "0 " x ($nv-$ncol), "\n";
	for ($i = 0; $i < $nv; $i++) {
	    print $xyz[$i], "\n";
	}
	for ($i = 0; $i < $ncol; $i++) {
	    print $rgb[$i] . " 1\n";
	}
	print "\n";
    }
    $oldsize = $wholesize;
    $nv = 0; $lastcolored = -1;
}

printf "# stargv -m %.3g -d %.3g -c %.3g  %s\n", $maglim, $magdiam, $colormag, join(@ARGV, " ");

print "appearance { material { edgecolor 1 1 1 } } { LIST\n";

while(<>) {
    $ra = $pi/12 * (substr($_,0,2) + substr($_,2,2) / 60
				+ substr($_,4,2) / 3600);
    $dec = $pi/180 * (substr($_,6,1) . (substr($_,7,2) + substr($_,9,2)/60));
    $mag = substr($_, 11, 3) / 100;
    $mag *= 10 if ($mag < 0);

    next if ($mag > $maglim);

    $size = sqrt($maglim - $mag) * $magdiam;
    $color = substr($_, 16, 1);
    $color = 'A' unless defined $r{$color};
    $wholesize = int($size + .5);
    if ($wholesize != $oldsize) {
	&dump;
    }
    $xyz[$nv] = sprintf("%.2f %.2f %.2f", $R*cos($ra)*cos($dec),
			   $R*sin($ra)*cos($dec), $R*sin($dec));
    if ($mag < $colormag) {
	$light = ($size - $wholesize) * .25 + .875;
	$light = 1 if $light > 1;
	$rgb[$nv] = sprintf("%.2f %.2f %.2f", $light * $r{$color},
			   $light * $g{$color}, $light * $b{$color});
	$lastcolored = $nv;
    } else {
	$rgb[$nv] = "1 1 1";
    }
    $nv++;
}

&dump();
print "}\n";

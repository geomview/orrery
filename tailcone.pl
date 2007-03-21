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

if(@ARGV == 0) {
  print STDERR "Usage: $0 -z length -r width -n nrings[,nsides]  alpha0 [alpha1]
Writes a MESH representing a cone (or paraboloid), with opacity ranging
from alpha0 at the vertex to alpha1 at the edge.
";
  exit(1);
}

$zmax = 1;
$rmax = 1;
$nu = 2;
$nv = 6;

while($ARGV[0] =~ /-[rzn]/) {
  shift, $zmax = shift if $ARGV[0] =~ /-z/;
  shift, $rmax = shift if $ARGV[0] =~ /-r/;
  if($ARGV[0] =~ /-n/) {
    shift;
    $nu = $1 if $ARGV[0] =~ /^(\d+)/;
    $nv = $1 if $ARGV[0] =~ /[^\d](\d+)/;
    shift;
  }
}

$alpha0 = shift if($ARGV[0] =~ /^[.\d]+$/);
$alpha1 = shift if($ARGV[0] =~ /^[.\d]+$/);

print "# tailcone -z $zmax -r $rmax -n ${nu}x${nv}  $alpha0  $alpha1\n";
print "CvMESH\n";
print "$nu $nv\n\n";
$suf = $nu>2 ? "\n" : "\t";
for($v = 0; $v < $nv; $v++) {
  $th = 6.28318*$v/$nv;
  $x = cos($th);
  $y = sin($th);
  for($u = 0; $u < $nu; $u++) {
    $tu = $u/($nu-1);
    $r = $rmax * $tu;
    $z = $zmax * $tu*$tu;
    $a = $alpha0 + ($alpha1-$alpha0)*sqrt($tu);
    printf "%.4f %.4f %.4f  1 1 1 %.3f%s", $r*$x,$r*$y,$z, $a, $suf;
  }
  print "\n";
}

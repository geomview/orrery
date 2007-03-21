#! @PERL@

if(@ARGV == 0 && -t STDOUT) {
  print STDERR "Usage: $0 {-stereo|-sinu|-rect|-cyl|-oneface} usize vsize > mesh.oogl
Writes an OOGL MESH with texture coordinates applied variously:
  -stereo : stereographic projection from the south (Z=-1) pole
  -sinu   : sinusoidal equal-area projection
  -rect   : rectangular proj: x ~ longitude, y ~ sin(lat) (i.e. Z on sphere)
  -cyl    : cylindrical proj: x ~ longitude, y ~ latitude
  -oneface: stretch orthographic view of +Y hemisphere over both, mirroring
usize and vsize are the number of mesh points on the sphere around the
equatorial (u) & polar (v) directions; ideally usize ~ 2*vsize, default 40 20.
";
  exit(1);
}

$map = "oneface";
if ($ARGV[0] =~ /-st/) {
   $map = "stereographic", shift;
} elsif ($ARGV[0] =~ /-s/) {
   $map = "sinusoidal", shift;
} elsif ($ARGV[0] =~ /-r/) {
   $map = "rectangular", shift;
} elsif ($ARGV[0] =~ /-c/) {
   $map = "cylindrical", shift;
} elsif ($ARGV[0] =~ /-o/) {
   $map = "oneface", shift;
}

($nu, $nv) = (40, 20);
($nu, $nv) = @ARGV, shift, shift if($ARGV[0] =~ /^(\d+)x?(\d*)/);

$pi = 3.1415926535;
print "# $0 -$map $nu $nv\n";
print "appearance {\n";
print "	*-evert\n";
print "	+backcull\n";
print "	shading smooth\n";
print "}\n";
print "NUMESH\n";
print "${nu+1} $nv\n";

# latitude ranges from -0.5*$pi .. 0.5*Pi
for($v=0; $v<$nv; $v++) {
    $vfrac = $v / ($nv-1);
    $lat = (.5 - $vfrac) * $pi;
    $z = sin($lat);
    $r = cos($lat);
    for($u=0; $u <= $nu; $u++) {
	$ufrac = $u/$nu;
	$lon = $ufrac*2*$pi;
	$x = $r*cos($lon);
	$y = $r*sin($lon);
	if($map eq "sinusoidal") {
	   $s = .5 + $r * ($ufrac - .5);
	   $t = 1 - $vfrac;
	} elsif($map eq "cylindrical") {
	   $s = $ufrac;
	   $t = 1 - $vfrac;
	} elsif($map eq "rectangular") {
	   $s = $ufrac;
	   $t = ($z + 1) * .5;
	} elsif($map eq "stereographic") {
	   $s = .5 + $x/(1 + ($z < -.99 ? .01 : $z));
	   $t = .5 + $y/(1 + ($z < -.99 ? .01 : $z));
	} else {
	   # "oneface" map
	   $s = ($x + 1) * .5;
	   $t = ($z + 1) * .5;
	}
	printf "%.4f %.4f %.4f  %.3f %.3f %.3f  %.4f %.4f 0\n",
	    $x, $y, $z, $x,$y,$z, $s, $t;
    }
    print "\n";
}

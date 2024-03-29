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

if(-t STDOUT) {
  print STDERR "Usage: $0 | quick > .../Geomview/data/modules/orrery/orrery.elements
Drives JPL's program \"quick\" to emit orbital elements and physical data
in the form read by the Orrery module.
If you don't have quick, too bad.  See the comments in the supplied
orrery.elements file, which should be enough to let you add new bodies.
";
  exit(1);
}

# Pipe this script's output to "quick", and save the output in orrery.elements:
#  getelem | quick > orrery.elements

$\ = "\n";

print "on double";
print "off print";
print "prompt = ''";
print "epoch=date(19960100)";	# Jan 0, 1996
print "cbodyn(epoch,0,0)";
print "au = plelem(epoch,3)(1)";

@sats = (9, 0,0,1,2, 7, 9, 5, 2, 1);

sub emit {
    local($is, $ip) = @_;
    print "cname = cbodyn(epoch, 0, $ip)";
    print "name = cbodyn(epoch, $is, $ip)";
    print "print 'NAME = ',name";
    print "print 'CENTER = ',cname";
    $elem = "satelm(epoch,$is,$ip)";
    if($is == 0) {
	$elem = "plelem(epoch,$ip)";
    } elsif($ip == 0) {
	$elem = "plelem(epoch,$is)";
    }
    if($is || $ip) {
	print "orbin($elem,1)";
	print "elem = orbout(1)";
	print "cbodyn(epoch,0,$ip)";
	print "orbin($elem,1)";
	print "period = orbout(101)(1)";
	print "putstr(stdout, sprint('(''ELEM ='',6(X,G22.15),A)', elem, CHAR(10)))";
	print "print period";
	print "Torbit = (pa, ucross(ob,pa), ob)";
	print "print Torbit";
	print "cbodyn(epoch,$is,$ip)";
    }
    print "print rpl";
    print "print gm";
    print "print oj2";
    print "print sprint('(''PV ='',3(X,F12.8))',pv)";
    print "print sprint('(''PM ='',3(X,F12.8))',pm)";
    print "print rot";
}

&emit(0,0);
foreach $center (1..$#sats) {
    &emit($center, 0);
    foreach $sat (1..$sats[$center]) {
	&emit($sat, $center);
    }
}
print "year = orbout(101)(1)\n";

# while(<>) {
#    @F = split(' ');
#    print "name = astput($F[1],10)\n";
#    print "orbin( plelem(d,10), 1 )\n";
#    print "axis = -PA; period = ORBOUT(101)(1)/year\n";  
#    print "PRINT sprint('(3(F8.4,X),X,G10.5,2X,A)',axis,period,name)\n";
# }

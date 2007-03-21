#! @TCLSH@ 

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

if {[llength $argv] < 6} {
  puts stderr "Usage: $argv0  e  q(Rperi)  Tp(mm/dd.dd/yyyy) W(Node) w(peri) incl(i)  name
Given orbital elements for a comet with an elliptical orbit, specified
with respect to its perihelion date and distance, emit an entry which
could be added to orrery.elements.

Parameters are:
  e	eccentricity (should be less than 1; we fake it with a 1000-year
		orbit if it's nearly 1, since this Orrery can't handle
		parabolic or hyperbolic orbits)
  q	distance from sun at perihelion, in AU
  Tp	date of perihelion, in form mm/dd.dd/yyyy, or as Julian date
  W	ecliptic longitude of ascending node (epoch 2000)
  w	argument of perihelion
  i	inclination of orbit to ecliptic
  name  Name with which it should appear; shouldn't contain blanks
"
  exit 1
}

set tcl_precision 17

proc peri2elem {ee q Tp W w i {name "Comet"}} {
  if {$ee < .999} {
    set e $ee
  } else {
    set e .999
  }
  # Semimajor axis in AU: q = a*(1-e)
  set a [expr $q/(1.-$e)]
  # In kilometers, too.
  set akm [expr $a*149597927.]

  # Period: from Kepler's laws, a^3 ~ P^2.  We want it in seconds,
  # so multiply by 1 year.
  set P [expr $a*sqrt($a)*31558213.605578]

  # Now, how far is the Orrery's epoch (1996.0, sorry) from
  # our perihelion?  That, as a fraction of the period, is the mean anomaly.
  # str2date's value is in mean solar days, so we scale P to days, too,
  # and multiply by 360 for degrees.
  set anom [expr -360.*[str2date $Tp]/($P/86400.)]
  # Prefer mean anomaly values close to zero.
  set anom [expr $anom-int($anom)]
  set anom [expr $anom<-.5 ? $anom+1 : ($anom>.5 ? $anom-1 : $anom)]

  # Now for it.
  # We know it's not really 3000 km across, but this makes it
  # easy to see.
  return "NAME = $name
CENTER = Sun
ELEM = $akm $e $i $W $w $anom
PERIOD = $P
RPL = 3000.
GM = 0
OJ2 = 0
PV = 0 0 1
PM = 1 0 0
ROT = 1"
}


set mdays {0 0 31 59 90 120 151 181 212 243 273 304 334 365 396}
set mnames {0 Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}
set epochyear 1996.0
set epochJD 2450082.5

proc str2date {astr} {
  global mdays epochyear epochJD year debug
  set str $astr
  set hour 0; set min 0; set sec 0; set mm 1; set dd 1
  set yyyy $epochyear
  if {[scan $str {%f%c} jd junk] == 1} {	;# Expect just a single number
	return [expr $jd - $epochJD]
  }
  if {[regexp {([0-9]+:[0-9.:]+)} $str hms]} {
	regsub {[       ]*[0-9]+:[0-9.:]+[      ]*} $str {} str
	scan $hms %f:%f:%f hour min sec
  }
  if {[regexp {^[-.0-9eE]+$} $str] && [catch {set yyyy [expr 0.+$str]}] == 0} {
	set mm 1
	set yyyy [expr int(floor($str))]
	set dd [expr ($str-$yyyy)*[daysin $yyyy]]

  } elseif {[scan $str %f/%f/%f mm dd yyyy] > 1} {
	# Fine.
  } elseif {[scan $str %d.%d.%d yyyy mm dd] <= 1} {
	# Failed.
	puts stderr "Can't understand date string: $str"
	return 0
  }
  set m0 [lindex $mdays [expr int($mm+0)]]
  set iy [expr int($yyyy)]
  if {$mm>2 && $iy%4 == 0 && $iy%400 != 0} {
	incr m0
  }
  set y0 [expr ($yyyy - $epochyear)*365 \
	+ floor(($iy-1)/4) - floor(($epochyear-1)/4) \
	- floor(($iy-1)/400) + floor(($epochyear-1)/400)]
  return [expr $y0 + $m0 + $dd + (($sec/60. + $min)/60. + $hour)/24.]
}

proc daysin {year} {
  expr ((int($year)%4 == 0) && (int($year)%400 != 0)) ? 366 : 365
}


puts [eval peri2elem $argv]

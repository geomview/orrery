#! /usr/local/bin/tclsh

# Copyright (c) 1995, Geometry Center, University of Minnesota
# Script by Stuart Levy, Geometry Center.
# Uses Hershey fonts as encoded for Ghostscript.
# This program may be freely used and redistributed so long as
# this notice remains.

# Configurable value: if you have Ghostscript Hershey fonts installed on your
# system, you might want to set $gsfontdir to the directory where they live.
# "-hershey" will seek files there if not found relative to ".".
# This could be a colon-separated list of directories.

set gsfontpath "/usr/local/lib/ghostscript/fonts"
catch {set gsfontpath $env(GS_FONTPATH)}

proc vectext {args} {
  global cstate
  set at(0) 0; set at(1) 0; set at(2) 0
  set ujust -.5; set vjust -.5
  set uaxis 0; set vaxis 1
  set usign 1; set vsign 1
  set height .25
  set slant 0
  set cstate(gsfont) {}
  set cstate(u) 0; set cstate(v) 0
  set cstate(npts) 0
  set cstate(ptv) {}

  # Generic Hershey font properties
  set fontscale [expr 1./33.]
  set aspect .67

  set ax(x) 0; set ax(y) 1; set ax(z) 2
  set ax(0) x; set ax(1) y; set ax(2) z
  for {set i 0} {$i<[llength $args]} {incr i} {
    switch -glob -- [lindex $args $i] {
     -w* {set totallen [lindex $args [incr i]]}
     -s -
     -hei* -
     -si* {set height [lindex $args [incr i]]}
     -sl* {set slant [expr sin([lindex $args [incr i]]/57.3)]}
     -pl* {
	set pl [string tolower [lindex $args [incr i]]]
	set su +; set sv +; set uax x; set vax x
	regexp {^([-+]?)([xyz])([-+]?)([xyz])$} $pl junk su uax sv vax
	set uaxis $ax($uax)
	set vaxis $ax($vax)
	set usign [eval expr ${su}1]
	set vsign [eval expr ${sv}1]
	if {![info exists uaxis] || ![info exists vaxis] || $uaxis==$vaxis} {
	    error "vectext: -plane $pl: expected e.g. xy or -y+z"
	}
       }
     -al* {
	set al [lindex $args [incr i]]
	set ujust -.5; set vjust -.5
	if {[string match *e* $al]} {set ujust -1}
	if {[string match *w* $al]} {set ujust 0}
	if {[string match *n* $al]} {set vjust -1}
	if {[string match *s* $al]} {set vjust 0}
	if {[regexp -- {[^nsewc]} $al]} {
	    error "vectext: -align $al: expected some combination of letters n s e w c"
	}
       }
     -at {
	set at(0) [lindex $args [incr i]]
	if {[llength $at(0)]==3} {
	  set at(1) [lindex $at(0) 1]
	  set at(2) [lindex $at(0) 2]
	  set at(0) [lindex $at(0) 0]
	} else {
	  set at(1) [lindex $args [incr i]]
	  set at(2) [lindex $args [incr i]]
	}
      }
     -her* {
	set gsbase [lindex $args [incr i]]; set ok 0
	foreach dir [split $gsfontpath :] {
	  set gsfont "$dir/$gsbase"
	  if {[file exists $gsfont]} {break}
	}
	if {[info exists cstate(fontloaded)]} {unset cstate(fontloaded)}
      }
     -sub {
	set vwas $cstate(v)
	set cstate(v) [expr $vwas-.2/$fontscale]
	append stuff "[vrender cstate [lindex $args [incr i]] .7]\n"
	set cstate(v) $vwas
      }
     -sup {
	set vwas $cstate(v)
	set cstate(v) [expr $vwas+.5/$fontscale]
	append stuff "[vrender cstate [lindex $args [incr i]] .7]\n"
	set cstate(v) $vwas
      }
     -text {
	append stuff "[vrender cstate [lindex $args [incr i]] 1]\n"
      }
     -- { incr i; break }
     default { break }
    }
  }
  append stuff  [vrender cstate [join [lrange $args $i end] " "] 1]

  # Compute scaling.
  set strwidth $cstate(u)
  if {$strwidth==0} {set strwidth 1}
  if {[info exists totallen]} {
    set scl [expr double($totallen)/$strwidth]
    set height [expr $scl * $aspect / $fontscale]
  } else {
    set scl [expr $fontscale * $height / $aspect]
    set totallen [expr $scl * $strwidth]
  }
  # Justify.
  set at($uaxis) [expr $at($uaxis) + $usign*$ujust*$totallen]
  set at($vaxis) [expr $at($vaxis) + $vsign*$vjust*$height]


  # Expression to transform a point.  Precalculate constants.
  set putpt {format "%.5g %.5g %.5g\n"}
  foreach i {0 1 2} {
    if {$uaxis==$i} {
	set shear {}
	if {$slant!=0} {
	  set shear "+[expr $vsign*$scl*$slant]*\[lindex \$ppt 1\]"
	}
	append putpt " \[expr $at($i)+[expr $usign*$scl]*\[lindex \$ppt 0]$shear\]"
    } elseif {$vaxis==$i} {
	append putpt " \[expr $at($i)+[expr $vsign*$scl]*\[lindex \$ppt 1]\]"
    } else {
	append putpt " $at($i)"
    }
  }

  # Remember location & orientation for next time
  set ppt [list $cstate(u) 0]
  set cstate(at) [string trim [eval $putpt]]

  # Emit VECT header
  #  "+1x-1z" -> "+x-z"
  regsub -all {1} "$usign$ax($uaxis)$vsign$ax($vaxis)" {} pl
  regsub -all {[0-9]+} $cstate(ptv) {0} colorv
  set vect "# Continue with: -at $cstate(at) -align sw -s $height -plane $pl
{"
  # Avoid ``{ VECT 0 0 0 }'' if we've no text -- it's invalid.
  # Say ``{ }'' instead.
  if {$cstate(npts)>0} {
    append vect " VECT
[llength $cstate(ptv)] $cstate(npts) 0
[join $cstate(ptv) \n]

[join $colorv \n]

"
    foreach pline $stuff {
    set glop {}
	foreach ppt $pline {
	  append glop [eval $putpt]
	}
	append vect "$glop\n"
    }
  }
  append vect "}"
}

proc vreadfontline {cst cnm line} {
  if {[regexp {^/([^ ]*) +\[([-0-9]+) ([-0-9]+) \((.*)\)] def} $line all ch pre post code]} {
    if {[info exists cname($ch)]} {
      set ch $cname($ch)
    }
    regsub -all -- {\\(.)} $code {\1} code
    upvar $cst cstate $cnm cname
    if {[info exists cname($ch)]} {set ch $cname($ch)}
    set cstate(size,$ch) [list $pre $post]
    set cstate(code,$ch) $code
    return 1
  }
  return 0
}

proc vrender {cst string {strscale 1}} {
  upvar $cst cstate
  if {![info exists cstate(fontloaded)]} {
    vloadfont cstate $cstate(gsfont)
  }
  set rstr {}
  set str $string
  while {[set bsl [string first {\\} $str]]>=0} {
    append rstr [string range $str 0 [expr $bsl-1]]
    incr bsl
    switch -glob -- [string index $str $bsl] {
	n { append rstr "\n" }
	b { append rstr "\b" }
	r { append rstr "\r" }
	e { append rstr "\e" }
	[0-7] {
	  regexp {.[0-7]?[0-7]?} $str oct
	  scan $oct %o ch
	  append rstr ch
	  incr bsl [expr [string length $oct]-1]
	}
	default {
	  append rstr [string index $str $bsl]
	}
    }
    set str [string range $str [incr bsl] end]
  }
  append rstr $str

  set lines {}
  set pts 0
  set ptv {}
  foreach ch [split $rstr {}] {
    if {[info exists cstate(code,$ch)]} {
	set umin [lindex $cstate(size,$ch) 0]
	set usize [expr [lindex $cstate(size,$ch) 1]-$umin]
	set u0 [expr $cstate(u)-(82+$umin)*$strscale]
	set v0 [expr $cstate(v)+91*$strscale]
	set code $cstate(code,$ch)
	foreach pline [split $code] {
	  set oline {}
	  for {set i 0} {[scan [string range $pline $i end] %c%c cu cv]==2} {incr i 2} {
	    append oline [format "{%.5g %.5g} " [expr $u0+$cu*$strscale] [expr $v0-$cv*$strscale]]
	  }
	  set ptsnow [expr [string length $pline]/2]
	  lappend cstate(ptv) $ptsnow
	  incr pts $ptsnow
	  lappend lines $oline
	}
	set cstate(u) [expr $cstate(u) + $strscale*$usize]
    }
  }
  incr cstate(npts) $pts
  set lines
}


proc vloadfont {cst font} {
  upvar $cst cstate

  set cnames {
exclam !
quotedbl "
numbersign #
dollar $
percent %
ampersand &
quotesingle '
parenleft (
parenright )
asterisk *
plus +
comma ,
hyphen -
period .
slash /
zero 0
one 1
two 2
three 3
four 4
five 5
six 6
seven 7
eight 8
nine 9
colon :
semicolon ;
less <
equal =
greater >
question ?
bracketleft [
backslash \
bracketright ]
asciicircum ^
underscore _
quoteleft `
braceleft {
bar |
braceright }
asciitilde ~
tilde ~
universal "
existential $
suchthat '
asteriskmath *
congruent @
Alpha A
Beta B
Chi C
Delta D
Epsilon E
Phi F
Gamma G
Eta H
Iota I
theta1 J
Kappa K
Lambda L
Mu M
Nu N
Omicron O
Pi P
Theta Q
Rho R
Sigma S
Tau T
Upsilon U
sigma1 V
Omega W
Xi X
Psi Y
Zeta Z
therefore \
perpendicular ^
radicalex `
alpha a
beta b
chi c
delta d
epsilon e
phi f
gamma g
eta h
iota i
phi1 j
kappa k
lambda l
mu m
nu n
omicron o
pi p
theta q
rho r
sigma s
tau t
upsilon u
omega1 v
omega w
xi x
psi y
zeta z
similar ~
Upsilon1 !
minute "
lessequal #
fraction $
infinity %
florin &
club '
diamond (
heart )
spade *
arrowboth +
arrowleft ,
arrowup -
arrowright .
arrowdown /
degree 0
plusminus 1
second 2
greaterequal 3
multiply 4
proportional 5
partialdiff 6
bullet 7
divide 8
notequal 9
equivalence :
approxequal ;
ellipsis <
arrowvertex =
arrowhorizex >
carriagereturn ?
aleph @
Ifraktur A
Rfraktur B
weierstrass C
circlemultiply D
circleplus E
emptyset F
intersection G
union H
propersuperset I
reflexsuperset J
notsubset K
propersubset L
reflexsubset M
element N
notelement O
angle P
gradient Q
registerserif R
copyrightserif S
trademarkserif T
product U
radical V
dotmath W
logicalnot X
logicaland Y
logicalor Z
arrowdblboth [
arrowdblleft \
arrowdblup ]
arrowdblright ^
arrowdbldown _
lozenge `
angleleft a
registersans b
copyrightsans c
trademarksans d
summation e
parenlefttp f
parenleftex g
parenleftbt h
bracketlefttp i
bracketleftex j
bracketleftbt k
bracelefttp l
braceleftmid m
braceleftbt n
braceex o
angleright q
integral r
integraltp s
integralex t
integralbt u
parenrighttp v
parenrightex w
parenrightbt x
bracketrighttp y
bracketrightex z
bracketrightbt {
bracerighttp |
bracerightmid }
bracerightbt ~
}
  set cname(space) " "
  foreach pair [split $cnames "\n"] {
    if {[scan $pair %s%s name ch]==2} {
	set cname($name) $ch
    }
  }
  # Font file?
  set any 0
  catch {
    set gsf [open $cstate(gsfont) r]
    while {[gets $gsf line]>=0 && ![string match %END $line]} {}
    while {[gets $gsf line]>=0} {
	incr any [vreadfontline cstate cname $line]
    }
    close $gsf
  }
  if {$any} {
    set cstate(fontloaded) $cstate(gsfont)
  } else {
    set defaultfont {
/A [-8 9 (RFJ[ RFZ[ MTWT)] def
/B [-10 10 (KFK[ KFTFWGXHYJYLXNWOTP KPTPWQXRYTYWXYWZT[K[)] def
/C [-9 11 (ZKYIWGUFQFOGMILKKNKSLVMXOZQ[U[WZYXZV)] def
/D [-10 10 (KFK[ KFRFUGWIXKYNYSXVWXUZR[K[)] def
/E [-9 9 (LFL[ LFYF LPTP L[Y[)] def
/F [-9 8 (LFL[ LFYF LPTP)] def
/G [-9 11 (ZKYIWGUFQFOGMILKKNKSLVMXOZQ[U[WZYXZVZS USZS)] def
/H [-10 11 (KFK[ YFY[ KPYP)] def
/I [-3 4 (RFR[)] def
/J [-7 8 (VFVVUYTZR[P[NZMYLVLT)] def
/K [-10 10 (KFK[ YFKT POY[)] def
/L [-9 7 (LFL[ L[X[)] def
/M [-11 12 (JFJ[ JFR[ ZFR[ ZFZ[)] def
/N [-10 11 (KFK[ KFY[ YFY[)] def
/O [-10 11 (PFNGLIKKJNJSKVLXNZP[T[VZXXYVZSZNYKXIVGTFPF)] def
/P [-10 10 (KFK[ KFTFWGXHYJYMXOWPTQKQ)] def
/Q [-10 11 (PFNGLIKKJNJSKVLXNZP[T[VZXXYVZSZNYKXIVGTFPF SWY])] def
/R [-10 10 (KFK[ KFTFWGXHYJYLXNWOTPKP RPY[)] def
/S [-9 10 (YIWGTFPFMGKIKKLMMNOOUQWRXSYUYXWZT[P[MZKX)] def
/T [-8 8 (RFR[ KFYF)] def
/U [-11 11 (KFKULXNZQ[S[VZXXYUYF)] def
/V [-9 10 (JFR[ ZFR[)] def
/W [-13 12 (HFM[ RFM[ RFW[ \\FW[)] def
/X [-10 10 (KFY[ YFK[)] def
/Y [-9 9 (JFRPR[ ZFRP)] def
/Z [-10 10 (YFK[ KFYF K[Y[)] def
/a [-8 10 (XMX[ XPVNTMQMONMPLSLUMXOZQ[T[VZXX)] def
/b [-9 9 (LFL[ LPNNPMSMUNWPXSXUWXUZS[P[NZLX)] def
/c [-8 9 (XPVNTMQMONMPLSLUMXOZQ[T[VZXX)] def
/d [-8 10 (XFX[ XPVNTMQMONMPLSLUMXOZQ[T[VZXX)] def
/e [-8 9 (LSXSXQWOVNTMQMONMPLSLUMXOZQ[T[VZXX)] def
/f [-4 7 (WFUFSGRJR[ OMVM)] def
/g [-8 10 (XMX]W`VaTbQbOa XPVNTMQMONMPLSLUMXOZQ[T[VZXX)] def
/h [-8 10 (MFM[ MQPNRMUMWNXQX[)] def
/i [-3 4 (QFRGSFREQF RMR[)] def
/j [-4 5 (RFSGTFSERF SMS^RaPbNb)] def
/k [-8 8 (MFM[ WMMW QSX[)] def
/l [-3 4 (RFR[)] def
/m [-14 15 (GMG[ GQJNLMOMQNRQR[ RQUNWMZM\\N]Q][)] def
/n [-8 10 (MMM[ MQPNRMUMWNXQX[)] def
/o [-8 10 (QMONMPLSLUMXOZQ[T[VZXXYUYSXPVNTMQM)] def
/p [-9 9 (LMLb LPNNPMSMUNWPXSXUWXUZS[P[NZLX)] def
/q [-8 10 (XMXb XPVNTMQMONMPLSLUMXOZQ[T[VZXX)] def
/r [-6 7 (OMO[ OSPPRNTMWM)] def
/s [-7 9 (XPWNTMQMNNMPNRPSUTWUXWXXWZT[Q[NZMX)] def
/t [-5 7 (RFRWSZU[W[ OMVM)] def
/u [-8 10 (MMMWNZP[S[UZXW XMX[)] def
/v [-7 8 (LMR[ XMR[)] def
/w [-11 11 (JMN[ RMN[ RMV[ ZMV[)] def
/x [-7 9 (MMX[ XMM[)] def
/y [-7 8 (LMR[ XMR[P_NaLbKb)] def
/z [-7 9 (XMM[ MMXM M[X[)] def
/zero [-10 10 (QFNGLJKOKRLWNZQ[S[VZXWYRYOXJVGSFQF)] def
/one [-10 10 (NJPISFS[)] def
/two [-10 10 (LKLJMHNGPFTFVGWHXJXLWNUQK[Y[)] def
/three [-10 10 (MFXFRNUNWOXPYSYUXXVZS[P[MZLYKW)] def
/four [-10 10 (UFKTZT UFU[)] def
/five [-10 10 (WFMFLOMNPMSMVNXPYSYUXXVZS[P[MZLYKW)] def
/six [-10 10 (XIWGTFRFOGMJLOLTMXOZR[S[VZXXYUYTXQVOSNRNOOMQLT)] def
/seven [-10 10 (YFO[ KFYF)] def
/eight [-10 10 (PFMGLILKMMONSOVPXRYTYWXYWZT[P[MZLYKWKTLRNPQOUNWMXKXIWGTFPF)] def
/nine [-10 10 (XMWPURRSQSNRLPKMKLLINGQFRFUGWIXMXRWWUZR[P[MZLX)] def
/period [-5 5 (RYQZR[SZRY)] def
/comma [-5 5 (SZR[QZRYSZS\\R^Q_)] def
/colon [-5 5 (RMQNROSNRM RYQZR[SZRY)] def
/semicolon [-5 5 (RMQNROSNRM SZR[QZRYSZS\\R^Q_)] def
/exclam [-7 7 (RFRT RYQZR[SZRY)] def
/question [-9 9 (LKLJMHNGPFTFVGWHXJXLWNVORQRT RYQZR[SZRY)] def
/quotedbl [-8 8 (NFNM VFVM)] def
/ring [-7 7 (QFOGNINKOMQNSNUMVKVIUGSFQF)] def
/dollar [-10 10 (PBP_ TBT_ YIWGTFPFMGKIKKLMMNOOUQWRXSYUYXWZT[P[MZKX)] def
/fraction [-11 11 ([BIb)] def
/parenleft [-7 5 (VBTDRGPKOPOTPYR]T`Vb)] def
/parenright [-5 7 (NBPDRGTKUPUTTYR]P`Nb)] def
/bar [-4 4 (RBRb)] def
/hyphen [-13 13 (IR[R)] def
/plus [-13 13 (RIR[ IR[R)] def
/equal [-13 13 (IO[O IU[U)] def
/periodcentered [-5 5 (RQQRRSSRRQ)] def
/quoteleft [-5 5 (SFRGQIQKRLSKRJ)] def
/quoteright [-5 5 (RHQGRFSGSIRKQL)] def
/numbersign [-10 11 (SBLb YBRb LOZO KUYU)] def
/ampersand [-13 13 (\\O\\N[MZMYNXPVUTXRZP[L[JZIYHWHUISJRQNRMSKSIRGPFNGMIMKNNPQUXWZY[[[\\Z\\Y)] def
/bullet [-2 2 (QPPQPSQTSTTSTQSPQP RQQRRSSRRQ)] def
/slash [-7 7 (K^YF)] def
/backslash [-7 7 (KFY^)] def
/underscore [-8 8 (J]Z])] def
/tilde [-8 8 (LTLRMPOPUSWSXR LRMQOQUTWTXRXP)] def
/bracketleft [-7 7 (OBOb PBPb OBVB ObVb)] def
/bracketright [-7 7 (TBTb UBUb NBUB NbUb)] def
/braceleft [-7 7 (TBRCQDPFPHQJRKSMSOQQ RCQEQGRISJTLTNSPORSTTVTXSZR[Q]Q_Ra QSSUSWRYQZP\\P^Q`RaTb)] def
/braceright [-7 7 (PBRCSDTFTHSJRKQMQOSQ RCSESGRIQJPLPNQPURQTPVPXQZR[S]S_Ra SSQUQWRYSZT\\T^S`RaPb)] def
/asterisk [-8 8 (RFRR MIWO WIMO)] def
/less [-12 12 (ZIJRZ[)] def
/greater [-12 12 (JIZRJ[)] def
/asciitilde [-12 12 (IUISJPLONOPPTSVTXTZS[Q ISJQLPNPPQTTVUXUZT[Q[O)] def
/asciicircum [-11 11 (JTROZT JTRPZT)] def
/breve [-10 10 (KFLHNJQKSKVJXHYF KFLINKQLSLVKXIYF)] def
/percent [-12 12 ([FI[ NFPHPJOLMMKMIKIIJGLFNFPGSHVHYG[F WTUUTWTYV[X[ZZ[X[VYTWT)] def
/at [-13 14 (WNVLTKQKOLNMMPMSNUPVSVUUVS QKOMNPNSOUPV WKVSVUXVZV\\T]Q]O\\L[JYHWGTFQFNGLHJJILHOHRIUJWLYNZQ[T[WZYYZX XKWSWUXV)] def
/section [-8 8 (UITJUKVJVIUGSFQFOGNINKOMQOVR OMTPVRWTWVVXTZ PNNPMRMTNVPXU[ NVSYU[V]V_UaSbQbOaN_N^O]P^O_)] def
/dagger [-8 8 (RFQHRJSHRF RFRb RQQTRbSTRQ LMNNPMNLLM LMXM TMVNXMVLTM)] def
/daggerdbl [-8 8 (RFQHRJSHRF RFRT RPQRSVRXQVSRRP RTRb R^Q`RbS`R^ LMNNPMNLLM LMXM TMVNXMVLTM L[N\\P[NZL[ L[X[ T[V\\X[VZT[)] def
/space [-4 4 ()] def
/quotesingle [-4 5 (SFRGRM SGRM SFTGRM)] def
}
    foreach line [split $defaultfont "\n"] {
	vreadfontline cstate cname $line
    }
    set cstate(fontloaded) default
  }
}


if {"$argv" != "" && [string match *vectext.tcl $argv0]} {puts [eval vectext $argv]}

######## file browser.
proc file_browser {func {newfile 0} {pat *} {default "DEFAULT"} {title ""}} {
  global file_browser
  set file_browser(func) $func
  set file_browser(pattern) $pat
  set file_browser(newfile) $newfile
  set fb .filebrowser
  set file_browser(fb) $fb
  if {$default == "DEFAULT" && [info exists file_browser(dir)]} {
    set default $file_browser(dir)
  }
  if {$default == "DEFAULT" || $default == "."} {
    set default [pwd]
  }

  trace vdelete file_browser(dir) w {file_browser_refresh}
  if {[info commands $fb] != ""} {
    destroy $fb
  }
  toplevel $fb
  if {$title != ""} {
    wm title $fb $title
  }

  entry $fb.ent -textvariable file_browser(ent)
  set file_browser(ent) [file tail $default]
  bind $fb.ent <Return> { file_browser_select %W }

  set file_browser(dir) [file dirname $default]

  set file_browser(dmenu) \
    [eval [concat tk_optionMenu $fb.mb file_browser(dir) $file_browser(dir)]]

  frame $fb.list
  listbox $fb.list.lb -selectmode browse -yscrollcommand "$fb.list.sb set"
  scrollbar $fb.list.sb -orient vertical -command "$fb.list.lb yview"
  bind $fb.list.lb <Button-1> {
	%W activate [%W nearest %y]
	set file_browser(ent) $file_browser([%W index active])
  }
  bind $fb.list.lb <Return> {
	set file_browser(ent) $file_browser([%W index active])
	file_browser_select %W
  }
  bind $fb.list.lb <Double-Button-1> { file_browser_select %W }
  pack $fb.list.lb -side left -fill both -expand 1
  pack $fb.list.sb -side right -fill y

  pack $fb.mb $fb.list $fb.ent -side top -fill x
  file_browser_refresh
  trace variable file_browser(dir) w {file_browser_refresh}
  focus $fb.ent
}

proc file_browser_refresh {args} {
  global file_browser
  set fb $file_browser(fb)
  $fb.list.lb delete 0 end

  if {![string match {[~/]*} $file_browser(dir)]} {
    set file_browser(dir) [filejoin [pwd] $file_browser(dir)]
  }

  set dfs [files_in $file_browser(dir) $file_browser(pattern)]
  set i 0
  foreach file [lindex $dfs 0] {
    set file_browser($i) $file; incr i
    $fb.list.lb insert end "\[$file\]"
  }
  foreach file [lindex $dfs 1] {
    set file_browser($i) $file; incr i
    $fb.list.lb insert end $file
  }

  set path $file_browser(dir)
  set paths {}
  $file_browser(dmenu) delete 0 end
  if {[file isdir $path]} {
    $file_browser(dmenu) insert 0 command -label $path \
	-command [list set file_browser(dir) $path]
  }
  while {[set dir [file dirname $path]] != $path} {
    $file_browser(dmenu) insert 0 command -label $dir \
	-command [list set file_browser(dir) $dir]
    set path $dir
  }
}

proc file_browser_setval {str} {
  global file_browser
  set fb $file_browser(fb)
  set file_browser(ent) $str
  set v [$fb.ent xview]
  if {[lindex $v 1]<1} {
    $fb.ent xview moveto [expr [lindex $v 1]-[lindex $v 0]+.05]
  }
}


proc file_browser_select {w} {
  global file_browser
  set fb $file_browser(fb)
  set sel $file_browser(ent)
  if {$sel == ""} {
    # Cancel.
    trace vdelete file_browser(dir) w {file_browser_refresh}
    wm withdraw $fb
    return
  }
  if {[file tail $file_browser(ent)] == $file_browser(ent)} {
    set sel [filejoin $file_browser(dir) $sel]
    file_browser_setval $sel
  }

  if {[file isdir $sel]} {
    set file_browser(dir) $sel
  } else {
    set already [file exists $sel]
    if {$file_browser(newfile)<0 && $already} {
	if {[tk_dialog ${fb}dg {Overwrite?} "Overwrite [file tail $sel]?" \
		{questhead} 0 OK Cancel]} {
	  raise $fb
	  return
	}
    } elseif {$file_browser(newfile)==0 && !$already} {
	tk_dialog ${fb}dg {Nope} "[file tail $sel] doesn't exist." {error} 0 OK
	raise $fb
	return
    }
    $fb conf -cursor watch
    if {[catch {eval [concat $file_browser(func) [list $sel]]} whynot] == 0} {
	trace vdelete file_browser(dir) w {file_browser_refresh}
	wm withdraw $fb
    } else {
	msg $whynot
    }
  }
}

proc filejoin {args} {
  if {[catch {eval [concat file join $args]} result] == 0} {
    set fsp {}
    foreach f [file split $result] {
	if {$f != "." && $f != ""} {lappend fsp $f}
    }
    eval [concat file join $fsp]
  } else {
    set result [string trimright [join $args /] /]
    while {[regsub -all {(/\.?)($|/)} $result {\2} result]} {}
    set result
  }
}
    
proc files_in {dir {pattern *}} {
  set flist [glob -nocomplain [filejoin $dir {{.*,*}}]]
  set dirs {}; set files {}
  foreach f $flist {
    set tail [file tail $f]
    if {[file isdir $f]} {
	if {$tail != "."} {lappend dirs $tail}
    } elseif {[string match $pattern $tail]} {
	lappend files $tail
    }
  }
  list [lsort $dirs] [lsort $files]
}


;;
;; Does plots of HYADES output.
;;

;; Put interesting variables in common block to avoid hairy parameter
;; passing.
;; Changed to use new procedure for plotting "r vs t" graphs. (See
;; snaps.pro.)
;;             -- Dave Chin, 16 June 1999
    
;; Converted from a pro file to a main program.  This retains all
;; variables in the MAIN context/scope, i.e. variables are accessible
;; from the IDL command line after the program ends.
;;             -- Dave Chin 28 May 1999

;; begun 12/26/98 by RPD  edited 1/7/98
;;
;; This procedure is intended to be run to the stop then quit.  
;; Its job is to define variables in main memory 
;; for interactive use after running read_hyades. 
;;
;; $Id: hyades_shell.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
;;

common hyad_data, runname, ndumps, time, rz, u, rho, pres, qtot,  $
  te, tion, tr, ucm, lasi, rcm, zbar, default_device


;; limits -- (structure) sets plot limits
;; logplot -- (logical) determines if plots are made with log scale
;; ti -- array of time-indices (integers)
;; limits_changed -- (logical) determines if plot ranges have been changed
common hyad_lims, limits, logplot, ti, limits_changed

;@hyadmenu
;@read_hyades
;@color_vs_zone
;@color_vs_rcm
;@snaps
;@rt_display

print, ''
print, 'Hyades Shell v.2'
print, ''

;; Each variable will be an array of time, zone after read_hyades runs

runname = ''
ndumps = 0L
time   = 0.
rz     = 0.
u      = 0.
rho    = 0.
pres   = 0.
qtot   = 0.
te     = 0.
tion   = 0.
tr     = 0.
ucm    = 0.
lasi   = 0.
rcm    = 0.
zbar   = 0.
default_device = !d.name

;  Extra possible variables follow

;;,dene,qelc,eelc,eicpl,$
;;	qion,csi,ldep 

print, ''
getrunname: read, runname, prompt='Enter run name: '
if (runname eq '') then begin
    goto, getrunname
endif else begin
    filename = runname+'.otf'
    
    openr, lun, filename, /get_lun, error=err
    if (err ne 0) then begin
        printf, -2, !err_string ; write to stderr
        goto, getrunname
    endif
    
    print, 'Reading data from: ', filename
    
    read, ndumps,  $
      prompt='Enter ndumps (integer), or enter 0 to infer ' + $
      'ndumps from OTF file: '
    ndumps = fix(ndumps)
    
    read_hyades, lun
    initlims
endelse


done = 0
while (not done) do begin
    hyadmenu, done
endwhile

print, ''
print, 'Here are the common block variables currently defined for run: '+ $
  runname
help, rz, u, pres, qtot, te, tion, tr, ucm, lasi, rcm, zbar
print, ''
print, "'Bye!  It's all yours!"
print, ''


end

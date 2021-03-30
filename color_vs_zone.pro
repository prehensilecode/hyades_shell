pro color_vs_zone
;;
;; This program displays an image of the following variables:
;;     te, tion, rho, u, pres
;;
;; These variables need to be manually in the code changed if other 
;; variables desired. The variables are plotted vs. zone number on
;; the y-axis.
;;
;;;;;;;;;;;;
;;
;; Removed awkward scaling code.  We now open a fixed size window
;; (win_xsize by win_ysize).
;;                   -- dwchin 
;;
;; In plotting u, changed from alog10(alog10(abs(u))) to
;; alog10(alog10(abs(u)>10)).
;;                   -- RPD 27 May 1999
;;
;; reworked from color_display by RPD on 12/26/98
;;
;; By - Harry Reisig
;; July 10, 1998
;; Improved to ver2 July 29, 1998
;;
;; $Id: color_vs_zone.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
;;
    common hyad_data

    loadct, 4                   ; loads the color scale
    plotvars = [te, tion, rho, u, pres] ; sets up the variables to be plotted
    nvars    = 5                ; number of variables in plotvars
    aa       = size(te)         ; the size of any of the arrays (all the
                                ; same size)
    ;; in the following constants, assume a screen size of 1000x800
    win_xsize = 920             ; xsize of plot window, in pixels
    win_ysize = 160             ; ysize of plot window, in pixels
    y_offset  =  20             ; offset the plot upwards to make
                                ;   space for labels

    ;; Open a new window
    window, xsize=win_xsize, ysize=win_ysize,  $
      title=runname+': vars. vs. time and zone', /free
    
    tmparray = fltarr(aa(1), aa(2))
    
    ;; Plot one array at a time;
    ;; each time it plots the array and the name of the array.
    ;; Note: alog10 is the LOG base 10, not, as might be natural to
    ;;       assume, the anti-log.
    for i=0,nvars-1 do begin
        if (i eq 0) then begin      
            tmparray = alog10(abs(te))
            string   = 'te'
        endif
        
        if (i eq 1) then begin
            tmparray = alog10(abs(tion))
            string   = 'tion'
        endif
        
        if (i eq 2) then begin
            tmparray = alog10(rho)
            string   = 'rho'
        endif
        
        if (i eq 3) then begin
            ;;tmparray = alog10(alog10(abs(u)))
            tmparray = alog10(abs(u)>10.)
            string   = 'u'
        endif
        
        if (i eq 4) then begin
            ;;tmparray = alog10(alog10(abs(pres)))
            tmparray = alog10(abs(pres)) ; negative pressures are possible
            string   = 'pres'
        endif
        
        
        ;; label graphs
        xyouts, i*win_xsize/nvars, 0, string, /device, charsize=2, color=255
        
        ;; resize graphs using linear interpolation (congrid), and
        ;; plot;  use tv and bytscl rather than tvscl since tvscl
        ;; scales to current depth of display, rather than a fixed
        ;; range as can be specified by bytscl
        tv, bytscl(congrid(tmparray, win_xsize/nvars, win_ysize-y_offset),  $
                   top=200), $
          i*win_xsize/nvars, y_offset ; no interpolation
        
    endfor

    return
end



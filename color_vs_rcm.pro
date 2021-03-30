pro color_vs_rcm
;;
;; This program displays a tvscl image of the following variables:
;;     te, tion, rho, ucm, pres
;;
;; Modified from color_vs_zone
;;
;;;;;;;;;;;;
;;
;; $Id: color_vs_rcm.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
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
      title=runname+': vars. vs. time and rcm', /free
    
    ;; Plot one array at a time;
    ;; each time it plots the array and the name of the array.
    ;; Note: alog10 is the LOG base 10, not, as might be natural to
    ;;       assume, the anti-log.
    tmparray  = fltarr(aa(1), aa(2))
    aminrcm   = abs(min(rcm))
    rcmscale = (aa(2)-1)/(max(rcm) - min(rcm))
    
    for i=0,nvars-1 do begin
        for j=0,ndumps-1 do begin
            for k=0,aa(2)-1 do begin
                if (i eq 0) then begin      
                    tmparray(j,k) =  $
                      alog10(abs(te(j,fix((rcm(j,k) + aminrcm)*rcmscale))))
                    string   = 'te'
                endif
                
                if (i eq 1) then begin
                    tmparray(j,k) =  $
                      alog10(abs(tion(j,fix((rcm(j,k) + aminrcm)*rcmscale))))
                    string   = 'tion'
                endif
                
                if (i eq 2) then begin
                    tmparray(j,k) =  $
                      alog10(rho(j,fix((rcm(j,k) + aminrcm)*rcmscale)))
                    string   = 'rho'
                endif
                
                if (i eq 3) then begin
                    ;;tmparray(j,k) = alog10(alog10(abs(u)))
                    tmparray(j,k) =  $
                      alog10(abs(ucm(j,fix((rcm(j,k) + aminrcm)* $
                                           rcmscale)))>10.)
                    string   = 'ucm'
                endif
                
                if (i eq 4) then begin
                    ;;tmparray(j,k) = alog10(alog10(abs(pres)))
                    tmparray(j,k) = alog10(abs(pres(j,fix((rcm(j,k) +  $
                                                      aminrcm)*rcmscale))))
                    string   = 'pres'
                endif
                

            endfor ;; k=0,z(2)-1
        endfor ;; j=0,z(1)-1
        
        ;; label graphs
        xyouts, i*win_xsize/nvars, 0, string, /device, charsize=2, color=255
        
        ;; resize graphs using linear interpolation (congrid), and plot
        tv, bytscl(congrid(tmparray, win_xsize/nvars, win_ysize-y_offset), $
                   top=255), $
          i*win_xsize/nvars, y_offset ; no interpolation
        ;;tvscl, congrid(tmparray, win_xsize/nvars, win_ysize-y_offset, $
        ;;/interp), i*win_xsize/nvars, y_offset

    endfor
    
    return
end

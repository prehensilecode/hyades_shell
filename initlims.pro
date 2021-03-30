pro initlims
    ;;
    ;; Initialize limits struct, and logplot struct.
    ;; Define ti.
    ;;
    ;;                    -- David Chin, 6 Aug 1999
    ;;
    ;; $Id: initlims.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data
    common hyad_lims
    
    limits  = {hyad_plot_lims,   $
               rcm:  fltarr(2), $
               rho:  fltarr(2), $
               ucm:  fltarr(2), $
               pres: fltarr(2), $
               te:   fltarr(2), $
               tion: fltarr(2), $
               tr:   fltarr(2)}
    
    logplot = {hyad_log_plot, $
               rho:  0, $
               ucm:  0, $
               pres: 0, $
               te:   0, $
               tion: 0, $
               tr:   0}
    
    ti = intarr(5)
    
    limits_changed = 0
    
    ;;
    ;; Default values
    ;;
    
    for i=1,5 do begin
        ti(i-1) = fix(i*ndumps/5 - 1)
    end
    
    limits.rcm  = [min(rcm(ti,*)),  max(rcm(ti,*))]
    limits.rho  = [min(rho(ti,*)),  max(rho(ti,*))]
    limits.ucm  = [min(ucm(ti,*)),  max(ucm(ti,*))]
    limits.pres = [min(pres(ti,*)), max(pres(ti,*))]
    limits.te   = [min(te(ti,*)),   max(te(ti,*))]
    limits.tion = [min(tion(ti,*)), max(tion(ti,*))]
    limits.tr   = [min(tr(ti,*)),   max(tr(ti,*))]
    
    ;; Logical flags to set logarithmic axis
    logplot.rho  = 1
    logplot.ucm  = 0
    logplot.pres = 1
    logplot.te   = 1
    logplot.tion = 1
    logplot.tr   = 1
    
end

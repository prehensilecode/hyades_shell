pro setlog, var_name
    ;; 
    ;; Sets flag for log plot (y-axis only)
    ;;
    ;; Inputs:
    ;;          var_name -- string; name of variable to set plot range
    ;;
    ;; Outputs:
    ;;          (none)
    ;;
    ;; Side effects:
    ;;          sets appropriate values for structure logplot in the
    ;;          common block hyad_lims 
    ;;          
    ;;                                -- David Chin, 15 Jun 1999
    ;;
    ;; $Id: setlog.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data            ; defined in hyades_shell.pro
    common hyad_lims            ; defined in snaps.pro
    
    islog = 0
    
    case var_name of
        'rho':  if logplot.rho then islog = 1
        
        'ucm':  if logplot.ucm then islog = 1
            
        'pres': if logplot.pres then islog = 1
            
        'te':   if logplot.te then islog = 1
            
        'tion': if logplot.tion then islog = 1
            
        'tr':   if logplot.tr then islog = 1
            
        else:   print, 'setlog: HUH?'
    endcase
    
    tmp = ''
    prompt: if islog then begin
        read, tmp, prompt='    Change scale to linear? (y/n) '
    endif else begin
        read, tmp, prompt='    Change scale to logarithmic? (y/n) '
    endelse
    
    ;; have to do mod 2 because toggle keywords have 0 and 1 only as
    ;; their legal values, and "NOT 1" gives "-2"
    if tmp eq 'y' or tmp eq 'Y' then begin
        case var_name of
            'rho':  logplot.rho  = (not logplot.rho) mod 2
            
            'ucm':  logplot.ucm  = (not logplot.ucm) mod 2
            
            'pres': logplot.pres = (not logplot.pres) mod 2
            
            'te':   logplot.te   = (not logplot.te) mod 2
            
            'tion': logplot.tion = (not logplot.tion) mod 2
            
            'tr':   logplot.tr   = (not logplot.tr) mod 2
            
            else:   goto, prompt
        endcase
    endif
    
    return
end

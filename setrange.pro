pro setrange, var_name
    ;; 
    ;; Sets ranges of graphs to be plotted.
    ;;
    ;; Inputs:
    ;;          var_name -- string; name of variable to set plot range
    ;;
    ;; Outputs:
    ;;          (none)
    ;;
    ;; Side effects:
    ;;          sets appropriate values for structure limits in the
    ;;          common block hyad_lims
    ;;          
    ;;                                -- David Chin, 14 Jun 1999
    ;;
    ;; $Id: setrange.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data
    common hyad_lims
    
    ;; temporary variables
    tmp  = 0.
    tmp2 = 0L
    tmp3 = 0L
    
    case var_name of
        'time': begin
            print, '    Available range of time indices: 1    to ' +  $
              string(ndumps)
            print, '       (Latest time is: ' + string(time(ndumps-1)) +  $
              ' sec.)'
            
            prompt1: read, tmp2, prompt='    Earliest time index? '
            if (tmp2 lt 0) then begin
                print, '    ERROR: time index too small'
                goto, prompt1
            endif
            
            prompt2: read, tmp3, prompt='    Latest time index? '
            if (tmp3 gt ndumps) then begin
                print, '    ERROR: time index too large'
                goto, prompt2
            endif
            
            ;; assign time-indices, evenly spaced
            ti(0) = tmp2
            ti(4) = tmp3
            for i=1,3 do begin
                ti(i) = tmp2 + fix(i*(tmp3 - tmp2)/4)
            endfor
        end
        
        'rcm': begin
            print, '    Available range of rcm: ', min(rcm(ti,*)),  $
              ' to ', max(rcm(ti,*))
            read, tmp, prompt='    Min. value of rcm? '
            limits.rcm(0) = tmp
            read, tmp, prompt='    Max. value of rcm? '
            limits.rcm(1) = tmp
        end
        
        'rho': begin
            print, '    Available range of rho: ', min(rho(ti,*)),  $
              ' to ', max(rho(ti,*))
            read, tmp, prompt='    Min. value of rho? '
            limits.rho(0) = tmp
            read, tmp, prompt='    Max. value of rho? '
            limits.rho(1) = tmp
        end
        
        'ucm': begin
            print, '    Available range of ucm: ', min(ucm(ti,*)),  $
              ' to ', max(ucm(ti,*))
            read, tmp, prompt='    Min. value of ucm? '
            limits.ucm(0) = tmp
            read, tmp, prompt='    Max. value of ucm? '
            limits.ucm(1) = tmp
        end
        
        'pres': begin
            print, '    Available range of pres: ', min(pres(ti,*)),  $
              ' to ', max(pres(ti,*))
            read, tmp, prompt='    Min. value of pres? '
            limits.pres(0) = tmp
            read, tmp, prompt='    Max. value of pres? '
            limits.pres(1) = tmp
        end
        
        'te': begin
            print, '    Available range of te: ', min(te(ti,*)),  $
              ' to ', max(te(ti,*))
            read, tmp, prompt='    Min. value of te? '
            limits.te(0) = tmp
            read, tmp, prompt='    Max. value of te? '
            limits.te(1) = tmp
        end
        
        'tion': begin
            print, '    Available range of tion: ', min(tion(ti,*)),  $
              ' to ', max(tion(ti,*))
            read, tmp, prompt='    Min. value of tion? '
            limits.tion(0) = tmp
            read, tmp, prompt='    Max. value of tion? '
            limits.tion(1) = tmp
        end
        
        'tr': begin
            print, '    Available range of tr: ', min(tr(ti,*)),  $
              ' to ', max(tr(ti,*))
            read, tmp, prompt='    Min. value of tr? '
            limits.tr(0) = tmp
            read, tmp, prompt='    Max. value of tr? '
            limits.tr(1) = tmp
        end
        
        else: print, 'HUH?'
    endcase
    
    return
end

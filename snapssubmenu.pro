pro snapssubmenu, done, var=var_name
    ;;
    ;; Menu for selecting operation on plot: change range, or toggle
    ;; log/linear scale.
    ;;
    ;; Inputs:
    ;;          var_name -- string; name of variable -> identifies
    ;;                      plot
    ;;
    ;; Outputs:
    ;;          (none)
    ;;
    ;; Side effects:
    ;;          prompts for operation to be performed.
    ;;      
    ;;
    ;;                               -- David Chin, 15 Jun 1999
    ;;
    ;; $Id: snapssubmenu.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_lims            ; see snaps.pro for definition
    
    print, 'Select operation:'
    print, '    (1) Change range'
    print, '    (2) Change scale (log or linear)'
    print, '    (Q) Go back'
    print, ''
    
    answer = ''
    prompt: read, answer, prompt='Select an operation to perform (1-2,Q): '
    print, ''
    
    case answer  of
        '1': begin
            limits_changed = 1  ; set to TRUE
            setrange, var_name
            
            snapsplot, ti, device=default_device, range=limits 
        end
        
        '2': begin
            setlog, var_name
            
            if limits_changed then begin
                snapsplot, ti, device=default_device, range=limits 
            endif else begin
                snapsplot, ti, device=default_device
            endelse
        end
        
        'Q': begin
            done = 1
            return
        end
        
        'q': begin
            done = 1
            return
        end
        else: goto, prompt
    endcase
    
    return
    
end

@setrange
@setlog

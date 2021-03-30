pro hyadmenu, done
    ;;
    ;; Main hyades_shell menu.  Allows one to pick datafile and which
    ;; graphs to plot.
    ;;
    ;; Inputs:
    ;;         done -- pass by reference; see Outputs
    ;;
    ;; Outputs:
    ;;         done -- logical flag; Has user selected "Quit"?
    ;;         
    ;; Side effects:
    ;;         prompts for operation to be performed
    ;;         sets done flag: see Outputs
    ;;
    ;;                                -- David Chin, 16 Jun 1999
    ;;
    ;; $Id: hyadmenu.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data
    
    print, ''
    print, 'HYADES SHELL MAIN MENU'
    print, ''
    print, '    (1) Select data set (runname)'
    print, '        Current runname: ', + runname
    print, ''
    print, '  Select plot to make:'
    print, ''
    print, '    (2) Color vs. zone and time'
    print, '    (3) Color vs. rcm and time'
    print, '    (4) Time snapshots of variables vs. rcm'
    ;;print, '    (5) rt display'
    print, '    (5) Animations'
    print, ''
    print, '    (Q) QUIT'
    
    answer = ''
    print, ''
    prompt: read, answer,  $
      prompt='Select an operation to perform or plot to make (1-4, Q): '
    print, ''
    
    case answer of
        '1': begin
            print, 'Current runname is: ' + runname
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
            endelse
            
            print, 'Reading data from: ', filename
            
            read, ndumps,  $
              prompt='Enter ndumps (integer), or 0 to infer ndumps ' + $
              'from OTF file: '
            ndumps = fix(ndumps)
            
            read_hyades, lun
            initlims
        end
        
        '2': begin
            color_vs_zone
        end
        
        '3': begin
            color_vs_rcm
        end
        
        '4': begin
            snaps
        end
        
;        '5': begin
;            rt_display, rcm, time, ucm, rho, pres, te, tion, tr, Aout
;        end
        
        '5': begin
            animdone = 0
            while not animdone do animmenu, animdone
        end
        
        'q': done = 1
        
        'Q': done = 1
        
        else: goto, prompt
    endcase
    
    return
end

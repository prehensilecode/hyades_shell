pro snapsmenu, done
    ;;
    ;; Menu for changing time snapshot plots.
    ;;
    ;; Inputs:
    ;;           done -- pass by reference; see Outputs
    ;;
    ;; Outputs:
    ;;           done -- logical flag; Has user selected "Quit"?
    ;;
    ;; Side effects:
    ;;           prompts for operation to be performed
    ;;           sets done flag:  see Outputs
    ;;
    ;;                                -- David Chin, 14 Jun 1999
    ;;
    ;; $Id: snapsmenu.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_lims            ; see snaps.pro for definition
    
    subdone = 0                 ; is submenu done?
    
    print, ''
    print, 'SNAPSHOT PLOTS MENU'
    print, ''
    print, '    (1) Set time-index range'
    print, '    (2) Set rcm range'
    print, ''
    print, '  Change plot of:'
    print, ''
    print, '    (3) rho'
    print, '    (4) ucm'
    print, '    (5) pres'
    print, '    (6) te'
    print, '    (7) tion'
    print, '    (8) tr'
    print, ''
    print, '    (C) Change color map'
    print, '    (P) Make PostScript file'
    print, '    (Q) QUIT'
    
    answer = ''
    print, ''
    prompt: read, answer,  $
      prompt='Select an operation to perform or plot to change (1-8,C,P,Q): '
    print, ''
    
    case answer of
        '1': begin
            print, 'Current set of time indices = ', ti
            setrange, 'time'
            
            if limits_changed then begin
                snapsplot, ti, device=default_device, range=limits
            endif else begin
                snapsplot, ti, device=default_device
            endelse
        end
        
        '2': begin
            ;; change range of RCM
            print, 'Current range of rcm: ', limits.rcm(0), ' to ',  $
              limits.rcm(1)
            setrange, 'rcm'
            limits_changed = 1
            snapsplot, ti, device=default_device, range=limits
        end
        
        '3': begin
            ;; change range of RHO
            print, 'Current range of rho: ', limits.rho(0), ' to ', $
              limits.rho(1)
            
            if logplot.rho then begin
                print, 'Rho plot is logarithmic'
            endif else begin
                print, 'Rho plot is linear'
            endelse
            print, ''
            
            subdone = 0
            while (not subdone) do begin
                snapssubmenu, subdone, var='rho'
            endwhile
        end
        
        '4': begin
            ;; change range of UCM
            print, 'Current range of ucm: ', limits.ucm(0), ' to ', $
              limits.ucm(1)
            
            if logplot.ucm then begin
                print, 'Ucm plot is logarithmic'
            endif else begin
                print, 'Ucm plot is linear'
            endelse
            print, ''
            
            subdone = 0
            while (not subdone) do begin
                snapssubmenu, subdone, var='ucm'
            endwhile
        end
        
        '5': begin
            ;; change range of PRES
            print, 'Current range of pres: ', limits.pres(0), ' to ', $
              limits.pres(1)
            
            if logplot.pres then begin
                print, 'Pres plot is logarithmic'
            endif else begin
                print, 'Pres plot is linear'
            endelse
            print, ''
            
            subdone = 0
            while (not subdone) do begin
                snapssubmenu, subdone, var='pres'
            endwhile
        end
        
        '6': begin
            ;; change range of TE
            print, 'Current range of te: ', limits.te(0), ' to ', $
              limits.te(1)
            
            if logplot.te then begin
                print, 'Te plot is logarithmic'
            endif else begin
                print, 'Te plot is linear'
            endelse
            print, ''
            
            subdone = 0
            while (not subdone) do begin
                snapssubmenu, subdone, var='te'
            endwhile
        end
        
        '7': begin
            ;; change range of TION
            print, 'Current range of tion: ', limits.tion(0), ' to ', $
              limits.tion(1)
            
            if logplot.tion then begin
                print, 'Tion plot is logarithmic'
            endif else begin
                print, 'Tion plot is linear'
            endelse
            print, ''
            
            subdone = 0
            while (not subdone) do begin
                snapssubmenu, subdone, var='tion'
            endwhile
        end
        
        '8': begin
            ;; change range of TR
            print, 'Current range of tr: ', limits.tr(0), ' to ', $
              limits.tr(1)
            
            if logplot.tr then begin
                print, 'Tr plot is logarithmic'
            endif else begin
                print, 'Tr plot is linear'
            endelse
            print, ''
            
            subdone = 0
            while (not subdone) do begin
                snapssubmenu, subdone, var='tr'
            endwhile
        end
        
        'c': begin
            ;; change color map
            cmap = 0L
            ;;print, 'Good color map for PostScript is 6'
            read, cmap, prompt='Enter color map number (0 - 37): '
            loadct, cmap
        end
        
        'C': begin
            ;; change color map
            cmap = 0L
            ;;print, 'Good color map for PostScript is 6'
            read, cmap, prompt='Enter color map number (0 - 37): '
            if ((cmap ge 0) and (cmap le 37)) then loadct, cmap
        end
        
        'p': begin
            if limits_changed then begin
                snapsplot, ti, range=limits, device='ps'
            endif else begin
                snapsplot, ti, device='ps'
            endelse
        end
        
        'P': begin
            if limits_changed then begin
                snapsplot, ti, range=limits, device='ps'
            endif else begin
                snapsplot, ti, device='ps'
            endelse
        end
        
        'Q': begin
            done = 1
        end
        
        'q': begin
            done = 1
        end
        
        else: goto, prompt
    endcase
    
    return
    
end

@snapssubmenu

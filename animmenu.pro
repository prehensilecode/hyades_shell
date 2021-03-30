pro animmenu, done
    
    ;;
    ;; Menu for changing animation.
    ;;
    ;; Inputs:
    ;;         done -- pass by reference; see Outputs
    ;;
    ;; Outputs:
    ;;         done -- logical flag; Has user selected "Quit"?
    ;;
    ;; Side effects:
    ;;         
    ;;
    ;;                           -- David Chin, 4 Aug 1999
    ;;
    ;; $Id: animmenu.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;; 
    
    common hyad_data
    common hyad_lims
    
    print, ''
    print, 'ANIMATION MENU'
    print, ''
    print, '  Change range of:'
    print, ''
    print, '    (1) rcm'
    print, ''
    print, '    (2) rho'
    print, '    (3) ucm'
    print, '    (4) te'
    print, '    (5) tion'
    print, '    (6) tr'
    print, ''
    print, ' Make Animation of:'
    print, ''
    print, '    (p) rho'
    print, '    (u) ucm'
    print, '    (e) te'
    print, '    (i) tion'
    print, '    (r) tr'
    print, ''
    print, '    (Q) QUIT'
    
    answer = ''
    print, ''
    prompt: read, answer, $
      prompt='Pick one (1-6, p, u, e, i, r, Q): '
    print, ''
    
    case answer of 
        '1': begin
            ;; change range of RCM
            print, 'Current range of rcm: ', limits.rcm(0), ' to ',  $
              limits.rcm(1)
            setrange, 'rcm'
            limits_changed = 1
        end
        
        '2': begin
            setrange, 'rho'
        end
        
        '3': begin
            setrange, 'ucm'
        end
        
        '4': begin
            setrange, 'te'
        end
        
        '5': begin
            setrange, 'tion'
        end
        
        '6': begin
            setrange, 'tr'
        end
        
        'p': begin
            done = 1
            hyadanim, 'rho'
        end
        
        'u': begin
            done = 1
            hyadanim, 'ucm'
        end
        
        'e': begin
            done = 1
            hyadanim, 'te'
        end
        
        'i': begin
            done = 1
            hyadanim, 'tion', /plotrho
        end
        
        'r': begin
            done = 1
            hyadanim, 'tr'
        end
        
        'q': begin
            done = 1
            print, 'DONE'
        end
        
        'Q': begin
            done = 1
            print, 'DONE'
        end
        
        else: goto, prompt
    endcase
    
    return
end

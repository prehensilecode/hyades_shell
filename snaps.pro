pro snaps
    ;;
    ;; Plots rho, ucm, pres, te, tion, tr vs. rcm at different times.
    ;;
    ;; Inputs:
    ;;          (none)
    ;;
    ;; Outputs:
    ;;          window containing plots
    ;;
    ;; Side effects:
    ;;          defines and sets defauls for limits in common block
    ;;          hyad_lims
    ;;
    ;;                                -- David Chin, 14 Jun 1999
    ;;
    ;; $Id: snaps.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data
    
    common hyad_lims
    
    ;;initlims
    
    snapsplot, ti
    
    done = 0
    
    while (not done) do begin
        snapsmenu, done
    end
    
end

@snapsmenu
@snapsplot

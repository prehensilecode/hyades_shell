pro snapsplot, time_i, range=range, device=device, colortable=colortable

    ;;
    ;; Plot pres, te, rho, ucm vs. rcm.
    ;; Plots are arranged in 3 rows by 2 columns:
    ;;     rho       ucm
    ;;     pres      te
    ;;     tion      tr
    ;;
    ;; Inputs:
    ;;         time_i -- int. array; array of time-indexes to be
    ;;                   plotted 
    ;;         limits -- structure containing plot limits.  See
    ;;                   snaps.pro for definition
    ;;         device -- string; name of device to be used for
    ;;                   plotting
    ;; 
    ;; Outputs:
    ;;         window containing plots
    ;;
    ;; Side effects:
    ;;         (none)
    ;;
    ;; --David Chin, 2 Jun 1999
    ;;
    ;; $Id: snapsplot.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data
    common hyad_lims

    n_steps  = (size(time_i))(1) - 1
    color_0  = 25
    col_step = fix(0.8*255/n_steps)
    
    ;; sizing and positioning variables
    winsize    = [700., 810.]
    subwinsize = [700., 770.]   ; leave space at top for text
    margin     = [0.07, 0.04]
    offset     = [0.03, 0.]
    position   = replicate({placement, low_l: fltarr(2), top_r: fltarr(2)}, 6)
    
    WINID = 2

    if keyword_set(device) then begin
        case device of
            'x': begin
                set_plot, 'x'
                window, WINID, xsize=winsize(0), ysize=winsize(1),  $
                  title=runname
                !p.color = color_0
            end
            
            'mac': begin
                ;; The Mac version of IDL does not behave like it ought to,
                ;; according to the manual.  In particular, "set_plot, 'mac'"
                ;; breaks, and so does setting "retain=0" in the call
                ;; to window
                ;;set_plot, 'mac'
                device, decomposed=0
                if keyword_set(colortable) then begin
                    loadct, colortable
                endif
                window, WINID, xsize=winsize(0), ysize=winsize(1),  $
                  title=runname
                !p.color = color_0
            end
            
            'ps': begin
                set_plot, 'ps'
                ;; offsets are in cm, from the lower left of portrait
                ;; page
                printname = ''
                
                while printname eq '' do begin
                    read, printname, prompt='Enter filename to save as: '
                endwhile
                
                !p.font = -1
                !p.thick = 2.0
                !p.charthick = 2.0
                device, file=printname, /color, bits=8, /portrait, $
                  font_size=10.0, $
                  xoffset=0., yoffset=-0.5, $
                  xsize=19.05, ysize=25.40, $
                  /encapsulated
                if keyword_set(colortable) then begin
                    loadct, colortable
                endif else begin
                    loadct, 6
                endelse

                offset = offset + [0.02,0.]
                print, ''
                print, 'Plot saved to file ' + printname
            end
            
            else: begin
                print, 'SNAPSPLOT: unrecognized device'
                return
            end
        endcase
    endif else begin
        ;; assume display is default device
        set_plot, default_device
        device, decomposed=0
        if keyword_set(colortable) then begin
            loadct, colortable
        endif

        window, WINID, xsize=winsize(0), ysize=winsize(1), title=runname
        !p.color = color_0
    endelse
    
    ;; Global formatting settings
    !y.tickformat = '(e10.1)'

    ;; position params in reading order (top left to bottom right,
    ;; going across)
    ;; maxw(0) -- right edge
    ;; maxw(1) -- top edge

    maxw = [subwinsize(0)/winsize(0), subwinsize(1)/winsize(1)]

    position(0).low_l = [0., 2./3.*maxw(1)] + margin + offset
    position(0).top_r = [0.5*maxw(0), maxw(1)] - margin + offset

    position(1).low_l = [0.5*maxw(0), 2./3.*maxw(1)] + margin + offset
    position(1).top_r = [maxw(0), maxw(1)] - margin + offset

    position(2).low_l = [0., maxw(1)/3.] + margin + offset
    position(2).top_r = [0.5*maxw(0), 2./3.*maxw(1)] - margin + offset

    position(3).low_l = [0.5*maxw(0), maxw(1)/3.] + margin + offset
    position(3).top_r = [maxw(0), 2./3.*maxw(1)] - margin + offset

    position(4).low_l = [0., 0.] + margin + offset
    position(4).top_r = [0.5*maxw(0), maxw(1)/3.] - margin + offset

    position(5).low_l = [0.5*maxw(0), 0.] + margin + offset
    position(5).top_r = [maxw(0), maxw(1)/3.] - margin + offset
    
    ;;print, range
    ;;print, logplot
    
    ;;
    ;; Top 2 graphs
    ;;
    
    ;; rho vs. rcm graph (on the left);
    ;;     truncate graph at rho=1.e-4
    pos = [position(0).low_l, position(0).top_r]
    
    if keyword_set(range) then begin
        plot, rcm(0,*), rho(0,*)>1.e-4,  $
          ytitle='rho (g/cm!e3!n)', ylog=logplot.rho,  $
          position=pos, /normal, xrange=range.rcm, $
          yrange=range.rho
    endif else begin
        plot, rcm(0,*), rho(0,*)>1.e-4,  $
          ytitle='rho (g/cm!e3!n)', ylog=logplot.rho,  $
          position=pos, /normal
    endelse
    
    for i=0,n_steps do begin
        oplot, rcm(time_i(i),*), rho(time_i(i),*),  $
          color=(col_step*(i+1)+color_0)
    endfor

    ;; ucm vs. rcm graph (on the right)
    pos = [position(1).low_l, position(1).top_r]
    
    if logplot.ucm then begin
        ucm_p = abs(ucm)
    endif else begin
        ucm_p = ucm
    endelse
    
    if keyword_set(range) then begin
        plot, rcm(1,*), ucm_p(1,*),  xrange=range.rcm, $
          ytitle='ucm (cm/s)', position=pos, /normal, /noerase,  $
          ylog=logplot.ucm, $
          yrange=range.ucm
    endif else begin
        plot, rcm(1,*), ucm_p(1,*),  ylog=logplot.ucm, $
          ytitle='ucm (cm/s)', position=pos, /normal, /noerase
    endelse
        
    for i=0,n_steps do begin
        oplot, rcm(time_i(i),*), ucm(time_i(i),*),  $
          color=(col_step*(i+1)+color_0)
    endfor

    ;;
    ;; Middle 2 graphs
    ;;

    ;; pres vs. rcm graph (on the left)
    pos = [position(2).low_l, position(2).top_r]
    
    if keyword_set(range) then begin
        plot, rcm(1,*), pres(1,*),  xrange=range.rcm, $
          ytitle='pres (dyne/cm!e2!n)',  $
          position=pos, /normal, /noerase, ylog=logplot.pres, $
          yrange=range.pres
    endif else begin
        plot, rcm(1,*), pres(1,*), $
          ytitle='pres (dyne/cm!e2!n)',  $
          position=pos, /normal, /noerase, ylog=logplot.pres
    endelse

    for i=2,n_steps do begin
        oplot, rcm(time_i(i),*), pres(time_i(i),*),  $
          color=(col_step*(i+1)+color_0)
    endfor

    ;; te vs. rcm graph (on the right)
    pos = [position(3).low_l, position(3).top_r]
    
    if keyword_set(range) then begin
        plot, rcm(1,*), te(1,*), xrange=range.rcm, ylog=logplot.te,  $
          ytitle='te (keV)', position=pos, /normal, /noerase, $
          yrange=range.te
    endif else begin
        plot, rcm(1,*), te(1,*), ylog=logplot.te, $
          ytitle='te (keV)', position=pos, /normal, /noerase
    endelse

    for i=0,n_steps do begin
        oplot, rcm(time_i(i),*), te(time_i(i),*),  $
          color=(col_step*(i+1)+color_0)
    endfor


    ;;
    ;; Bottom 2 graphs
    ;;

    ;; tion vs. rcm graph (on the left)
    pos = [position(4).low_l, position(4).top_r]
    
    if keyword_set(range) then begin
        plot, rcm(0,*), tion(0,*), xrange=range.rcm, ylog=logplot.tion, $
          ytitle='tion (keV)', position=pos, /normal, /noerase, $
          yrange=range.tion
    endif else begin
        plot, rcm(0,*), tion(0,*), ylog=logplot.tion, $
          ytitle='tion (keV)', position=pos, /normal, /noerase
    endelse

    for i=0,n_steps do begin
        oplot, rcm(time_i(i),*), tion(time_i(i),*),  $
          color=(col_step*(i+1)+color_0)
    endfor

    ;; tr vs. rcm graph (on the right)
    pos = [position(5).low_l, position(5).top_r]
    
    if keyword_set(range) then begin
        plot, rcm(1,*), tr(1,*),  xrange=range.rcm, $
          ytitle='tr (keV)', /ylog, position=pos, /normal, /noerase, $
          yrange=range.tr
    endif else begin
        plot, rcm(1,*), tr(1,*),  $
          ytitle='tr (keV)', /ylog, position=pos, /normal, /noerase
    endelse

    for i=0,n_steps do begin
        oplot, rcm(time_i(i),*), tr(time_i(i),*),  $
          color=(col_step*(i+1)+color_0)
    endfor

    ;; Put label at the top, containing runname and time range plotted
    xyouts, 0.3, 0.98, /normal, charsize=1.5, $
      '!17'+runname+': variables vs. rcm (cm)!3'

    xyouts, 0.3, 0.96, /normal, $
      '!3Times plotted:  '+string(time(time_i(0)))+' to '+ $
      string(time(time_i((size(time_i))(1) - 1)))+ $
      ' (time 0.0 always plotted)'
    
    xyouts, 0.3, 0.94, /normal, $
      '!3Time indices plotted: '+string(time_i(0))+' '+string(time_i(1))+' '+ $
      string(time_i(2))+' '+string(time_i(3))+' '+string(time_i(4))
    
    
    ;; reset device, and close

    if keyword_set(device) then begin
        if (device eq 'ps') then begin
            device, xoffset=0., yoffset=0., xsize=19.05, ysize=24.13,  $
              /courier, encapsulated=0
            device, /close
            !p.thick = 1.0
            set_plot, default_device
        endif
    endif

end


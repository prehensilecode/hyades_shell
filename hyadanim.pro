pro ehandler, event
    
    ;; simple event handler to Quit the animation widget
    
    widget_control, /destroy, event.top
    
end

pro hyadanim, var,  $
              xrange=xrange, yrange=yrange,  $
              plotrho=plotrho, $
              rhorange=rhorange, help=help, bigwin=bigwin,  $
              _extra=extra
    
    ;;
    ;; HYADANIM is run after quitting from HYADES_SHELL.  It makes use
    ;; of the variables in the common blocks that HYADES_SHELL
    ;; defines.  It animates the variable whose name is the string var.
    ;;
    ;; Inputs:
    ;;           var   == string -- name of variable to be
    ;;                              plotted/animated 
    ;;                        
    ;; Outputs (returns):
    ;;           none
    ;;           
    ;; Side effects:
    ;;           displays an animation widget with movie of the
    ;;           variable named in var
    ;;           
    ;;                 -- David Chin, 29 Jul 1999
    ;;
    ;; $Id: hyadanim.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common hyad_data
    common hyad_lims

    device, decomposed=0
    loadct, 27                  ; this CT produces decent MPG output
    
    novar = 0                   ; logical flag
    
    if keyword_set(help) then begin
        print, 'HYADANIM, var, [[xrange=xrange], [yrange=yrange], [/help]]'
        goto, ending
    endif
    
    ;; need to set xrange so that the plot doesn't rescale axes as
    ;; time goes on.
    if not keyword_set(xrange) then begin
        ;;xrange = [min(rcm), max(rcm)]
        xrange = limits.rcm
    endif
    
    nframes = ndumps - 1
    if not keyword_set(bigwin) then begin
        winsize = [450, 400]
    endif else begin
        print, 'HYADANIM: CAUTION! /bigwin option works ' + $
          'only on Unix, or if you have TONS of memory'
        winsize = [900, 800]
    endelse

    pwin    = replicate(-1, nframes)
    units   = ''

    case var of
        'rho': begin
            data = rho
            units = ' (g/cm!e3!n)'
            ylog = 1
            if not keyword_set(yrange) then yrange = limits.rho
        end
        
        'te':  begin
            data = te
            units = ' (keV)'
            ylog = 1
            if not keyword_set(yrange) then yrange = limits.te
        end
        
        'tion':  begin
            data = tion
            units = ' (keV)'
            ylog = 1
            if not keyword_set(yrange) then yrange = limits.tion
        end
        
        'tr':  begin
            data = tr
            units = ' (keV)'
            ylog = 1
            if not keyword_set(yrange) then yrange = limits.tr
        end
        
        'pres': begin
            data = pres
            units = ' (dyne/cm!e3!n)'
            ylog = 1
            if not keyword_set(yrange) then yrange = limits.pres
        end
        
        'ucm': begin
            data = ucm
            units = ' (cm/s)'
            ylog = 0            ; linear scale since ucm < 0 is possible
            if not keyword_set(yrange) then yrange = limits.ucm
        end
        
        'lasi': begin
            data = lasi
            ylog = 1
            if not keyword_set(yrange) then yrange = limits.lasi
        end
        
        else:  begin
            novar = 1           ; no variable was given
            goto, ending
        end
    endcase
    
    if not keyword_set(rhorange) then rhorange=[.0001, 10.]
    
    if var eq 'ucm' then begin
        ;; put in a dotted line at ucm=0
        zeroes = replicate(0., nframes)
        rcmrange = fltarr(nframes)
        for i=0,nframes-1 do begin
            rcmrange[i] = xrange[0] + i*(xrange[1] - xrange[0])/nframes
        endfor
        
        for i=0,nframes-1 do begin
            window, /free, xsize=winsize[0], ysize=winsize[1], /pixmap
            pwin[i] = !d.window
        
            plot, rcm[i,*], data[i,*],  $
              xtitle='rcm (cm)', ytitle=var+units, $
              xrange=xrange, $
              yrange=yrange, $
              /normal, $
              ylog=ylog, $
              position=[0.18, 0.1, 0.8, 0.8], $
              _extra=extra
            
            oplot, rcmrange, zeroes, linestyle=1, color=0.5*!d.n_colors
        
            xyouts, 0.4, 0.96, /normal, charsize=3.0, '!17'+runname
            xyouts, 0.2, 0.86, /normal, charsize=1.414, '!3Time: '+ $
              string(format='(e10.3)', time(i))+' s'
            xyouts, 0.2, 0.81, /normal, charsize=1.414, '!3Time index: ' +  $
              string(i)
        endfor
    endif else begin
        for i=0,nframes-1 do begin
            window, /free, xsize=winsize[0], ysize=winsize[1], /pixmap
            pwin[i] = !d.window
            
            
            if keyword_set(plotrho) then begin
                plot, rcm[i,*], data[i,*],  $
                  xtitle='rcm (cm)', ytitle=var+units, $
                  xrange=xrange, $
                  yrange=yrange, $
                  ystyle=8, $   ; suppress RHS y-axis
                  ytickformat='(e10.1)', $
                  /normal, $
                  ylog=ylog, $
                  position=[0.18, 0.1, 0.8, 0.9], $
                  _extra=extra
            
                ;; underlay Rho plot
                ;; do this because the CURSOR procedure gives data
                ;; coordinates by the most recent set of axes
                axis, yaxis=1, yrange=rhorange,  $
                  ytickformat='(e10.0)', ytitle='rho (g/cm!e3!n)',  $
                  /ylog, color=200, /save
                oplot, rcm[i,*], rho[i,*], color=200, linestyle=2
            endif else begin
                plot, rcm[i,*], data[i,*],  $
                  xtitle='rcm (cm)', ytitle=var+units, $
                  xrange=xrange, $
                  yrange=yrange, $
                  ytickformat='(e10.1)', $
                  /normal, $
                  ylog=ylog, $
                  position=[0.18, 0.1, 0.8, 0.9], $
                  _extra=extra
            endelse
            xyouts, 0.4, 0.96, /normal, charsize=3.0, '!17'+runname
            xyouts, 0.2, 0.86, /normal, charsize=1.414, '!3Time: '+ $
              string(format='(e10.3)', time(i))+' s'
            xyouts, 0.2, 0.81, /normal, charsize=1.414, '!3Time index: ' +  $
              string(i)        
        endfor
    endelse
    
    base = widget_base(title='Hyades 1D: '+runname)
    widget_control, /managed, base
    widget_control, /realize, base
    
    anim = cw_animate(base, winsize[0], winsize[1], nframes, pixmaps=pwin)
    cw_animate_run, anim, 30
    
    xmanager, 'HyadesAnimation', base, event_handler='ehandler', $
      group_leader=group, /no_block
    
    ending: begin
        if novar then print, 'HYADANIM: no such variable: ', var
    end
    
end

pro speed2, runname, ps=ps, xsrange=xsrange, xdrange=xdrange, _extra=extra
    
    ;; Computes speed of shock front, and finds correlation between
    ;; xdot (speed of shock front) and xdot^2 with tion.
    ;; Expects a file with name runname.time containing
    ;; 3 columns of data:
    ;;       time, x (position of shock), tion
    ;;    Data terminates with "end"
    ;;
    ;;                                -- David Chin
    ;; $Id: speed2.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
    ;;
    
    common speed2, time, tion, xshock, xshockdot, xshockdot2
    
    defaultdev = !d.name
    
    filename = runname+'.time'
    openr, lun, filename, /get_lun

    foundbegin = 0
    foundend   = 0
    d          = ''
    count      = 0

    time = fltarr(146)          ; time
    xshock  = fltarr(146)       ; position of shock front
    tion = fltarr(146)          ; tion at peak of shock

    repeat begin
        readf, lun, d
        d = strtrim(d, 2)
        db = byte(d)
        ;;print, d
        ;;print, db[0]
        
        if db[0] ne 35 then begin 
            if d eq 'end' then begin
                foundend = 1
            endif else begin
                ;; ASCII 35 == "#"
                if (db[0] ne 35) then begin
                    reads, d, tmp1, tmp2, tmp3
                    ;;print, tmp1, tmp2, tmp3, tmp4
                    time[count] = tmp1
                    xshock[count]  = tmp2
                    tion[count] = tmp3
                    count = count+1
                endif
            endelse
        endif
        comment: wait,  0.
    endrep until (foundend) 
    
    ;;print, 'count = ', count

    time = time[0:count-1]
    xshock = xshock[0:count-1]
    tion = tion[0:count-1]

    xshockdot = fltarr(count - 1)

    d_tion = fltarr(count)
    for i=0,count-2 do begin
        xshockdot[i] = (xshock[i+1] - xshock[i])/(time[i+1] - time[i])
    endfor

    xshockdot2 = xshockdot^2

    window, 19
    if keyword_set(xdrange) then begin
        plot, xshockdot2[0:count-2], tion[0:count-2], psym=4,  $
          xtitle='xshockdot2 (cm!e2!n/s!e2!n)', ytitle='tion (keV)',  $
          title='!17'+runname, xrange=xdrange, xstyle=1, _extra=extra
    endif else begin
        plot, xshockdot2[0:count-2], tion[0:count-2], psym=4,  $
          xtitle='xshockdot2 (cm!e2!n/s!e2!n)', ytitle='tion (keV)',  $
          title='!17'+runname, _extra=extra
    endelse
    xyouts, /normal, 0.4, 0.2,  $
      '!3Correlation coefficient: '+string(correlate(xshockdot2,tion))
    xyouts, /normal, 0.4, 0.15, $
      '!3Covariance:              '+string(correlate(xshockdot2,tion, $
                                                     /covariance))
    
    
    if keyword_set(ps) then begin
        set_plot, 'ps'
        device, filename=runname+'_time1.ps', /Helvetica
        
        if keyword_set(xdrange) then begin
            plot, xshockdot2[0:count-2], tion[0:count-2], psym=4,  $
              xtitle='xshockdot2 (cm!e2!n/s!e2!n)', ytitle='tion (keV)',  $
              title='!17'+runname, xrange=xdrange, xstyle=1, _extra=extra
        endif else begin
            plot, xshockdot2[0:count-2], tion[0:count-2], psym=4,  $
              xtitle='xshockdot2 (cm!e2!n/s!e2!n)', ytitle='tion (keV)',  $
              title='!17'+runname, _extra=extra
        endelse
        
        xyouts, /normal, 0.4, 0.2,  $
          '!3Correlation coefficient: '+string(correlate(xshockdot2,tion))
        xyouts, /normal, 0.4, 0.15, $
          '!3Covariance:              '+string(correlate(xshockdot2,tion, $
                                                         /covariance))
        device, /close
        set_plot, defaultdev
    endif
    
    print, 'Correlation coeff (xshockdot2, tion): ',correlate(xshockdot2, tion)
    print, 'Covariance:                       ',  $
      correlate(xshockdot2, tion, /covariance)

    window, 20
    if keyword_set(xsrange) then begin
        plot, xshock, tion, psym=4,  $
          xtitle='xshock (cm)', ytitle='tion (keV)', $
          title='!17'+runname, xrange=xsrange, xstyle=1, _extra=extra
    endif else begin
        plot, xshock, tion, psym=4,  $
          xtitle='xshock (cm)', ytitle='tion (keV)', $
          title='!17'+runname, _extra=extra
    endelse
    xyouts, /normal, 0.2, 0.8,  $
      '!3Correlation coefficient: '+string(correlate(xshock,tion))
    xyouts, /normal, 0.2, 0.75, $
      '!3Covariance:              '+string(correlate(xshock,tion,/covariance))
    
    if keyword_set(ps) then begin
        set_plot, 'ps'
        device, filename=runname+'_time2.ps', /Helvetica
        
        if keyword_set(xsrange) then begin
            plot, xshock, tion, psym=4,  $
              xtitle='xshock (cm)', ytitle='tion (keV)', $
              title='!17'+runname, xrange=xsrange, xstyle=1, _extra=extra
        endif else begin
            plot, xshock, tion, psym=4,  $
              xtitle='xshock (cm)', ytitle='tion (keV)', $
              title='!17'+runname, _extra=extra
        endelse
        xyouts, /normal, 0.2, 0.8, $
          '!3Correlation coefficient: '+string(correlate(xshock,tion))
        xyouts, /normal, 0.2, 0.75, $
          '!3Covariance:              '+string(correlate(xshock,tion, $
                                                         /covariance))
        device, /close
        set_plot, defaultdev
    endif

    print, 'Correlation coeff (xshock, tion): ',  $
      correlate(xshock, tion)
    print, 'Covariance:                           ',  $
      correlate(xshock, tion, /covariance)

    close, lun

end

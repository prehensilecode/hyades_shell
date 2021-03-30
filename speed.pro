
openr, lun, 'time14.dat', /get_lun

foundbegin = 0
foundend   = 0
d          = ''
count      = 0

time = fltarr(50)
rcm  = fltarr(50)
tionmax = fltarr(50)
tionmin = fltarr(50)

repeat begin
    readf, lun, d
    d = strtrim(d, 2)
    db = byte(d)
    ;;print, d
    ;;print, db[0]
    
    if d eq 'end' then begin
        foundend = 1
    endif else begin
        ;; ASCII 35 == "#"
        if (db[0] ne 35) then begin
            reads, d, tmp1, tmp2, tmp3, tmp4
            ;;print, tmp1, tmp2, tmp3, tmp4
            time[count] = tmp1
            rcm[count]  = tmp2
            tionmax[count] = tmp3
            tionmin[count] = tmp4
            count = count+1
        endif
    endelse
    comment: wait,  0.
endrep until (foundend) 
    
;;print, 'count = ', count

time = time[0:count-1]
rcm = rcm[0:count-1]
tionmax = tionmax[0:count-1]
tionmin = tionmin[0:count-1]

rcmdot = fltarr(count - 1)
;;rcd2   = fltarr(count)
d_tion = fltarr(count)
for i=0,count-2 do begin
    rcmdot[i] = (rcm[i+1] - rcm[i])/(time[i+1] - time[i])
    ;;rcd2[i]   = (rcm[i+1] - rcm[0])/(time[i+1] - time[0])
    d_tion[i] = tionmax[i] - tionmin[i]
endfor
;;rcd2[count-1]   = (rcm[count-1] - rcm[0])/(time[count-1] - time[0])
d_tion[count-1] = tionmax[count-1] - tionmin[count-1]

d_tion2 = fltarr(count)
for i=0,count-1 do begin
    d_tion2[i] = d_tion[i]/tionmax[i]
endfor

rcmdot2 = rcmdot^2
plot, rcmdot2[0:count-2], d_tion[0:count-2], psym=4

print, 'Correlation coeff (d_tion, rcmdot2): ', correlate(rcmdot2, d_tion)
print, 'Covariance:                          ',  $
  correlate(rcmdot2, d_tion, /covariance)
print, 'Correlation coeff (d_tion2, rcmdot2): ',correlate(rcmdot2, d_tion2)
print, 'Covariance:                          ',  $
  correlate(rcmdot2, d_tion2, /covariance)
end


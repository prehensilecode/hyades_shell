Pro rt_display, rcm, time, ucm, rho, pres, te, tion, tr, Aout

; Begun 5/21/99 by RPD
;
; This version, started 5/18/99, is an attempt to use actual hyades output
; Tritest3 works as edited for Te 5/20/99
; rt_display is to attempt to do all the variables 
;;
;; $Id: rt_display.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
;;

loadct,5

varnames=['ucm','rho','pres','tr','tion'] ; must adjust to do others 
av=size(varnames)
ar=size(rcm)
Plotvars=fltarr(ar(1),ar(2),av(1))
Plotvars(*,*,0)=ucm
Plotvars(*,*,1)=rho
Plotvars(*,*,2)=pres
Plotvars(*,*,3)=tr
Plotvars(*,*,4)=tion
ai=size(varnames)
imax=ai(1)-1

; rcm=Findgen(10)*1.1
;time=Findgen(10)*1.0+1

gr=[Min(rcm),Max(rcm)]          ; get r limits
Print,'min rcm = ', gr(0),'  max rcm =  ',gr(1)
Read,gr,Prompt='Enter desired rcm range min,max :'
Print,gr

gti=[Min(time),Max(time)]       ; get time limits
Print,'min time = ', gti(0),'  max time =  ',gti(1)
Read,gti,Prompt='Enter desired time range min,max :'
Print,gti

gn=[100,100]                    ; get # zones to plot
Read, gn, Prompt='Enter # of pts to plot in r,t:'

gs=[(gti(1)-gti(0))/gn(1),(gr(1)-gr(0))/gn(0)] ; set point spacing
limits=[gti(0),gr(0),gti(1),gr(1)] ; plot limits from input 

Aout=fltarr(gn(1)+1,gn(0)+1,av(1)) ; create output array

A=fltarr(2,ar(2))               ; For use in loop with 2 timedumps
B=fltarr(ar(2))
rzz=fltarr(ar(2))
rzzz=fltarr(ar(2))
Ain=fltarr(ar(1),ar(2))
azz=fltarr(ar(2))
azzz=fltarr(ar(2))
arz=ar(2)-1                     ; actual rcm, space dimension
B=B+1                           ;B= array with all elements = 1

at=size(time)
nt=at(1)-1                      ; index of max timedump in data

timeout=fltarr(gn(1))
timeout=gti(0)+(findgen(gn(1)+1)-1)*gs(0)

rout=fltarr(gn(0))
rout=gr(0)+(findgen(gn(0)+1)-1)*gs(1)

nt0=Max(Where(time LE gti(0)))  ; find time indices for loop
If (nt0 LT 0) THEN nt0=0        ; set to zero if error
nt1=Min(Where(time GE gti(1)))
If (nt1 GT (nt-1)) THEN nt1=(nt-1) ; largest is next to last in data
If (nt1 LT 0) THEN nt1=(nt-1)   ; set to nt-1 if error 
Print,'nt0,nt1=', nt0,nt1

For i = 0, imax do begin        ; loop for variables 

    Ain=Plotvars(*,*,i)         ; set variable

    For j=nt0,nt1 do begin      ; loop for times

        ttri=[B*time(j),B*time(j+1)] ; use 2 timesteps
        rzz(0:arz)=rcm(j,*)
        rzzz(0:arz)=rcm(j+1,*)
        rtri=[rzz,rzzz]         ; fixed for actual
        azz(0:arz)=Ain(j,*)
        azzz(0:arz)=Ain(j+1,*)
        A=[azz,azzz]            ; fill array for trigrid

        ;;Window,10+j, xsize=gn(1), ysize=gn(0)

        ;;Plot,ttri,rtri,psym=1			;to show triangles if needed

        Triangulate,ttri,rtri,tria,b1

        For k=0,N_ELEMENTS(tria)/3-1 do begin
            tt=[tria(*,k),tria(0,k)]
            ;;Plots,ttri(tt),rtri(tt)	;showing triangles
        endfor
        


        A2=Trigrid(ttri,rtri,A,tria,gs,limits)

        Atest=total(A2,2)

        t1=Min(Where(Atest NE 0.)) ; initial output index
        t2=Max(Where(Atest NE 0.)) ; index of last output element 
        ;;Print, 't1,t2=',t1,t2		 	; can monitor loop
        IF (t1 NE -1) AND (t2 NE -1) THEN BEGIN
            Aout(t1:t2,*,i)=A2(t1:t2,*)
        ENDIF

    endfor

    Window,20+i, xsize=gn(1), ysize=gn(0)+20 ; plot each variable
    
    xyouts, 0,0, varnames(i), /device, charsize = 2, color = 255

    tvscl, (Aout(*,*,i)), 0, 20

endfor

End


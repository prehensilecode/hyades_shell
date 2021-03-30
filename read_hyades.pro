pro read_hyades, lun
    
;;
;; Inputs:
;;        lun -- logical unit number (file ID) of OTF file
;;
;; Outputs:
;;        (none)
;;
;; Side effects:
;;        fills variables in hyad_data common block with data from lun
;;        (the OTF file)
;;
;;                            -- David Chin, 16 Jun 1999
;; 
;; This procedure has evolved from one written by a summer student at LLNL.
;; It reads the .otf file produced by HYADES.  It returns the variables listed 
;; above in the call, but could be modified to return others listed blow 
;;
;; The OTF file has rather uneven data format.
;;    The initial dump/snapshot, i.e. at time t=0., (called the
;;    "cycle 0 edit") consists of 2 chunks of output.  To make
;;    things a little more complicated, the final row of some of
;;    the chunks may be incomplete.
;;        Chunk 1 -- 11 columns (variables)
;;                   last row short: elems 0, 1, 2, 3 only
;;        Chunk 2 --  8 columns. (column Einz is always empty)
;;                   last row full
;;
;;    The subsequent dumps/snapshots/edits, i.e. at times t>0.,
;;    have 3 chunks.
;;       Chunk 1 -- 11 columns
;;                  last row short: elems 0, 1, 2, 3 only
;;       Chunk 2 -- 11 columns
;;                  last row gapped: elems 0, 1, 3, 6, 10 only
;;       Chunk 3 --  7 columns
;;                  last row gapped: elems 0, 1, 4 only
;;
;; More details are in the body of the code below.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Fixed problems with variables being in wrong positions of arrays.
;; Streamlined code.
;; -- David Chin, 29 May 1999 (19990528)
;;
;; Took care of Note1.  We now ignore comment lines.
;; -- David Chin, 28 May 1999 (19990528)
;;
;; This version includes modifications by Harry Reisig and Paul Drake, 
;; modified 990521 by RPD, mainly clean up
;;
;; Note1: Any extra uses of "mesh" in the .inf file, for example in lines 
;; that are comments, will cause errors
;;
;; Note 2: using the default ndumps=0 will not work for runs in which 
;; editdt is changed during the run.  
;;
;; fn, time, rz, u, rho, pres, qtot, te, tion, tr, zbar, lasi, rcm, ucm, ndumps
;; Argument list:
;;     fn	input file name (.otf file)
;;
;; $Id: read_hyades.pro,v 1.1.1.1 1999/09/03 14:25:14 dwchin Exp $
;;


    ;;  Extra possible variables follow
    ;;,dene,qelc,eelc,eicpl,$
    ;;	qion,csi,ldep 
    ;;+
    
    ;; see hyades_shell.pro for definition of the common block
    common hyad_data

    ;;
    ;; Get data from the .inf file.
    ;;
;    fn = runname + '.otf'
;    openr, lun, fn, /get_lun, error=err
;    if (err ne 0) then printf, -2, !err_string

    ;;
    ;; Skip first page
    ;;
    d = 'b'                     ; make d a string

    ;; Look for ASCII FF (form feed, new page) -- ASCII decimal 12 -- in first
    ;; character of line. This skips over the banner heading into the
    ;; Input Card section.
    repeat begin
        readf, lun, d           ; read a line at a time into string d
        db = byte(d)
    endrep until db(0) eq 12

    ;;
    ;; Get the dump time step and total time
    ;;

    ;; Flags -- ODD integers are TRUE, EVEN integers are FALSE - 0 is EVEN
    found_editdt = 0
    found_tstop  = 0
    found_mesh   = 0

    ;; nmesh  == Number of mesh points
    ;; nzone  == Number of zones = mesh - 1
    ;; ntimes == Number of timesteps (snapshots) wanted, including
    ;;           initial time (t=0)
    ;; ncols(i), i=0,1,2: number of columns in chunk of position i
    ;; nvars(i)  == Number of variables we are interested in
    ;;              from each chunk that will be read
    ;; tmp0, tmp1, tmp2, tmp3 == Temporary variables (floats)

    nmesh  = 0
    nzone  = 0                  ; can only be set after nmesh is set
    ntimes = 0

    ncols  = [11, 8, 7]

    nvars    = intarr(3)
    nvars(0) = ncols(0) - 2     ; we don't care about the 1st 2 columns
                                ; of the dump: zone #, and region #
    nvars(1) = ncols(0) - 2
    nvars(2) = 1

    tmp0 = 0.
    tmp1 = 0.
    tmp2 = 0.
    tmp3 = 0.

    ;; Look for strings 'editdt', 'tstop' and 'mesh'
    ;; This loop depends on the fact that there is only one occurence of
    ;; 'editdt' and 'tstop' in the .otf file.
    ;; We also ignore blank lines and comment lines.
    repeat begin
        readf, lun, d           ; read a line into string d
        d   = strtrim(d, 2)     ; remove leading and trailing blanks
        db  = byte(d)           ; convert to byte (char) array
        
        ;; ignore blank lines,
        ;; ignore 'c' or 'C' on line by itself -- 99 == 'c', 67 == 'C'
        ;; ignore lines beginning with 'c ' or 'C '
        if (db(0) ne 0) and  $
          not (((db(0) eq 99) or (db(0) eq 67)) and  $
               (n_elements(db) eq 1)) then begin
            if not (((db(0) eq 99) or (db(0) eq 67)) and  $
                    (db(1) eq 32)) then begin
                parameter = strpos(d,'parm') ; look for position of 'parm'
                pmesh     = strpos(d,'mesh') ; look for position of 'mesh'
                if (parameter(0) ne -1) then begin ; if 'parm' occurs
                    ;; look for editdt in current line
                    ppos = strpos(d,'editdt')
                    if (ppos(0) ne -1) then begin ; if 'editdt' occurs,
                                                  ;;; get value
                        reads, strmid(d,ppos+7,15), editdt
                        found_editdt = 1
                    endif else begin
                        pstop = strpos(d,'tstop')
                        if pstop ne -1 then begin ; if 'tstop' occurs,
                                                  ;;; get value
                            reads, strmid(d,pstop+6,15), tstop
                            found_tstop = 1
                        endif 
                    endelse
                endif else if (pmesh(0) ne -1) then begin ; if 'mesh' occurs
                    ;; read values of smesh and emesh from line
                    ;;     smesh == starting mesh point
                    ;;     emesh == ending mesh point
                    reads, strmid(d,pmesh+4,15), smesh, emesh
                    if (emesh gt nmesh) then nmesh=emesh
                    found_mesh = 1
                    nzone      = nmesh - 1
                endif
            endif ;; not (db(0) eq 99) ...
        endif ;; (db(0) ne 0) and ...
    endrep until (found_editdt and found_tstop and found_mesh)

    ;;
    ;; Establish output arrays
    ;;
    if ( (n_elements(ndumps) eq 0) or (ndumps eq 0) ) then begin
        ndumps = fix(tstop/editdt)
    endif

    ntimes = ndumps + 1         ; +1 for t=0.

    ;; time = time of dump
    ;; rlast and ulast = arrays containing the values of r and u from
    ;;                   the short last row of Chunk 1 in init and subseq
    ;;                   dumps
    time  = fltarr(ntimes)
    rlast = fltarr(ntimes)
    ulast = fltarr(ntimes)

    ;; otfarr0, otfarr1, and otfarr2 will contain all data
    ;; from the 3 different sized chunks:
    ;;     otfarr0(i,j,k), otfarr1(i,j,k), otfarr2(i,j,k)
    ;;                                 -- i=time index
    ;;                                 -- j=zone index
    ;;                                 -- k=variable index
    ;;
    ;; size 0 is (ntimes, nzone, 11) -- chunk 1 of initial dump (t=0.),
    ;;                                  chunks 1 and 2 of
    ;;                                  subsequent dumps (t>0.)
    ;; size 1 is (ntimes, nzone, 8)  -- chunk 2 of initial dump
    ;; size 2 is (ntimes, nzone, 7)  -- chunk 3 of subsequent dumps

    ;; otfarr0 will contain: r, u, rho, pres, m or qtot, te, tion, tr, zbar
    ;;                       i.e. size 0
    ;;                       all from Chunk 1 of init dump
    ;; otfarr1 will contain: dene, qelc, eelc, eicpl, qion, eion, csi,
    ;;                         ldep, lasi
    ;;                       i.e. size 0
    ;;                       all from Chunk 1 of subseq dumps

    otfarr0 = fltarr(ntimes, nzone, nvars(0))
    otfarr1 = fltarr(ntimes, nzone, nvars(1))
    ;;otfarr2 = fltarr(ntimes, nzone, nvars(2)) ; unused for now

    ;; Temporary arrays for reading in snapshot arrays
    ;; sized according to chunk size.  We only care about chunks of
    ;; two different sizes. Chunks 1 and 2 of initial dump, and of the
    ;; subsequent dumps, too.
    ;;    dummy0(i,j), dummy1(i,j) -- i=variable index
    ;;                                j=zone index
    dummy0 = fltarr(ncols(0), nzone)
    dummy1 = fltarr(ncols(1), nzone)
    ;;dummy2 = fltarr(ncols(2), nzone) ; unused for now

    ;;
    ;; Get initial values
    ;;
    time(0) = 0.0               ; initial time, t=0.0

    ;; Skip a page -- look for ASCII FormFeed as first character of line
    ;;   skips to the end of the Input Card section, beginning of the
    ;;   snapshots or dumps or "edits"
    repeat begin
        readf, lun, d
        db = byte(d)
    endrep until db(0) eq 12

    ;; The first chunk, the "Cycle Zero Edit", is the initial conditions.
    ;; Read it.

    ;; skip 3 lines
    for i=0,2 do begin
        readf, lun, d
    endfor


    ;; Read initial values into dummy array.  Indexing is (col,row).
    ;; OTF file has two chunks in the initial condition (cycle 0 edit) section
    ;; (see sample trial3.otf in this directory).
    ;;
    ;; Chunk 1:
    ;; --------
    ;;     columns:
    ;;         0,        1,          2, 3, 4,   5,    6,  7,  8,  9,    10
    ;;         j (zone), k (region), R, U, Rho, Mass, Te, Ti, Tr, Pres, Zbar
    ;;
    ;;     last row is short: only elements 0, 1, 2, 3
    ;;
    ;; Chunk2:
    ;; -------
    ;;     columns:
    ;;         0,        1,          2,   3,    4,    5,    6,    7
    ;;         j (zone), k (region), Rcm, Dene, Deni, Eelc, Eion, Erad
    ;;
    ;;         note: there is a final column (8) labeled Einz,
    ;;               but it's always empty
    ;;
    ;;     last row is full
    ;;
    ;; 1st chunk only gets assigned to dummy0. 2nd chunk will be ignored, below

    ;; Read in 1st chunk
    readf, lun, dummy0

    ;; We cut off the zone and region numbers from dummy0, then transpose
    ;; it, and assign it to otfarr0.  Since we cut off zone numbers, the
    ;; variables are offset.
    ;; otfarr0 contains:
    ;;     third index:
    ;;         0, 1, 2,   3,    4,  5,  6,  7,    8
    ;;         R, U, Rho, Mass, Te, Ti, Tr, Pres, Zbar
    otfarr0(0,*,*) = transpose(dummy0(2:10,*))

    ;; Unfortunately, the subsequent dumps have the variables of the 
    ;; 1st chunk in a different order.  So, we must re-arrange the
    ;; variables of the initial dump to be in the same order as what will
    ;; come later.
    ;;          0  1  2    3     4   5     6     7     8
    ;; We have: r, u, rho, m,    te, tion, tr,   pres, zbar
    ;; We want: r, u, rho, pres, m,  te,   tion, tr,   zbar
    tv0 = reform(otfarr0(0,*,7)) ; pres -> tv0, a temp array
    otfarr0(0,*,7) = otfarr0(0,*,6)
    otfarr0(0,*,6) = otfarr0(0,*,5)
    otfarr0(0,*,5) = otfarr0(0,*,4)
    otfarr0(0,*,4) = otfarr0(0,*,3)
    otfarr0(0,*,3) = tv0

    ;; Get r and u for the last mesh point
    readf, lun, tmp0, tmp1, tmp2, tmp3
    rlast(0) = tmp2
    ulast(0) = tmp3

    ;; skip 3 lines
    ;;for i=0,2 do begin
    ;;    readf, lun, d
    ;;endfor

    ;; You think that shuffling was bad? Some of the variables that we
    ;; might be interested in, as evidenced by their allocation at the
    ;; bottom, such as qelc, eicpl, lasi, are in the subsequent dumps but
    ;; not the initial one.  Some of the variables are in both.  I propose
    ;; to ignore the ones that are in both, namely: dene, eelc, eion.

    ;; Read in 2nd chunk, but do nothing to it or with it,
    ;; i.e. ignore 2nd chunk
;   readf, lun, dummy1

    ;; Don't need to do anything to ignore 2nd chunk.
    ;; When we start reading the t>0. dumps, we always look for ASCII FF,
    ;; which will take us past the 2nd chunk of initial conditions.

    ;; following line is redundant: initialized to zero when defined.
    ;;otfarr1(0,*,*) = 0.   ; output array 2 does not have initial values


    ;;
    ;; Get the data from the dumps/snapshots, at times t>0.0
    ;;

    ;; Get the time
    print, 'ndumps=', ndumps, '       tstop=', tstop, '       editdt=', editdt

    ;; Each dump comprises three chunks.  The variables are different
    ;; from those in the initial condition (edit cycle 0) dump. Gotcha!
    ;; OTF file contains, for edit cycles > 0:
    ;;
    ;; Chunk 1:
    ;; --------
    ;;    columns:
    ;;        0,        1,          2, 3, 4,   5,    6,    7,  8,  9,  10
    ;;        j (zone), k (region), R, U, Rho, Pres, Qtot, Te, Ti, Tr, Zbar
    ;;
    ;;    last row is short: only elements 0, 1, 2, 3
    ;;
    ;; Chunk 2:
    ;; --------
    ;;    columns:
    ;;        0,        1,          2,    3,    4,    5,     6,    7,
    ;;        j (zone), k (region), Dene, Qelc, Eelc, Eicpl, Qion, Eion,
    ;;
    ;;        8,   9,    10
    ;;        Csi, Ldep, Lasi
    ;;
    ;;    last row is gapped: only elements 0, 1, 3, 6, 10
    ;;
    ;; Chunk 3:
    ;; --------
    ;;    columns:
    ;;        0,        1,          2,  3,    4,    5,     6
    ;;        j (zone), k (region), Tr, Erad, Qrad, Recpl, Radmfp
    ;;        
    ;;        (yes, Tr is duplicated in Chunk 1)
    ;;
    ;;    last row is gapped: only elements 0, 1, 4
    ;;

    ;;print, ' Index j  time(j)'

    for j=1,ndumps do begin
        ;; Skip 1 page: goes to the problem snapshots, each snapshot is
        ;; on a new page. Pages delimited by ASCII FF, as usual.
        repeat begin
            readf, lun, d
            db = byte(d)
        endrep until db(0) eq 12	
        
        ;; Read the header line of the snapshot, and
        ;; extract the time
        readf, lun, d
        tpos    = strpos(d,'Time')
        
        time(j) = float(strmid(d, tpos+6, 12))
        
        ;;print, j, time(j)
        
        ;; Skip 4 lines -- blank lines and variable names for snapshot
        for i=0,3 do begin
            readf, lun, d
            ;;print, d
        endfor
        
        ;; Read in 1st chunk
        readf, lun, dummy0
        otfarr0(j,*,*) = transpose(dummy0(2:10,*))
        
        ;; Get r for the last mesh point
        readf, lun, tmp0, tmp1, tmp2, tmp3
        rlast(j) = tmp2
        ulast(j) = tmp3
        
        ;; skip 3 lines -- separation between chunks
        for i=0,2 do begin
            readf, lun, d
        endfor
        
        ;; Read in 2nd chunk
        readf, lun, dummy0
        otfarr1(j,*,*) = transpose(dummy0(2:10,*))
        
        ;; variable lasi also occurs in last (gapped) line
        ;; ignore it since we're not computing a CM average of it
    endfor

    print, 'Got data at all dump times '

    ;;
    ;; Compute rcm and ucm
    ;;    Rcm is one of the columns in the OTF file.  Do
    ;;    we need to do this?
    ;;
    rz  = reform(otfarr0(*,*,0))
    rcm = fltarr(ntimes,nzone)

    for j=0,ndumps do begin
        for  i=0,nzone-2 do begin
            rcm(j,i)   = (rz(j,i) + rz(j,i+1))/2.
        endfor
        rcm(j,nzone-1) = (rz(j,nzone-1) + rlast(j))/2.
    endfor

    u   = reform(otfarr0(*,*,1))
    ucm = fltarr(ntimes,nzone)

    for j=0,ndumps do begin
        for  i=0,nzone-2 do begin
            ucm(j,i)   = (u(j,i) + u(j,i+1))/2.
        endfor
        ucm(j,nzone-1) = (u(j,nzone-1) + ulast(j))/2.
    endfor

    ;;
    ;; Here is where each array is assigned.  
    ;; read_hyades just read in the .otf file into the 3D arrays
    ;; otfarr0(*,*,*) and otfarr1(*,*,*).
    ;; It now sets 2D arrays equal to each of the varibles:
    ;;    1st index is time, 2nd index is zone

    ;;otfarr0 contains: r, u, rho, pres, m or qtot,  te,   tion, tr,   zbar
    ;;                  0  1  2    3     4           5     6     7     8

    ;;qtot  = reform(otfarr0(*,*,5)) ; don't care about qtot
    rho   = reform(otfarr0(*,*,2))
    pres  = reform(otfarr0(*,*,3))
    te    = reform(otfarr0(*,*,5))
    tion  = reform(otfarr0(*,*,6))
    tr    = reform(otfarr0(*,*,7))
    zbar  = reform(otfarr0(*,*,8))

    ;;otfarr1 contains: dene, qelc, eelc, eicpl, qion, eion, csi, ldep, lasi
    ;;                  0     1     2     3      4     5     6    7     8

    ;; only care about lasi, now
    lasi  = reform(otfarr1(*,*,8))
    ;;dene  = reform(otfarr1(*,*,0))
    ;;qelc  = reform(otfarr1(*,*,1))
    ;;eelc  = reform(otfarr1(*,*,2))
    ;;eicpl = reform(otfarr1(*,*,3))
    ;;qion  = reform(otfarr1(*,*,4))
    ;;eion  = reform(otfarr1(*,*,5))
    ;;csi   = reform(otfarr1(*,*,6))
    ;;ldep  = reform(otfarr1(*,*,7))

    ;;
    ;; Housekeeping
    ;;
    close, lun
    free_lun, lun

end

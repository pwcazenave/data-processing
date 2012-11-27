      subroutine hlpred (D,ustc,ws,do,T,lam,H,type)
c    hlpred.f
c 
c    Input do,T,D,ws,taucr
c    Outputs expected ripple dimensions, lam and H
c
      real D,lam_ms,H_ms,do,T,pi
      real lam,H,stp,lam_o,H_o,stp_o,omega,ws
      real lam_a,H_a,stp_a,lam_s,H_s,stp_s
      real rho,rhos,g,vk
      integer type_ms,type,j1
c
c
      parameter(rho=1.0,rhos=2.65,g=980.,vk=0.408)
      pi = acos(-1.0)
c
      omega=2*pi/T
      taucr=rho*ustcr*ustcr
c
c      if (ust.ne.0.and.ust/ustc.lt.0.79) then
c	     write (8,*) "Below Threshold"
c	     H=0.0
c             lam=0.0
c 	     goto 101
c      end if

c
c        Assume anorbital type, and calculate expected ripple dimensions
c
      lam_a=535.*D 
c          initial guess of steepness
      stp_a=0.10
      call stp_clc (i,lam_a,H_a,do,D,stp_a)
c
      if (H_a.gt.0.) then
	     doH_a=do/H_a
      else
	     doH_a=0.
      end if
c
c
c        Now assume orbital conditions, and predict ripple dimensions
c
201   lam_o=0.62 * do
      stp_o=0.17
      H_o=stp_o*lam_o
c
      doH_o=do/H_o
c      write (6,91) lam_o,stp_o,H_o,lam_a,stp_a,H_a,doH_o,doH_a
c
c        Now, decide whether orbital, or anorbital
c        conditions are most consistent.
      if (stp_a.lt.0.01.or.doH_a.eq.0.) then
		write (6,*) "upper plane bed"
		type = 6
      elseif (doH_a.lt.20.and.doH_a.gt.0.) then
c		write (6,*) "orbital"
		type = 1
      elseif (doH_a.gt.100.) then
c		write (6,*) "anorbital"
		type = 2
      elseif (doH_a.lt.35.and.doH_a.gt.0.) then
c		write (6,*) "suborbital/orbital"
		type = 3
      elseif (doH_a.gt.65.) then
c		write (6,*) "suborbital/anorbital"
		type = 3
      else
		type = 3
		if (stp_a.lt.0.01.or.doH_a.eq.0.) type=6
      endif
c
      if (type.eq.1.or.type.eq.4) then
            lam=lam_o
            H=H_o
            stp=stp_o
      elseif (type.eq.2.or.type.eq.5.or.type.eq.6) then 
            lam=lam_a
            H=H_a
            stp=stp_a
      elseif (type.eq.3) then
c	    interpolate based on weighted average		
            frac=(alog(do/H_a)-alog(100.))/(alog(20.)-alog(100.))
            lam_s=exp(frac*(alog(lam_o)-alog(lam_a))+alog(lam_a))
c	    lam_s=exp(0.5*(alog(lam_a)+alog(lam_o)))
	    stp_s=0.1
            call stp_clc (i,lam_s,H_s,do,D,stp_s)
            lam=lam_s
            H=H_s
            stp=stp_s
c            write (6,*) "suborbital"
      end if
      if (j1.eq.9) type_ms=9
c 99   write (8,90) type_ms,type,H_ms,lam_ms,D,do,T,H,lam,doH_a
c      write (7,93) type_ms,type,H_ms,lam_ms,H_a,lam_a,H_o,lam_o,
c     1 H_s,lam_s,do/H_o,do/H_a,do/H_s
c
91    format (9f8.3)
90    format (2i3,2f7.2,f8.4,5f8.2)
93    format (2i3, 11f7.2)
101   return
      end

c
c
c
c
	subroutine stp_clc (i,lam,H,do,D,stp)
	real lam,H,do,D,stp
	integer i
c
        do 200 ni=1,30
c           iterate to consistent steepness, u*, z0.
            H = stp * lam
	    if (H.lt.(3.*D)) then
		H = 0.0
		stp = 0.0
		goto 201
	    endif
c
c           recalculate steepness based on a regression relationship
	    stp_new = exp(-0.0950*((alog(do/H))**2.) + 
     1                0.4415*(alog(do/H))-2.2827)
c           make sure that new steepness is reasonable, less than .17
            if (stp_new.gt.0.17) stp_new=0.17
	    if (stp_new.lt.0.17.and.do/H.lt.10.) stp_new=0.17
c
c           see if steepness has converged
            if (((abs(stp_new-stp)/stp).lt.0.005).or.(ni.eq.30)) then
               stp_a = stp_new
               goto 201
            else
c	    pick new steepness
c              write (6,95) i,ni,stp_new,stp,do/H
		if (ni.eq.1) stp_old = stp
		if ((stp_old.lt.stp_new).and.(stp.lt.stp_new)) then
			stp_old = stp
			stp = stp_new+(stp_new-stp)
		elseif ((stp_old.gt.stp_new).and.(stp.gt.stp_new)) then
			stp_old = stp
			stp = stp_new+(stp_new-stp)
		elseif ((stp_old.lt.stp_new).and.(stp.gt.stp_new)) then
			stp_old = stp
			stp = 0.5*(stp_new+stp)
		elseif ((stp_old.gt.stp_new).and.(stp.lt.stp_new)) then
			stp_old = stp
			stp = 0.5*(stp_new+stp)
		endif
		if (stp.gt.0.17) stp = 0.17
            endif
200     continue
c
95      format (2i3, 7f8.4,f8.2)
96      format (2i3, 7f8.4, f8.2) 
201	return
	end

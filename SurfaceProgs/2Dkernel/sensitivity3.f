c This version (sensitivity2.f) same as sensitivity.f except it increases the 
c  number of frequencies used in constructing kernels by interpolation between 
c  original frequencies.  For longer windows, may not be enough frequencies
c  to give smooth representation of interference in outer Fresnel zones
c
c  sensitivity3.f outputs only unsmoothed version - smoothing will be done
c  later in inversion program ( for linear interporation instead of Gaussian)
c
c  ./sensitivity3 < input_sensitivity3
	parameter( maxnfreq = 50,radius = 6371,
     1             maxix = 500,maxiy = 500 )

	real*8    phsens(maxix,maxiy),      ampsens(maxix,maxiy)
	real*8 avgphsens(maxix,maxiy),   avgampsens(maxix,maxiy)
	real wgttemp(maxix,maxiy)

	real freq(maxnfreq),amplitude(maxnfreq)
	real kk,lamda
	character *70 outfn1,outfn2,spcfn
	
	read(*,*) nperiods
	do iper = 1, nperiods
	
	write(*,*) 'input velocity'
	read(*,*) phvel
	write(*,*) 'please input the spectral file'
	read(*,*) spcfn
c	write(*,*) 'please input the number of freq'
c	read(*,*) nfreq
	write(*,*) 'please input outfn of unsmoothed sens'
	read(*,*) outfn1
c	write(*,*) 'please input outfn of smoothed sens'
c	read(*,*) outfn2
c	write(*,*) 'please input smooth len (km) '
c	read(*,*)   scalelen 

	open(10,file = spcfn)
	open(30,file = outfn2)
        open(20,file = outfn1)
	
c	xbeg = -1500
c	xend =  1500
c	ybeg = -1500
c	yend =  1500
c	dx   =  10.
c	dy   =  10.
	xbeg = -3000
	xend =  3000
	ybeg = -3000
	yend =  3000
	dx   =  20.
	dy   =  20.
	
	nx = (xend-xbeg)/dx + 1
	ny = (yend-ybeg)/dy + 1	 
	
c	write(30,100) nx,xbeg,dx
c	write(30,100) ny,ybeg,dy
	write(20,100) nx,xbeg,dx
	write(20,100) ny,ybeg,dy
100   format(I3, 2F8.1) 
	
	pi = 4.* atan(1.)   

	open(10,file = spcfn)
	  sumamp = 0.
	  read(10,*) nfreq
	do ifreq = 1, nfreq
	  read(10,*) freq(ifreq),amplitude(ifreq)
c	  sumamp = sumamp + amplitude(ifreq)
	enddo
c  add extra, interpolated frequencies	
        do ifreq = 1, nfreq-1
	  amplitude(ifreq+nfreq) = 0.5*(amplitude(ifreq) 
     1                           + amplitude(ifreq+1))
          freq(ifreq+nfreq) = 0.5*(freq(ifreq)+freq(ifreq+1))
	enddo
	
        nfreq = 2*nfreq-1
	
	do ifreq = 1, nfreq
	  sumamp = sumamp + amplitude(ifreq)
	enddo
	
	do ifreq = 1,nfreq
	   amplitude(ifreq) = amplitude(ifreq)/sumamp
	enddo	
	
	do ix = 1,maxix
	do iy = 1,maxiy
	   phsens(ix,iy) = 0.
	avgphsens(ix,iy) = 0.
	   ampsens(ix,iy) = 0. 
	avgampsens(ix,iy) = 0.
	enddo
	enddo

	do ifreq = 1, nfreq
c!	   write(*,*) ifreq
	 period = 1/freq(ifreq)
	 lamda = phvel*period
         kk = 2*pi/lamda*radius
c	 write (*,*) ifreq,period,kk, lamda
  	 do ix = 1,nx
	     x = (ix-1)*dx + xbeg
  	     delta1 = x
	   do iy = 1,ny
	     y = (iy-1)*dy + ybeg
	     if(x.eq.0 .and. y.eq.0) then 
	       delta2 = sqrt(dx**2+dy**2)
	     else
	       delta2 = sqrt(x**2+y**2)
	     endif
cc formula from Ying Zhou et al., 2004, GJI 3-D sensitivity kernels for surface-wave observables

        phsens(ix,iy) = phsens(ix,iy)   + 
     1  amplitude(ifreq)*(-2)*kk**2*sin(kk*(delta1+delta2)/radius+pi/4)
     1                 /sqrt(8*pi*kk*abs(sin(delta2/radius)))
     1                 * ((dx*dy)/radius**2) 

	ampsens(ix,iy) = ampsens(ix,iy) +
     1  amplitude(ifreq)*(-2)*kk**2*cos(kk*(delta1+delta2)/radius+pi/4)
     1                 /sqrt(8*pi*kk*abs(sin(delta2/radius)))
     1              * ((dx*dy)/radius**2)
              
                    
	   enddo
	 enddo
	enddo	     




c        alpha = 1./( scalelen**2 )

c	nxlimit = 20. 	
c	nylimit = 20. 

         do ix = 1, nx
	 do iy = 1, ny
	   x = (ix-1)*dx + xbeg
	   y = (iy-1)*dy + ybeg
c            wgtsum = 0
c   
c	   ixxbeg = ix-nxlimit
c	   ixxend = ix+nxlimit
c	   iyybeg = iy-nylimit
c	   iyyend = iy+nylimit
c           if( ix .le. nxlimit    ) ixxbeg = 1
c	   if( ix .ge. (nx-nxlimit)) ixxend = nx
c           if( iy .le. nylimit    ) iyybeg = 1
c	   if( ix .ge. (ny-nylimit)) iyyend = ny
c	
c           do ixx = ixxbeg,ixxend
c	   do iyy = iyybeg,iyyend
c	      xx = (ixx-1)*dx + xbeg
c	      yy = (iyy-1)*dy + ybeg
c              distsq = alpha*((xx-x)**2+(yy-y)**2)
c             if( distsq.lt. 80. ) then
c               wgttemp(ixx,iyy) = exp(-distsq)
c               wgtsum = wgtsum + wgttemp(ixx,iyy)
c             else
c               wgttemp(ixx,iyy) = 0.0
c             endif
c           enddo
c	   enddo


c           do ixx = ixxbeg,ixxend
c	      do iyy = iyybeg,iyyend
c	       avgphsens(ix,iy)   = avgphsens(ix,iy) + 
c     1                     phsens(ixx,iyy)*wgttemp(ixx,iyy)/wgtsum
c	      avgampsens(ix,iy)  = avgampsens(ix,iy) + 
c     1                    ampsens(ixx,iyy)*wgttemp(ixx,iyy)/wgtsum
c              enddo
c	   enddo        
           write(20,*) x,y,   phsens(ix,iy),   ampsens(ix,iy)
c	   write(30,*) x,y,avgphsens(ix,iy),avgampsens(ix,iy)
	 enddo
	 enddo		

c	close (unit=30)
       close (unit=20)
c  end loop over periods       
       enddo 

	end


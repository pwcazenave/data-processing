C     Process digitised points
C
   10 read(1,*,end=100)i,x1,y1
      read(1,*,end=100)i,x2,y2
      read(1,*,end=100)i,x3,y3
      xnew=(x1+x2+x3)/3.0
      ynew=(y1+y2+y3)/3.0
      error=(y1-y3)/2.0
      write(10,*)xnew,ynew,error
      go to 10
  100 stop
      end

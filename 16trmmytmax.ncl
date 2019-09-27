begin
yeardir=(/"2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017"/)
;yeardir=(/"2003","2004","2005","2006","2007","2008","2009","2010","2011","2012"/)
;yeardir=(/"2012","2013","2014","2015","2016","2017"/)
year=(/2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017/)
;year=(/2003,2004,2005,2006,2007,2008,2009,2010,2011,2012/)
;year=(/2012,2013,2014,2015,2016,2017/)

nyear=dimsizes(yeardir)
prcmin=new((/400,1440,nyear/),double,-999.)
prcmax=new((/400,1440,nyear/),double,-999.)
do y=0,nyear-1,1
file_name = systemfunc ("ls 3B42_Daily."+yeardir(y)+"*.nc4")
  nfile=dimsizes(file_name)
  prc_y=new((/400,1440,nfile/),double,-999.)
do i=0,nfile-1,1  
   f      = addfile (file_name(i), "r")
   prc   = f->precipitation
   prc@_FillValue  = -9999.
   prc@units       = "mm"
   prc@long_name   = "TRMM_3B43 precip"
   nlat       = 400
   mlon       = 1440
   lat        = ispan(0,nlat-1,1)*0.25 -  49.875
   lon        = ispan(0,mlon-1,1)*0.25 - 179.875

   lat@long_name = "latitude"
   lat@units  = "degrees_north"
   lat!0      = "lat"
   lat&lat    =  lat

   lon@long_name = "longitude"
   lon@units  = "degrees_east"
   lon!0      = "lon"
   lon&lon    =  lon
   prc!1      = "lat"                   ; 1st ... name the dimensions
   prc!0      = "lon"
   prc&lat    =  lat                    ; create coordinate variable
   prc&lon    =  lon
   prc_y(:,:,i)= prc(lat|:,lon|:)
   delete(prc)
end do
nq=floattoint(0.95*nfile)
nmax=nfile-nq+1
nmin=nq-1
do a=0,399,1
do o=0,1439,1
   s=prc_y(a,o,:)
   qsort(s)
   div=s(nq-1)
   pmin=0
   pmax=0
   prmin=new((/nfile/),double,-999.)
   prmax=new((/nfile/),double,-999.)
   do i=0,nfile-1,1
   if (prc_y(a,o,i).lt.div) then
   prmin(pmin)=prc_y(a,o,i)
   pmin=pmin+1
   else
   prmax(pmax)=prc_y(a,o,i)
   pmax=pmax+1
   end if
   prcmax(a,o,y)=dim_sum_n_Wrap(prmax,0)
   prcmin(a,o,y)=dim_sum_n_Wrap(prmin,0)
end do   
end do
end do
end do
nlat       = 400
   mlon       = 1440
   lat        = ispan(0,nlat-1,1)*0.25 -  49.875
   lon        = ispan(0,mlon-1,1)*0.25 - 179.875

   lat@long_name = "latitude"
   lat@units  = "degrees_north"
   lat!0      = "lat"
   lat&lat    =  lat

   lon@long_name = "longitude"
   lon@units  = "degrees_east"
   lon!0      = "lon"
   lon&lon    =  lon
   
   prcmax!1      = "lat"                   ; 1st ... name the dimensions
   prcmax!0      = "lon"
   prcmax&lat    =  lat                    ; create coordinate variable
   prcmax&lon    =  lon
   
   prcmin!1      = "lat"                   ; 1st ... name the dimensions
   prcmin!0      = "lon"
   prcmin&lat    =  lat                    ; create coordinate variable
   prcmin&lon    =  lon
   
yt=new((/400,1440/),double);;
yt=regCoef(year,prcmax)*10
acry=new((/400,1440/),double);;
do m=0,399,1
do n=0,1439,1
;w
acry(m,n)=esccr(year,prcmax(m,n,:)*10,0)
end do
end do
Nr    = dimsizes(year)
proby=rtest(acry,Nr,0)
prob=proby(:,:,0)
nlat       = 400
   mlon       = 1440
   lat        = ispan(0,nlat-1,1)*0.25 -  49.875
   lon        = ispan(0,mlon-1,1)*0.25 - 179.875

   lat@long_name = "latitude"
   lat@units  = "degrees_north"
   lat!0      = "lat"
   lat&lat    =  lat

   lon@long_name = "longitude"
   lon@units  = "degrees_east"
   lon!0      = "lon"
   lon&lon    =  lon

   yt!0      = "lat"                   ; 1st ... name the dimensions
   yt!1      = "lon"
   yt&lat    =  lat                    ; create coordinate variable
   yt&lon    =  lon        
   prob!0      = "lat"                   ; 1st ... name the dimensions
   prob!1      = "lon"
   prob&lat    =  lat                    ; create coordinate variable
   prob&lon    =  lon
   
   wks=gsn_open_wks("png","trmmtrendymax0317")
  res                  = True                      ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@cnLinesOn        = False                ; no contour li
  res@pmTickMarkDisplayMode = "Always"; use NCL default lat/lon labels
;  res@vpHeightF= 0.4                    ; change aspect ratio of plot
;  res@vpWidthF = 0.6
  res@pmLabelBarOrthogonalPosF = 0.1           ; move whole thing down

  res@pmLabelBarWidthF     =  0.7
  res@pmLabelBarHeightF    =  0.05
  res@lbLabelFontHeightF   =  0.015
  res@tmXBLabelFontHeightF =  0.018       
  res@tmYLLabelFontHeightF =  0.018    
  res@lbLabelBarOn         =  False  

  res@mpLimitMode         = "LatLon"
  res@mpMinLatF           = 4
  res@mpMaxLatF           = 50
  res@mpMinLonF           = 73
  res@mpMaxLonF           = 150
  res@mpDataBaseVersion="Ncarg4_1";中等分辨率 province outline
  res@mpDataSetName="Earth..4"           ;第4版地图，有中国边界数据
  res@mpOutlineOn            = True
  res@mpOutlineBoundarySets = "National"
  res@mpOutlineSpecifiers=(/"China:states","Taiwan"/)

  gsn_define_colormap(wks,"GMT_polar")
  res@cnFillOn             = True         ; turn on color fill
  res@cnLineLabelsOn       = False
  res@cnLinesOn = False
  res@gsnSpreadColors       =True
  res@cnRasterModeOn        = True
;  res@pmLabelBarOrthogonalPosF = 0.14           ; move whole thing down
  res@cnLevelSelectionMode  = "ExplicitLevels"  
  res@cnLevels              = (/-60.,-40.,-20.,-10.,0.,10.,20.,40.,60./)
  res@cnFillColors          = (/2,4,6,7,9,13,14,15,16,17/)

  plot = gsn_csm_contour_map_ce(wks,yt(:,:),res)


  delete(res)
   res                      = True              
res@gsnDraw              = False             
res@gsnFrame             = False             
res@cnMonoFillPattern    = False
res@cnMonoFillColor      = True
res@cnLinesOn            = False
res@cnLineLabelsOn       = False
res@cnInfoLabelOn        = False
res@lbLabelBarOn         = False
res@gsnAddCyclic         = False
   
res@cnLevelSelectionMode  = "ExplicitLevels"  
res@cnLevels              = (/0.05/)            
res@cnFillOn              = True
res@gsnSpreadColors       = True
res@cnFillColor           = (/"white","black"/) 
res@cnFillPatterns        = (/17,-1/)
res@cnFillDotSizeF        = 0.0035


  plott = gsn_csm_contour(wks, prob(:,:),res)
  overlay(plot,plott)

  
 pres=True
 ;pres@gsnPanelFigureStrings = (/"A","B","C","D"/)
 pres@amJust = "TopLeft"
 pres@gsnPanelMainString = " "
 pres@gsnPanelLabelBar   =  True
 gsn_panel(wks,plot,(/1,1/),pres)

end 
